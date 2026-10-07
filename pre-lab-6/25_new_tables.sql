SET ROLE app_owner;

ALTER TABLE ref.addresses
ADD COLUMN postal_code VARCHAR(6);

ALTER TABLE app.client_addresses
DROP COLUMN delivery_notes;

ALTER TABLE app.client_addresses
DROP COLUMN intercom_code;

DROP TABLE app.status_history CASCADE;
DROP TABLE app.movement_history CASCADE;
DROP TABLE app.packages CASCADE;


CREATE TABLE ref.departure_types (
    id SERIAL
        PRIMARY KEY,
    type VARCHAR(20)
        NOT NULL
        CHECK ( type IN (
            'письмо',
            'бандероль',
            'посылка',
            'другое'
        )),
    subtype VARCHAR(50),
    max_weight_g INTEGER
        NOT NULL
        CHECK (max_weight_g > 0),
    description TEXT
);

COMMENT ON TABLE ref.departure_types
IS 'Типы почтовых отправлений';


CREATE TABLE ref.tariffs (
    id SERIAL
        PRIMARY KEY,
    departure_type_id INTEGER
        NOT NULL
        REFERENCES ref.departure_types(id),
    route_id INTEGER
        NOT NULL
        REFERENCES ref.routes(id),

    UNIQUE(departure_type_id, route_id),

    weight_limit_1_g INTEGER
        NOT NULL
        CHECK (weight_limit_1_g > 0),
    price_1 NUMERIC(10, 2)
        NOT NULL
        CHECK (price_1 > 0),
    weight_limit_2_g INTEGER
        NOT NULL
        CHECK (weight_limit_2_g > weight_limit_1_g),
    price_2 NUMERIC(10, 2)
        NOT NULL
        CHECK (price_2 > price_1),
    additional_weight_g INTEGER
        NOT NULL
        CHECK (additional_weight_g > 0),
    price_3 NUMERIC(10, 2)
        NOT NULL
        CHECK (price_3 > 0)
);

COMMENT ON TABLE ref.tariffs IS 'Тарифы';


CREATE TABLE app.dimensions (
    id SERIAL PRIMARY KEY,
    width_mm INTEGER
        NOT NULL
        CHECK (width_mm > 0),
    length_mm INTEGER
        NOT NULL
        CHECK (length_mm > 0 ),
    height_mm INTEGER
        CHECK (height_mm > 0),
    size_letters VARCHAR(3)
        UNIQUE,
    is_standard BOOLEAN
        NOT NULL
        DEFAULT FALSE,
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
        REFERENCES ref.postal_objects
);

COMMENT ON TABLE app.dimensions
IS 'Габариты почтовых отправлений';


CREATE TABLE app.departures (
    id SERIAL
        PRIMARY KEY,
    type_id INTEGER
        NOT NULL
        REFERENCES ref.departure_types(id),
    dimension_id INTEGER
        NOT NULL
        REFERENCES app.dimensions(id),
    weight_g INTEGER
        NOT NULL
        CHECK (weight_g > 0),
    declared_value NUMERIC(10, 2),
    sender_id INTEGER
        NOT NULL
        REFERENCES app.clients(id),
    recipient_id INTEGER
        NOT NULL
        REFERENCES app.clients(id),
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
        REFERENCES ref.postal_objects
);

COMMENT ON TABLE app.departures
IS 'Почтовые отправления';


CREATE TABLE app.delivery (
    id SERIAL
        PRIMARY KEY,
    route_id INTEGER
        NOT NULL
        REFERENCES ref.routes(id),
    departure_method VARCHAR(20)
        NOT NULL
        CHECK (departure_method IN (
            'из отделения',
            'курьером'
        )),
    receiving_method VARCHAR(20)
        NOT NULL
        CHECK (receiving_method IN (
            'самовывоз',
            'курьером',
            'почтальоном'
        )),
    notes TEXT,
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
        REFERENCES ref.postal_objects
);

COMMENT ON TABLE app.delivery
IS 'Параметры пересылки и доставки';


CREATE TABLE app.orders (
    id SERIAL
        PRIMARY KEY,
    departure_id INTEGER
        NOT NULL
        UNIQUE
        REFERENCES app.departures(id),
    delivery_id INTEGER
        NOT NULL
        UNIQUE
        REFERENCES app.delivery(id),
    price NUMERIC(10, 2)
        NOT NULL,
    created_at TIMESTAMP
        NOT NULL
        DEFAULT NOW(),
    paid_at TIMESTAMP
        CHECK (
            paid_at IS NULL
            OR paid_at >= created_at
        ),
    closed_at TIMESTAMP
        CHECK (
            closed_at IS NULL
            OR closed_at >= paid_at
        ),
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
        REFERENCES ref.postal_objects
);

COMMENT ON TABLE app.orders
IS 'Заказ на оказание услуги по пересылке';


CREATE TABLE app.status_history (
    departure_id INTEGER
        NOT NULL
        REFERENCES app.departures(id)
            ON DELETE CASCADE,
    status_id INTEGER
        NOT NULL
        REFERENCES ref.statuses(id)
            ON DELETE CASCADE,
    date TIMESTAMP
        NOT NULL
        DEFAULT NOW(),
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
        REFERENCES ref.postal_objects
);

COMMENT ON TABLE app.status_history
IS 'История изменения статусов заказа';

RESET ROLE;
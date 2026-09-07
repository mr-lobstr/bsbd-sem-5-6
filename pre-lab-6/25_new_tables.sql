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
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('письмо', 'бандероль', 'посылка', 'другое')
    ),
    subtype VARCHAR(50),
    max_weight_grams INTEGER NOT NULL,
    description TEXT
);

COMMENT ON TABLE ref.departure_types
IS 'Типы почтовых отправлений';


CREATE TABLE ref.base_tariffs (
    id SERIAL PRIMARY KEY,
    departure_type_id INTEGER NOT NULL
        REFERENCES ref.departure_types(id) ON DELETE RESTRICT,
    route_id INTEGER NOT NULL
        REFERENCES ref.routes(id) ON DELETE RESTRICT,
    max_weight_grams INTEGER NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE ref.base_tariffs
IS 'Базовые тарифы';


CREATE TABLE ref.additional_weight_tariffs (
    id SERIAL PRIMARY KEY,
    departure_type_id INTEGER NOT NULL
        REFERENCES ref.departure_types(id) ON DELETE RESTRICT,
    route_id INTEGER NOT NULL
        REFERENCES ref.routes(id) ON DELETE RESTRICT,
    step_weight_grams INTEGER NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE ref.additional_weight_tariffs
IS 'Тарифы на добавочный вес';


CREATE TABLE app.dimensions (
    id SERIAL PRIMARY KEY,
    width_mm INTEGER NOT NULL,
    length_mm INTEGER NOT NULL,
    height_mm INTEGER,
    size_letters VARCHAR(3),
    is_standard BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE app.dimensions
IS 'Габариты почтовых отправлений';


CREATE TABLE app.departures (
    id SERIAL PRIMARY KEY,
    type_id INTEGER NOT NULL
        REFERENCES ref.departure_types(id),
    dimension_id INTEGER NOT NULL
        REFERENCES app.dimensions(id),
    weight_grams INTEGER NOT NULL,
    declared_value NUMERIC(10, 2),
    sender_id INTEGER NOT NULL
        REFERENCES app.clients(id) ON DELETE RESTRICT,
    recipient_id INTEGER NOT NULL
        REFERENCES app.clients(id) ON DELETE RESTRICT
);

COMMENT ON TABLE app.departures
IS 'Почтовые отправления';


CREATE TABLE app.delivery (
    id SERIAL PRIMARY KEY,
    route_id INTEGER NOT NULL
        REFERENCES ref.routes(id) ON DELETE RESTRICT,
    departure_method VARCHAR(20) NOT NULL CHECK (
        departure_method IN ('из отделения', 'курьером')
    ),
    receiving_method VARCHAR(20) NOT NULL CHECK (
        receiving_method IN ('самовывоз', 'курьером', 'почтальоном')
    ),
    delivery_notes TEXT
);

COMMENT ON TABLE app.delivery
IS 'Параметры пересылки и доставки';


CREATE TABLE app.orders (
    id SERIAL PRIMARY KEY,
    departure_id INTEGER NOT NULL UNIQUE
        REFERENCES app.departures(id),
    delivery_id INTEGER NOT NULL UNIQUE
        REFERENCES app.delivery(id),
    price NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMP
);

COMMENT ON TABLE app.orders
IS 'Заказ на оказание услуги по пересылке';


CREATE TABLE app.status_history (
    departure_id INTEGER NOT NULL
        REFERENCES app.departures(id) ON DELETE CASCADE,
    status_id INTEGER NOT NULL
        REFERENCES ref.statuses(id) ON DELETE CASCADE,
    date TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE app.status_history
IS 'История изменения статусов заказа';

RESET ROLE;
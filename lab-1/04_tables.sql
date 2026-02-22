SET ROLE ddl_admin;

CREATE TABLE ref.addresses (
    id SERIAL PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    locality VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL,
    house_number INTEGER NOT NULL,
    fraction INTEGER,
    building VARCHAR(10)
);

COMMENT ON TABLE ref.addresses IS 'Адреса зданий и построек';

CALL app.change_owner_to_app_owner('TABLE', 'ref.addresses');


CREATE TABLE ref.postal_objects (
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('склад', 'офис')
    ),
    address_id INTEGER NOT NULL
        REFERENCES addresses(id) ON DELETE RESTRICT,
    postal_code VARCHAR(6)
);

COMMENT ON TABLE ref.postal_objects IS 'Объекты почты: отделения, склады';

CALL app.change_owner_to_app_owner('TABLE', 'ref.postal_objects');


CREATE TABLE ref.statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE ref.routes (
    id SERIAL PRIMARY KEY,
    object_from_id INTEGER NOT NULL
        REFERENCES postal_objects(id) ON DELETE CASCADE,
    object_to_id INTEGER NOT NULL
        REFERENCES postal_objects(id) ON DELETE CASCADE,
    move_method VARCHAR(30) NOT NULL CHECK (
        move_method IN ('автотранспорт', 'воздушный транспорт', 'водный транспорт')
    )
);

COMMENT ON TABLE ref.routes IS 'Маршруты между объектами почты';

CALL app.change_owner_to_app_owner('TABLE', 'ref.routes');


CREATE TABLE app.client_addresses (
    id SERIAL PRIMARY KEY,
    address_id INTEGER NOT NULL
        REFERENCES addresses(id) ON DELETE RESTRICT,
    entrance INTEGER,
    flat INTEGER
);

COMMENT ON TABLE app.client_addresses IS 'Адреса клиентов';

CALL app.change_owner_to_app_owner('TABLE', 'app.client_addresses');


CREATE TABLE app.clients (
    id SERIAL PRIMARY KEY,
    surname VARCHAR(30) NOT NULL,
    name VARCHAR(30) NOT NULL,
    middle_name VARCHAR(30),
    client_address_id INTEGER NOT NULL
        REFERENCES client_addresses(id) ON DELETE RESTRICT,
    date_of_birth DATE,
    personal_phone VARCHAR(12)
);

COMMENT ON TABLE app.clients IS 'Данные клиентов';

CALL app.change_owner_to_app_owner('TABLE', 'app.clients');


CREATE TABLE app.packages (
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('письмо', 'бандероль', 'посылка')
    ),
    receiving_method VARCHAR(20) NOT NULL CHECK (
        receiving_method IN ('самовывоз', 'курьером')
    ),
    sender_id INTEGER NOT NULL
        REFERENCES clients(id) ON DELETE RESTRICT,
    recipient_id INTEGER NOT NULL
        REFERENCES clients(id) ON DELETE RESTRICT,
    office_from_id INTEGER NOT NULL
        REFERENCES postal_objects(id) ON DELETE RESTRICT,
    office_to_id INTEGER NOT NULL
        REFERENCES postal_objects(id) ON DELETE RESTRICT,
    departure_date TIMESTAMP NOT NULL,
    receipt_date TIMESTAMP
);

COMMENT ON TABLE app.packages IS 'Данные посылок';

CALL app.change_owner_to_app_owner('TABLE', 'app.packages');


CREATE TABLE app.status_history (
    id SERIAL PRIMARY KEY,
    package_id INTEGER NOT NULL REFERENCES
        packages(id) ON DELETE CASCADE,
    status_id INTEGER NOT NULL REFERENCES statuses(id)
        ON DELETE RESTRICT,
    date TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE app.status_history IS 'История изменения статуса посылок';

CALL app.change_owner_to_app_owner('TABLE', 'app.status_history');


CREATE TABLE app.movement_history (
    id SERIAL PRIMARY KEY,
    package_id INTEGER NOT NULL
        REFERENCES packages(id) ON DELETE CASCADE,
    route_id INTEGER NOT NULL
        REFERENCES routes(id) ON DELETE CASCADE,
    arrival_date TIMESTAMP NOT NULL
);

COMMENT ON TABLE app.movement_history IS 'История перемещения посылок';

CALL app.change_owner_to_app_owner('TABLE', 'app.movement_history');


CREATE TABLE stg.raw_addresses (
    id SERIAL PRIMARY KEY,
    raw_text TEXT NOT NULL,
    system VARCHAR(100) NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP,
    address_id INTEGER
        REFERENCES addresses(id) ON DELETE SET NULL,
    normalized BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT 
);

COMMENT ON TABLE stg.raw_addresses
IS 'Адреса из внешних источников, которые могут быть добавлены в ref.addresses';

CALL app.change_owner_to_app_owner('TABLE', 'stg.raw_addresses');


CREATE TABLE stg.raw_clients (
    id SERIAL PRIMARY KEY,
    raw_text TEXT NOT NULL,
    system VARCHAR(100) NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP,
    client_id INTEGER
        REFERENCES clients(id) ON DELETE SET NULL,
    normalized BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT
);

COMMENT ON TABLE stg.raw_clients
IS 'Данные клиентов из внешних источников, которые могут быть добавлены в app.clients';

CALL app.change_owner_to_app_owner('TABLE', 'stg.raw_clients');

RESET ROLE;
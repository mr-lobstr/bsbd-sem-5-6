CREATE EXTENSION IF NOT EXISTS pgcrypto;

SET ROLE postgres;

CREATE TABLE app.encrypted_clients (
    id INTEGER,
    surname VARCHAR(30)
        NOT NULL,
    name VARCHAR(30)
        NOT NULL,
    middle_name VARCHAR(30),
    client_address_id BYTEA
        NOT NULL,
    date_of_birth BYTEA,
    personal_phone BYTEA,
    mail BYTEA
);

COMMENT ON TABLE app.encrypted_clients
IS 'Зашифрованные данные клиентов';


INSERT INTO app.encrypted_clients (
    id,
    surname,
    name,
    middle_name,
    client_address_id,
    date_of_birth,
    personal_phone,
    mail
)
SELECT
    c.id,
    c.surname,
    c.name,
    c.middle_name,
    app.pgp_encrypt(c.client_address_id::TEXT),
    app.pgp_encrypt(c.date_of_birth::TEXT),
    app.pgp_encrypt(c.personal_phone::TEXT),
    app.pgp_encrypt(c.mail::TEXT)
FROM app.clients c;



RESET ROLE;
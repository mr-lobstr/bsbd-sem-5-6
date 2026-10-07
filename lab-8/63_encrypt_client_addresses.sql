CREATE EXTENSION IF NOT EXISTS pgcrypto;

SET ROLE postgres;

CREATE TABLE app.encrypted_client_addresses (
    id INTEGER,
    address_id BYTEA
        NOT NULL,
    flat BYTEA,
    floor BYTEA,
    entrance BYTEA,
    has_mailbox BOOLEAN
);

COMMENT ON TABLE app.encrypted_client_addresses
IS 'Зашифрованные данные адресов клиентов';


INSERT INTO app.encrypted_client_addresses (
    id,
    address_id,
    flat,
    floor,
    entrance,
    has_mailbox
)
SELECT
    ca.id,
    app.pgp_encrypt(ca.address_id::TEXT),
    app.pgp_encrypt(ca.flat::TEXT),
    app.pgp_encrypt(ca.floor::TEXT),
    app.pgp_encrypt(ca.entrance::TEXT),
    ca.has_mailbox
FROM app.client_addresses ca;



RESET ROLE;
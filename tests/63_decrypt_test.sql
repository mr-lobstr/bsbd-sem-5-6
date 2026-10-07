SELECT
    ec.id,
    ec.surname,
    ec.name,
    ec.middle_name,
    app.pgp_decrypt(ec.client_address_id, 'passphrase'),
    app.pgp_decrypt(ec.date_of_birth, 'passphrase'),
    app.pgp_decrypt(ec.personal_phone, 'passphrase'),
    app.pgp_decrypt(ec.mail, 'passphrase')
FROM app.encrypted_clients ec
LIMIT 10;
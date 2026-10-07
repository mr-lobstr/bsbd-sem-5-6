SET ROLE postgres;

CREATE FUNCTION app.pgp_encrypt(TEXT)
RETURNS BYTEA
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN pgp_pub_encrypt(
        $1,
        pg_read_binary_file('./pgp_keys/public.key')
    );
END;
$$;


CREATE FUNCTION app.pgp_decrypt(BYTEA, passphrase TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN pgp_pub_decrypt(
        $1,
        pg_read_binary_file('./pgp_keys/private.key'),
        passphrase
    );
END;
$$;

RESET ROLE;
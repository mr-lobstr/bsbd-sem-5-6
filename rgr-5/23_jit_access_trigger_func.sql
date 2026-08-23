SET ROLE postgres;

CREATE TABLE audit.temp_access_log (
    id SERIAL PRIMARY KEY,
    request_time TIMESTAMP NOT NULL DEFAULT NOW(),
    caller_role VARCHAR(30) NOT NULL,
    expiries_at TIMESTAMP
);


CREATE PROCEDURE app.check_jit_access_impl(
    role_name TEXT,
    table_oid_ OID,
    operation_ TEXT
)
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
    DECLARE exp_at TIMESTAMP;
BEGIN
    SELECT expires_at
    INTO exp_at
    FROM temp_privileges tp
    WHERE tp.role_ = role_name
        AND tp.table_oid = table_oid_
        AND tp.operation = operation_;

    IF exp_at IS NULL OR exp_at < NOW() THEN
        RAISE EXCEPTION 'Привилегия не назначена или более не действует';
    END IF;

    INSERT INTO audit.temp_access_log (
        caller_role,
        expiries_at
    )
    VALUES (role_name, exp_at);
END;
$$;


CREATE FUNCTION app.check_jit_access()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    CALL app.check_jit_access_impl(
        current_user,
        TG_RELID,
        TG_OP
    );
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION '%s', SQLERRM;
END;
$$;

RESET ROLE;
SET ROLE postgres;

CREATE FUNCTION app.temp_privileges_create()
RETURNS event_trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE temp_privileges(
        role_ VARCHAR(63),
        table_oid OID,
        operation VARCHAR(20),
        expires_at TIMESTAMP
    );
END;
$$;

CREATE EVENT TRIGGER temp_privileges_create_trigger
ON LOGIN
EXECUTE FUNCTION app.temp_privileges_create();


CREATE PROCEDURE app.request_temp_privilege(
    role_name TEXT,
    table_name TEXT,
    operation_ TEXT,
    duration_min INT
)
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM temp_privileges tp
    WHERE tp.role_ = role_name
        AND tp.table_oid = table_name::regclass::oid
        AND tp.operation = operation_;

    INSERT INTO temp_privileges
    VALUES (
        role_name,
        table_name::regclass::oid,
        operation_,
        NOW() + (INTERVAL '1 minute' * duration_min)
    );
END;
$$;
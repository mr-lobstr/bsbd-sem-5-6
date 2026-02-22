SET ROLE postgres;

CREATE OR REPLACE PROCEDURE app.change_owner_to_app_owner(
    object_type VARCHAR(50),
    object_name VARCHAR(200)
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app, ref, stg
AS $$
BEGIN
    BEGIN
        EXECUTE format(
            'ALTER %s %s OWNER TO app_owner',
            object_type,
            object_name
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION
            'Не удалось сменить владельца объекта % % на app_owner, ошибка: %',
            object_type,
            object_name,
            SQLERRM;
    END;
END;
$$;

COMMENT ON PROCEDURE app.change_owner_to_app_owner
IS 'Меняет владельца объекта на app_owner';

GRANT EXECUTE
    ON PROCEDURE app.change_owner_to_app_owner TO ddl_admin;

RESET ROLE;
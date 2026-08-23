BEGIN;

CREATE FUNCTION pg_temp.print(INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
COST 0.000001
AS $$
BEGIN
    RAISE NOTICE 'address id: %', $1;
    RETURN TRUE;
END;
$$;


DO $$
    DECLARE result RECORD;
    DECLARE plan JSON;
	updated_count INTEGER;
BEGIN
    SET ROLE app_writer;

    PERFORM app.set_session_ctx(1, 1);

    RAISE NOTICE E'Попытка обойти WITH CHECK OPTION:';

    BEGIN
        INSERT INTO app.client_addresses_for_postal_delivery (
            address_id,
            flat,
            entrance,
            has_mailbox
        ) VALUES (
            10,
            1,
            1,
            false
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE
            E'Ошибка при вставке в app.client_addresses_for_postal_delivery: %\n', SQLERRM;
    END;

    RAISE NOTICE E'Попытка обойти SECURITY BARIER:';

    INSERT INTO app.status_history(
        package_id,
        status_id,
        date
    ) VALUES
        (1, 2, NOW()),
        (1, 3, NOW() + '1 day'),
        (1, 4, NOW() + '2 day'),
        (1, 5, NOW() + '3 day');

    SELECT *
    INTO result
    FROM app.current_status_count
    WHERE pg_temp.print(status_id);

    RAISE NOTICE '%\n', result;
    RAISE NOTICE E'Попытка удалить строку не из своего сегмента:';

    DELETE FROM app.packages
    WHERE segment_id = 7;
    GET DIAGNOSTICS updated_count = ROW_COUNT;

    RAISE NOTICE E'Строк удалено: %', updated_count;
END;
$$;

ROLLBACK;

BEGIN;

DO $$
    DECLARE result RECORD;
BEGIN
    SET ROLE app_writer;

    PERFORM app.set_session_ctx(1, 1);

    RAISE NOTICE E'Попытка обойти WITH CHECK OPTION: \n';

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


    RAISE NOTICE E'Попытка обойти SECURITY BARIER: \n';

    SELECT *
    INTO result
    FROM app.parcels_dimensions_stats
    WHERE avg_weight > 100
        AND avg_length > 0.2;
        

    BEGIN
        RAISE NOTICE E'История изменений в таблице app.clients: \n';

        INSERT INTO app.clients (
            surname,
            name,
            mail,
            personal_phone
        ) VALUES (
            'test surname',
            'test name',
            'testmail@test.com',
            '+0123456789'
        ), (
            'test surname 2',
            'test name',
            'testmail2@test.com',
            '+0987654321'
        );

        UPDATE app.clients
        SET name = 'new test name'
        WHERE name = 'test name';

        DELETE FROM app.clients
        WHERE name = 'new test name';

        SET ROLE auditor;

        SELECT *
        INTO result
        FROM audit.row_change_log;

        RAISE NOTICE E'Содержимое таблицы audit.row_change_log: %\n', to_jsonb(result);

        RESET ROLE;


        RAISE NOTICE E'Вызов audit.backup_audit_logs(1 день): \n';
        CALL audit.backup_audit_logs(1);

        SELECT *
        INTO result
        FROM audit.row_change_log;

        RAISE NOTICE E'Содержимое таблицы audit.row_change_log: %\n', to_jsonb(result);

        SELECT *
        INTO result
        FROM audit.row_change_log_archive;

        RAISE NOTICE E'Содержимое таблицы audit.row_change_log_archive: %\n', to_jsonb(result);


        RAISE NOTICE E'Вызов audit.backup_audit_logs(0 дней): \n';
        CALL audit.backup_audit_logs(0);

        SELECT *
        INTO result
        FROM audit.row_change_log;

        RAISE NOTICE E'Содержимое таблицы audit.row_change_log: %\n', to_jsonb(result);

        SELECT *
        INTO result
        FROM audit.row_change_log_archive;

        RAISE NOTICE E'Содержимое таблицы audit.row_change_log_archive: %\n', to_jsonb(result);
    END;
END;
$$;

ROLLBACK;
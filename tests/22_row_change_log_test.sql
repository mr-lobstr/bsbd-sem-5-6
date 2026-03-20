BEGIN;

DO $$
    DECLARE result RECORD;
BEGIN
    PERFORM app.set_session_ctx(1, 1);

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
$$;

ROLLBACK;

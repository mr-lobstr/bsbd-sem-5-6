SET ROLE postgres;

CREATE OR REPLACE PROCEDURE pg_temp.rights_test()
LANGUAGE plpgsql
AS $$
	DECLARE rec RECORD;
BEGIN
	RAISE NOTICE 'Текущая роль: %', current_role;

    BEGIN
        CREATE TABLE app.tmp_test(id INTEGER);
        DROP TABLE app.tmp_test;
        
        RAISE NOTICE 'Успешное выполнение DDL операций';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при выполнении DDL операций: %', SQLERRM;
    END;

    BEGIN
        SELECT username 
		INTO rec
		FROM audit.login_log;
        
        RAISE NOTICE 'Успешное чтение из audit.login_log';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при чтении из audit.login_log: %', SQLERRM;
    END;

    BEGIN
        SELECT name
		INTO rec
		FROM ref.statuses;
        
        RAISE NOTICE 'Успешное выполнение SELECT';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при выполнении SELECT: %', SQLERRM;
    END;

    BEGIN
        INSERT INTO ref.statuses (name)
        VALUES ('test status');
        
        RAISE NOTICE 'Успешное выполнение INSERT';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при выполнении INSERT: %', SQLERRM;
    END;

    BEGIN
        UPDATE ref.statuses
        SET name = 'new test status'
        WHERE name = 'test status';

        RAISE NOTICE 'Успешное выполнение UPDATE';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при выполнении UPDATE: %', SQLERRM;
    END;
    
    BEGIN
        DELETE FROM ref.statuses
        WHERE name = 'new test status';

        RAISE NOTICE 'Успешное выполнение DELETE';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при выполнении DELETE: %', SQLERRM;
    END;

    RAISE NOTICE '';
END;
$$;

BEGIN;
    SET ROLE app_owner;
    CALL pg_temp.rights_test();

    SET ROLE ddl_admin;
    CALL pg_temp.rights_test();

    SET ROLE dml_admin;
    CALL pg_temp.rights_test();

    SET ROLE security_admin;
    CALL pg_temp.rights_test();

    SET ROLE app_writer;
    CALL pg_temp.rights_test();

    SET ROLE app_reader;
    CALL pg_temp.rights_test();

    SET ROLE auditor;
    CALL pg_temp.rights_test();

    RESET ROLE;
ROLLBACK;
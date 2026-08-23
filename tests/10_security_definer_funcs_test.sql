SET ROLE postgres;

CREATE OR REPLACE PROCEDURE pg_temp.security_definer_funcs_test()
LANGUAGE plpgsql
AS $$
DECLARE
    res JSONB;
BEGIN
    RAISE NOTICE 'Тестирование ref.create_address_from_raw';

    SELECT * INTO res
    FROM ref.create_address_from_raw(1, 'Московская область', 'Химки', NULL, 5);

    RAISE NOTICE 'Вызовы с некорректными данными данными:';
    RAISE NOTICE '%', res;

    SELECT * INTO res
	FROM ref.create_address_from_raw(11, 'Московская область', 'Химки', 'Ленинградская', 5);
   	RAISE NOTICE '%', res;

    SELECT * INTO res
	FROM ref.create_address_from_raw(10, 'Московская область', 'Химки', 'Ленинградская', 5);
    RAISE NOTICE '%', res;

	SELECT * INTO res
	FROM ref.create_address_from_raw(1, 'Московская область', 'Химки', 'Ленинградская', 5);

	RAISE NOTICE 'Успешный вызов:';
    RAISE NOTICE '%', res;
    RAISE NOTICE '';


    RAISE NOTICE 'Тестирование app.create_client_from_raw';
    RAISE NOTICE 'Вызовы с некорректными данными данными:';

    SELECT * INTO res
    FROM app.create_client_from_raw(NULL, 'Иванов', 'Иван', 'Иванович', 10, '1980-05-15', '+79991234567');
    RAISE NOTICE '%', res;

    SELECT * INTO res
    FROM app.create_client_from_raw(20, 'Иванов', 'Иван', 'Иванович', 10, '1980-05-15', '+79991234567');
    RAISE NOTICE '%', res;

    SELECT * INTO res
    FROM app.create_client_from_raw(10, 'Иванов', 'Иван', 'Иванович', 10, '1980-05-15', '+79991234567');
    RAISE NOTICE '%', res;

	SELECT * INTO res
    FROM app.create_client_from_raw(1, 'Иванов', 'Иван', 'Иванович', 20, '1980-05-15', '+79991234567');
    RAISE NOTICE '%', res;

	SELECT * INTO res
    FROM app.create_client_from_raw(1, 'Иванов', 'Иван', 'Иванович', 10, '1980-05-15', '+79991234567');

	RAISE NOTICE 'Успешный вызов:';
    RAISE NOTICE '%', res;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$;


BEGIN;
    SET ROLE app_writer;
    CALL pg_temp.security_definer_funcs_test();
    RESET ROLE;
ROLLBACK;
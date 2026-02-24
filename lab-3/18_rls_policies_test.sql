BEGIN;

DO $$
	DECLARE success BOOLEAN;
		updated_count INTEGER;
BEGIN
	SET ROLE app_owner;
	RAISE NOTICE 'Тестирование set_session_ctx:';
	
	SELECT app.set_session_ctx(1, 1) INTO success;
	RAISE NOTICE 'Сегмент принадлежит рользователю. Вызов set_session_ctx: %', success;

	SELECT app.set_session_ctx(1, 2) INTO success;
	RAISE NOTICE 'Сегмент не принадлежит рользователю. Вызов set_session_ctx: %', success;
	
	RAISE NOTICE '';
	RAISE NOTICE 'Вставка/обновление с неверным segment_id:';

	SET ROLE app_writer;
	SELECT app.set_session_ctx(1, 3) INTO success;
	
	BEGIN
		INSERT INTO app.client_addresses (
    		address_id,
    		entrance,
	    	flat
		) VALUES (
    		10,
    		2,
    		3
		);

		RAISE NOTICE 'Успешная вставка с неверным segment_id';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Ошибка при вставке с неверным segment_id: %', SQLERRM;
	END;

	UPDATE app.client_addresses
	SET flat = 10
	WHERE id = 7;
	GET DIAGNOSTICS updated_count = ROW_COUNT;

	RAISE NOTICE 'Обновление с неверным segment_id. Обновлено строк: %', updated_count;

	RAISE NOTICE '';
	RAISE NOTICE 'Действия с верным segment_id:';

	SELECT app.set_session_ctx(3, 3) INTO success;

	BEGIN
		UPDATE app.client_addresses
		SET segment_id = 5;

		RAISE NOTICE 'Успешная ручное обновление segment_id';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Ошибка при ручном обновлении segment_id: %', SQLERRM;
	END;

	BEGIN
		INSERT INTO app.client_addresses (
    		address_id,
    		entrance,
	    	flat
		) VALUES (
    		10,
    		2,
    		300
		);

		RAISE NOTICE 'Успешная вставка с верным segment_id';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Ошибка при вставке с верным segment_id: %', SQLERRM;
	END;

	UPDATE app.client_addresses
	SET flat = 100
	WHERE flat = 300;
	GET DIAGNOSTICS updated_count = ROW_COUNT;

	RAISE NOTICE 'Обновление с верным segment_id. Обновлено строк: %', updated_count;

	DELETE FROM app.client_addresses
	WHERE flat = 100;
	GET DIAGNOSTICS updated_count = ROW_COUNT;

	RAISE NOTICE 'Удаление с верным segment_id. Удалено строк: %', updated_count;

	RAISE NOTICE '';
	RAISE NOTICE 'Тестирование политик для auditor:';

	SET ROLE app_reader;
	SELECT app.set_session_ctx(3, 3) INTO success;

	SELECT COUNT(*)
	INTO updated_count
	FROM app.client_addresses;

	RAISE NOTICE 'Роль app_reader. Прочитано строк: %', updated_count;

	SET ROLE auditor;

	SELECT COUNT(*)
	INTO updated_count
	FROM app.client_addresses;

	RAISE NOTICE 'Роль auditor. Прочитано строк: %', updated_count;
END;
$$;

ROLLBACK;
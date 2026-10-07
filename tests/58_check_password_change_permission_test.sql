BEGIN;

CREATE PROCEDURE app.employees_credentials_update()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE app.employees_credentials ec
    SET password_hash = md5(RANDOM()::TEXT)
    WHERE ec.id = 2;

    RAISE NOTICE 'Пароль успешно обновлён';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Не удалось обновить пароль: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    RAISE NOTICE 'Разрешение не получено';
    CALL app.employees_credentials_update();

	CALL app.password_change_request(2);

    RAISE NOTICE 'Запрос на изменение не одобрен';
    CALL app.employees_credentials_update();

	CALL app.password_change_approve(2, 1, NOW()::TIMESTAMP + '5 minutes');

    RAISE NOTICE 'Запрос одобрен';
    CALL app.employees_credentials_update();

    RAISE NOTICE 'Повторное изменение по тому же запросу';
    CALL app.employees_credentials_update();
END;
$$;

ROLLBACK;
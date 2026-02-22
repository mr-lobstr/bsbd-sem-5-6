SET ROLE app_owner;

CREATE TABLE audit.login_log (
    id SERIAL PRIMARY KEY,
    login_time TIMESTAMP NOT NULL DEFAULT NOW(),
    username VARCHAR(50) NOT NULL DEFAULT session_user,
    client_ip VARCHAR(45)
);

COMMENT ON TABLE stg.raw_clients IS 'История подключений пользователей';


CREATE OR REPLACE FUNCTION audit.login_log_trg()
RETURNS event_trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = audit
AS $$
BEGIN
    INSERT INTO audit.login_log (client_ip) VALUES (inet_client_addr());    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'При попытке % подключиться произошла ошибка: %', session_user, SQLERRM;
END;
$$;

CREATE EVENT TRIGGER login_log_trigger
ON login
EXECUTE FUNCTION audit.login_log_trg();

COMMENT ON TABLE EVENT TRIGGER login_log_trigger
IS 'Автоматически создает запись в audit.login_log при подключении пользователя';

RESET ROLE;
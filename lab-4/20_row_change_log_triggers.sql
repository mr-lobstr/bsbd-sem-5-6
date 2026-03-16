ALTER DATABASE postal_db
SET session_preload_libraries = 'anon';

CREATE EXTENSION anon CASCADE;
SELECT anon.init();


SET ROLE app_owner;

CREATE TABLE audit.row_change_log (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL DEFAULT session_user,
    table_name VARCHAR(50) NOT NULL,
    change_timestamp  TIMESTAMP NOT NULL DEFAULT NOW(),
    old_data JSONB,
    new_data JSONB
);

COMMENT ON TABLE audit.row_change_log
IS 'История изменения строк в ключевых таблицах';


CREATE OR REPLACE FUNCTION audit.client_addresses_row_change_log_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
    DECLARE old_data_ JSONB := NULL;
        new_data_ JSONB := NULL;
BEGIN
    IF TG_OP <> 'INSERT' THEN
        old_data_ := jsonb_build_object(
            'id', OLD.id,
            'address_id', OLD.address_id,
            'flat', anon.hash(OLD.flat::TEXT),
            'floor', OLD.floor,
            'entrance', OLD.entrance,
            'has_mailbox', OLD.has_mailbox,
            'intercom_code', anon.hash(OLD.intercom_code::TEXT),
            'delivery_notes', anon.hash(OLD.delivery_notes)
        );
    END IF;

    IF TG_OP <> 'DELETE' THEN
        new_data_ := jsonb_build_object(
            'id', NEW.id,
            'address_id', NEW.address_id,
            'flat', anon.hash(NEW.flat::TEXT),
            'floor', NEW.floor,
            'entrance', NEW.entrance,
            'has_mailbox', NEW.has_mailbox,
            'intercom_code', anon.hash(NEW.intercom_code::TEXT),
            'delivery_notes', anon.hash(NEW.delivery_notes)
        );
    END IF;


    INSERT INTO audit.row_change_log(
        username,
        table_name,
        old_data,
        new_data
    ) VALUES (
        session_user,
        'app.client_addresses',
        old_data_,
        new_data_
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER client_addresses_row_insert_log_trigger
AFTER INSERT ON app.client_addresses
FOR EACH ROW
EXECUTE FUNCTION audit.client_addresses_row_change_log_trg(); 

CREATE TRIGGER client_addresses_row_update_log_trigger
AFTER UPDATE ON app.client_addresses
FOR EACH ROW
EXECUTE FUNCTION audit.client_addresses_row_change_log_trg(); 

CREATE TRIGGER client_addresses_row_delete_log_trigger
AFTER DELETE ON app.client_addresses
FOR EACH ROW
EXECUTE FUNCTION audit.client_addresses_row_change_log_trg();


CREATE OR REPLACE FUNCTION audit.clients_row_change_log_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = audit, app
AS $$
    DECLARE old_data_ JSONB := NULL;
        new_data_ JSONB := NULL;
BEGIN
    IF TG_OP <> 'INSERT' THEN
        old_data_ := jsonb_build_object(
            'id', OLD.id,
            'surname', OLD.surname,
            'name', OLD.name,
            'middle_name', OLD.middle_name,
            'client_address_id', OLD.client_address_id,
            'date_of_birth', anon.generalize_daterange(OLD.date_of_birth, 'year'),
            'personal_phone', anon.partial(OLD.personal_phone, 2, '****', 2),
            'mail', anon.partial_email(OLD.mail)
        );
    END IF;

    IF TG_OP <> 'DELETE' THEN
        new_data_ := jsonb_build_object(
            'id', NEW.id,
            'surname', NEW.surname,
            'name', NEW.name,
            'middle_name', NEW.middle_name,
            'client_address_id', NEW.client_address_id,
            'date_of_birth', anon.generalize_daterange(NEW.date_of_birth, 'year'),
            'personal_phone', anon.partial(NEW.personal_phone, 2, '****', 2),
            'mail', anon.partial_email(NEW.mail)
        );
    END IF;


    INSERT INTO audit.row_change_log(
        username,
        table_name,
        old_data,
        new_data
    ) VALUES (
        session_user,
        'app.clients',
        old_data_,
        new_data_
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER clients_row_insert_log_trigger
AFTER INSERT ON app.clients
FOR EACH ROW
EXECUTE FUNCTION audit.clients_row_change_log_trg(); 

CREATE TRIGGER clients_row_update_log_trigger
AFTER UPDATE ON app.clients
FOR EACH ROW
EXECUTE FUNCTION audit.clients_row_change_log_trg(); 

CREATE TRIGGER clients_row_delete_log_trigger
AFTER DELETE ON app.clients
FOR EACH ROW
EXECUTE FUNCTION audit.clients_row_change_log_trg(); 

RESET ROLE;

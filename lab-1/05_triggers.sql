SET ROLE app_owner;

CREATE OR REPLACE FUNCTION app.check_package_dates()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.receipt_date IS NOT NULL AND NEW.receipt_date < NEW.departure_date
    THEN
        RAISE EXCEPTION
            'Дата обработки не может следовать раньше даты получения (таблица: app.packages, id: %)',
            NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_package_dates_insert_trigger
BEFORE INSERT ON app.packages
FOR EACH ROW
EXECUTE FUNCTION app.check_package_dates();

CREATE TRIGGER check_package_dates_update_trigger
BEFORE UPDATE ON app.packages
FOR EACH ROW
WHEN (
    OLD.receipt_date IS DISTINCT FROM NEW.receipt_date
    OR OLD.departure_date IS DISTINCT FROM NEW.departure_date
)
EXECUTE FUNCTION app.check_package_dates();


CREATE OR REPLACE FUNCTION ref.check_postal_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.postal_code IS NULL OR NEW.postal_code = ''
    THEN
        RAISE EXCEPTION
            'Объект типа "офис" должен иметь почтовый индекс (таблица: ref.postal_objects, id: %)',
            NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_postal_code_insert_trigger
BEFORE INSERT ON ref.postal_objects
FOR EACH ROW
WHEN (NEW.type = 'офис')
EXECUTE FUNCTION ref.check_postal_code();

CREATE TRIGGER check_postal_code_update_trigger
BEFORE UPDATE ON ref.postal_objects
FOR EACH ROW
WHEN (NEW.type = 'офис')
EXECUTE FUNCTION ref.check_postal_code();


CREATE OR REPLACE FUNCTION stg.check_raw_address_dates()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.processed_at IS NOT NULL AND NEW.processed_at < NEW.received_at
    THEN
        RAISE EXCEPTION
            'Дата обработки не может следовать раньше даты получения (таблица: stg.raw_addresses, id: %)',
            NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_raw_address_dates_insert
BEFORE INSERT ON stg.raw_addresses
FOR EACH ROW
EXECUTE FUNCTION stg.check_raw_address_dates();

CREATE TRIGGER trg_check_raw_address_dates_update
BEFORE UPDATE ON stg.raw_addresses
FOR EACH ROW
WHEN (
    OLD.processed_at IS DISTINCT FROM NEW.processed_at
    OR OLD.received_at IS DISTINCT FROM NEW.received_at
)
EXECUTE FUNCTION stg.check_raw_address_dates();



CREATE OR REPLACE FUNCTION stg.check_raw_client_dates()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.processed_at IS NOT NULL AND NEW.processed_at < NEW.received_at
    THEN
        RAISE EXCEPTION
            'Дата обработки не может следовать раньше даты получения (таблица: stg.raw_clients, id: %)',
            NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_raw_client_dates_insert_trigger
BEFORE INSERT ON stg.raw_clients
FOR EACH ROW
EXECUTE FUNCTION stg.check_raw_client_dates();

CREATE TRIGGER check_raw_client_dates_update_trigger
BEFORE UPDATE ON stg.raw_clients
FOR EACH ROW
WHEN (
    OLD.processed_at IS DISTINCT FROM NEW.processed_at
    OR OLD.received_at IS DISTINCT FROM NEW.received_at
)
EXECUTE FUNCTION stg.check_raw_client_dates();

RESET ROLE;
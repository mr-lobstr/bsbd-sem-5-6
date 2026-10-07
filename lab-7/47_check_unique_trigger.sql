SET ROLE app_owner;

CREATE FUNCTION app.check_unique_departure_type()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ref.departure_types dt
        WHERE dt.type = NEW.type
            AND dt.subtype = NEW.subtype
            OR (dt.subtype IS NULL AND NEW.subtype IS NULL)
    ) THEN
        RAISE EXCEPTION
            'Тип отправления "%" ("%") уже существует',
            NEW.type,
            NEW.subtype;
    END IF;

    RETURN NEW;
END;
$$;


CREATE TRIGGER check_unique_departure_type_trg
BEFORE INSERT
    OR UPDATE
ON ref.departure_types
FOR EACH ROW
EXECUTE FUNCTION app.check_unique_departure_type();

RESET ROLE;
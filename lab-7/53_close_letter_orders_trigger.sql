SET ROLE postgres;

CREATE FUNCTION app.close_letter_orders()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.paid_at IS NULL
    THEN
        RETURN NEW;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM app.orders o
        JOIN app.departures d
            ON d.id = o.departure_id
        JOIN ref.departure_types dt
            ON dt.id = d.type_id
        WHERE dt.type = 'письмо'
            AND dt.subtype IS NULL
    ) THEN
        NEW.closed_at = NEW.paid_at;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER close_letter_orders_before_insert_trg
BEFORE INSERT
ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.close_letter_orders();

CREATE TRIGGER close_letter_orders_before_update_trg
BEFORE UPDATE
OF paid_at ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.close_letter_orders();

RESET ROLE;
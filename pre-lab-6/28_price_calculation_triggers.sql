SET ROLE app_owner;

CREATE FUNCTION app.price_calculation_for_orders()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.price = app.price_calculation(NEW.departure_id, NEW.delivery_id);
    RETURN NEW;
END;
$$;

CREATE TRIGGER price_calculation_for_orders_trg
BEFORE INSERT ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.price_calculation_for_orders();

RESET ROLE;
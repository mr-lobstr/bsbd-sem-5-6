SET ROLE app_owner;

CREATE OR REPLACE FUNCTION app.price_calc_for_orders()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.price = app.price_calc_with_discounts(NEW.departure_id, NEW.delivery_id);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER price_calc_for_orders_trg
BEFORE INSERT ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.price_calc_for_orders();

RESET ROLE;
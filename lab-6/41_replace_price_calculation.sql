SET ROLE app_owner;

CREATE OR REPLACE FUNCTION app.price_calculation_for_orders()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE
        discount REAL;
        full_price NUMERIC(10, 2);
BEGIN
    full_price := app.price_calculation(NEW.departure_id, NEW.delivery_id);
    discount := app.discounts_calculation_for_departure(NEW.departure_id);
    NEW.price = full_price * (1 - discount);
    RETURN NEW;
END;
$$;

RESET ROLE;
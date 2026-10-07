BEGIN;

SELECT *
FROM ref.tariffs t
WHERE t.departure_type_id = 1
	AND t.route_id = 1;

CREATE FUNCTION app.print_change_orders()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
	DECLARE r RECORD;
BEGIN
	SELECT *
	INTO r
	FROM app.orders o
	JOIN app.departures dp
		ON dp.id = o.departure_id
	JOIN app.delivery d
		ON d.id = o.delivery_id
	WHERE o.id = OLD.id;
	
	RAISE NOTICE 'OLD: % % % % %',
		OLD.id,
		r.type_id,
		r.route_id,
		r.weight_g,
		OLD.price;

	RAISE NOTICE 'NEW: % % % % %',
		NEW.id,
		r.type_id,
		r.route_id,
		r.weight_g,
		NEW.price;
		
	RETURN NEW;
END;
$$;

CREATE TRIGGER print_change_orders_trg
AFTER UPDATE
ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.print_change_orders();

UPDATE ref.tariffs t
SET price_2 = 913
WHERE t.id = 1;

ROLLBACK;
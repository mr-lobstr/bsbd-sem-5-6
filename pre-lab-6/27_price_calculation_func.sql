SET ROLE app_owner;

CREATE FUNCTION app.price_calculation(_departure_id INTEGER, _delivery_id INTEGER)
RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
    DECLARE
        departure RECORD;
        route_id_ INTEGER;

        price NUMERIC(10, 2);
        base_weight INTEGER;
        
        additional_wieght INTEGER;
        additional_price NUMERIC(10, 2);
        step_weight INTEGER;
BEGIN
    SELECT *
    INTO departure
    FROM app.departures d
    WHERE d.id = _departure_id;

    SELECT dp.route_id
    INTO route_id_
    FROM app.delivery dp
    WHERE dp.id = _delivery_id; 

    SELECT bt.price
    INTO price
    FROM ref.base_tariffs bt
    WHERE bt.departure_type_id = departure.type_id
        AND bt.route_id = route_id_
        AND bt.max_weight_grams >= departure.weight_grams
    ORDER BY bt.max_weight_grams ASC
    LIMIT 1;

    IF NOT price IS NULL THEN
        RETURN price;
    END IF;

    SELECT bt.price, bt.max_weight_grams
    INTO price, base_weight
    FROM ref.base_tariffs bt
    WHERE bt.departure_type_id = departure.type_id
        AND bt.route_id = route_id_
    ORDER BY bt.max_weight_grams DESC
    LIMIT 1;

    RAISE NOTICE '%', price;

    additional_wieght := departure.weight_grams - base_weight;

    SELECT awt.step_weight_grams, awt.price
    INTO step_weight, additional_price
    FROM ref.additional_weight_tariffs awt
    WHERE awt.departure_type_id = departure.type_id
        AND awt.route_id = route_id_;

    RETURN price + (additional_wieght / step_weight + 1)::INTEGER * additional_price;
END;
$$;

RESET ROLE;
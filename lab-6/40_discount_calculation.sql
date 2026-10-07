SET ROLE app_owner;

CREATE FUNCTION app.discounts_calc(departure_id INTEGER)
RETURNS REAL
LANGUAGE plpgsql
AS $$
    DECLARE
        client_id_ INTEGER;

        temporary REAL;
        personal REAL;
        for_unpopular_product REAL;
BEGIN
    SELECT d.sender_id
    INTO client_id_
    FROM app.departures d
    WHERE d.id = departure_id;

    SELECT tpd.discount
    INTO temporary
    FROM app.departures d
    JOIN app.temporary_personal_discount tpd
        ON tpd.client_id = client_id_
        AND tpd.departure_type_id = d.type_id
    WHERE d.id = departure_id
        AND NOW() <= valid_until;

    IF temporary IS NULL THEN
        temporary := 0;
    END IF;

    SELECT cl.discount
    INTO personal
    FROM app.clients c
    JOIN ref.client_levels cl ON cl.id = c.level_id
    WHERE c.id = client_id_;

    IF personal IS NULL THEN
        personal := 0;
    END IF;

    SELECT dp.discount
    INTO for_unpopular_product
    FROM app.departures d
    JOIN app.discounts_for_unpopular_products dp
        ON dp.departure_type_id = d.type_id
    WHERE d.id = departure_id
        AND NOW() <= valid_until;

    IF for_unpopular_product IS NULL THEN
        for_unpopular_product := 0;
    END IF;

    RETURN 1 - (1 - temporary)
        * (1 - personal)
        * (1 - for_unpopular_product);
END;
$$;


CREATE FUNCTION app.price_calc_with_discounts(_departure_id INTEGER, _delivery_id INTEGER)
RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
    DECLARE
        discount REAL;
        full_price NUMERIC(10, 2);
BEGIN
    full_price := app.price_calc(_departure_id, _delivery_id);
    discount := app.discounts_calc(_departure_id);
    RETURN full_price * (1 - discount);
END;
$$;

RESET ROLE;
SET ROLE app_owner;

CREATE FUNCTION app.discounts_calculation_for_departure(departure_id INTEGER)
RETURNS REAL
LANGUAGE plpgsql
AS $$
    DECLARE
        client_id INTEGER;

        temporary REAL;
        personal REAL;
        for_unpopular_product REAL;
BEGIN
    SELECT d.sender_id
    INTO client_id
    FROM app.departures d
    WHERE d.id = departure_id;

    SELECT tpd.discount
    INTO temporary
    FROM app.departures d
    JOIN app.temporary_personal_discount tpd
        ON tpd.client_id = client_id
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
    WHERE c.id = client_id;

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

RESET ROLE;
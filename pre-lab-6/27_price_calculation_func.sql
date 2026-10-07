SET ROLE app_owner;


CREATE FUNCTION app.price_calc(
    _departure_id INTEGER,
    _delivery_id INTEGER
)
RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
    DECLARE
        r RECORD;
        additional_weight INTEGER;
        weight_steps NUMERIC(10, 2);
BEGIN
    SELECT
        t.*,
        dp.*
    INTO r
    FROM ref.tariffs t
    JOIN app.departures dp
        ON dp.id = _departure_id
    JOIN app.delivery d
        ON d.id = _delivery_id
    WHERE t.departure_type_id = dp.type_id
        AND t.route_id = d.route_id;

    IF r IS NULL
    THEN
        RAISE EXCEPTION 'Тариф для отправления (id=%) не найден', _departure_id;
    END IF;

    IF r.weight_g <= r.weight_limit_1_g
    THEN
        RETURN r.price_1;
    END IF;

    IF r.weight_g <= r.weight_limit_2_g
    THEN
        RETURN r.price_2;
    END IF;

    additional_weight := r.weight_g - r.weight_limit_2_g;
    weight_steps := (additional_weight / r.additional_weight_g)::INTEGER + 1;

    RETURN r.price_2 + weight_steps * r.price_3;
END;
$$;

RESET ROLE;
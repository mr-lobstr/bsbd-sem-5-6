INSERT INTO ref.tariffs (
    departure_type_id,
    route_id,
    weight_limit_1_g,
    price_1,
    weight_limit_2_g,
    price_2,
    additional_weight_g,
    price_3
) SELECT
	dt.id,
	r.id,
    CASE
        WHEN dt.type = 'письмо' THEN 20
        ELSE 500
    END,
	26 * dt.id + 17 * RANDOM(),
    CASE
        WHEN dt.type = 'письмо' THEN 90
        ELSE 1000
    END,
	26 * dt.id + 9 * RANDOM() + 17,
    CASE
        WHEN dt.type = 'письмо' THEN 20
        ELSE 500
    END,
	10 + 17 * dt.id * RANDOM()
FROM ref.departure_types dt
CROSS JOIN ref.routes r;
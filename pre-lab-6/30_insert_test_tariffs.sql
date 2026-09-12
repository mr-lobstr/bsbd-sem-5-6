INSERT INTO ref.base_tariffs (
    departure_type_id,
    route_id,
    max_weight_grams,
    price
) SELECT
	dt.id,
	r.id,
    CASE
        WHEN dt.type = 'письмо' THEN 20
        ELSE 500
    END,
	10 + 17 * dt.id * RANDOM()
FROM ref.departure_types dt
CROSS JOIN ref.routes r;


INSERT INTO ref.base_tariffs (
    departure_type_id,
    route_id,
    max_weight_grams,
    price
) SELECT
	dt.id,
	r.id,
    CASE
        WHEN dt.type = 'письмо' THEN 90
        ELSE 1000
    END,
	10 + 26 * dt.id  * RANDOM()
FROM ref.departure_types dt
CROSS JOIN ref.routes r;


INSERT INTO ref.additional_weight_tariffs (
    departure_type_id,
    route_id,
    step_weight_grams,
    price
) SELECT
	dt.id,
	r.id,
    CASE
        WHEN dt.type = 'письмо' THEN 20
        ELSE 500
    END,
	10 + 17 * dt.id * RANDOM()
FROM ref.departure_types dt
CROSS JOIN ref.routes r;
INSERT INTO app.delivery (
    route_id,
    departure_method,
    receiving_method,
    segment_id
) SELECT
	1,
	'из отделения',
	'почтальоном',
	1
FROM generate_series(1, 4) i
RETURNING id;


INSERT INTO app.departures (
    type_id,
    dimension_id,
    weight_g,
    declared_value,
    sender_id,
    recipient_id,
    segment_id
) SELECT
    1,
    5,
    22,
    NULL,
    RANDOM() * 999 + 1,
    RANDOM() * 999 + 1,
    RANDOM() * 9 + 1
FROM generate_series(1, 4) i
JOIN ref.departure_types dp ON dp.id = (i - 1) % 10 + 1
RETURNING id;


INSERT INTO app.orders (
    departure_id,
    delivery_id,
    price,
    created_at,
    paid_at,
	segment_id
) VALUES
	(10001, 10001, 55, NOW(), NULL, 1),
	(10002, 10002, 55, NOW(), NULL, 1),
	(10003, 10003, 55, NOW(), NOW() + '1 day', 1),
	(10004, 10004, 55, NOW(), NOW() + '2 day', 1);


SELECT *
FROM app.orders o
WHERE o.id > 10000;

UPDATE app.orders o
SET paid_at = NOW()
WHERE o.id = 10001 OR o.id = 10002;

SELECT *
FROM app.orders o
WHERE o.id > 10000;
INSERT INTO app.delivery (
    route_id,
    departure_method,
    receiving_method
) SELECT
    (RANDOM() * 9 + 1)::INTEGER,
    (ARRAY['из отделения', 'курьером'])[i % 2 + 1],
    (ARRAY['самовывоз', 'курьером', 'почтальоном'])[i % 3 + 1]
FROM generate_series(1, 500) AS i;


INSERT INTO app.departures (
    type_id,
    dimension_id,
    weight_grams,
    declared_value,
    sender_id,
    recipient_id
) SELECT
    i % 10 + 1,
    CASE WHEN i % 10 + 1 <= 3 THEN 4 + RANDOM() * 10 ELSE RANDOM() * 49 + 1 END,
    dp.max_weight_grams * RANDOM(),
    CASE WHEN i % 10 + 1 = 3 OR i % 10 + 1 = 6 THEN RANDOM() * 500 ELSE NULL END,
    RANDOM() * 9 + 1,
    RANDOM() * 9 + 1
FROM generate_series(1, 500) AS i
JOIN ref.departure_types dp ON dp.id = i % 10 + 1;


INSERT INTO app.orders (
    departure_id,
    delivery_id,
    created_at
) SELECT
    i,
    i,
    '2023-01-01'::DATE + RANDOM() * (NOW() - '2023-01-01'::DATE)
FROM generate_series(1, 500) AS i;


UPDATE app.orders
SET closed_at = created_at + '15 day'::INTERVAL + RANDOM() * '2 month'::INTERVAL
WHERE TRUE;
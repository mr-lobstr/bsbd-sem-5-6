SET ROLE postgres;

INSERT INTO app.delivery (
    route_id,
    departure_method,
    receiving_method,
    segment_id
) SELECT
    RANDOM() * 9 + 1,
    (ARRAY[
        'из отделения',
        'курьером'
    ])[i % 2 + 1],
    (ARRAY[
        'самовывоз',
        'курьером',
        'почтальоном'
    ])[i % 3 + 1],
    1 + RANDOM() * 9
FROM generate_series(1, 10000) i;


INSERT INTO app.departures (
    type_id,
    dimension_id,
    weight_grams,
    declared_value,
    sender_id,
    recipient_id,
    segment_id
) SELECT
    (i - 1) % 10 + 1,
    CASE
        WHEN dp.type = 'письмо' THEN 4 + RANDOM() * 10
        ELSE 1 + RANDOM() * 49
    END,
    1 + (dp.max_weight_grams - 1) * RANDOM(),
    CASE
        WHEN dp.subtype LIKE 'ценн%' THEN 1000 * RANDOM()
        ELSE NULL
    END,
    RANDOM() * 999 + 1,
    RANDOM() * 999 + 1,
    RANDOM() * 9 + 1
FROM generate_series(1, 10000) i
JOIN ref.departure_types dp ON dp.id = (i - 1) % 10 + 1;


INSERT INTO app.orders (
    departure_id,
    delivery_id,
    created_at,
    closed_at,
    segment_id
) SELECT
    i,
    i,
    created,
    created + '15 day'::INTERVAL + '2 month'::INTERVAL * RANDOM(),
    RANDOM() * 9 + 1
FROM (
    SELECT
        i,
        NOW() - (NOW() - '2023-01-01'::DATE) * RANDOM() AS created
    FROM generate_series(1, 10000) i
);

RESET ROLE;
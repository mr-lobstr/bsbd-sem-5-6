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
FROM generate_series(1, 1000000) i;
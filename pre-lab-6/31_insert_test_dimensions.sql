INSERT INTO app.dimensions (
    width_mm,
    length_mm,
    height_mm,
    size_letters,
    is_standard,
    segment_id
)
VALUES
    (263, 176,  99, 'S',  TRUE, 1),
    (303, 233, 172, 'M',  TRUE, 1),
    (403, 290, 189, 'L',  TRUE, 1),
    (503, 360, 229, 'XL', TRUE, 1);


INSERT INTO app.dimensions (
    width_mm,
    length_mm,
    segment_id
)
SELECT
    100 + floor(random() * 200)::INTEGER,
    150 + floor(random() * 200)::INTEGER,
    1 + 9 * RANDOM()
FROM generate_series(1, 10);


INSERT INTO app.dimensions (
    width_mm,
    length_mm,
    height_mm,
    segment_id
)
SELECT
    100 + floor(random() * 501)::INTEGER,
    150 + floor(random() * 551)::INTEGER,
    20  + floor(random() * 331)::INTEGER,
    1 + 9 * RANDOM()
FROM generate_series(1, 36);
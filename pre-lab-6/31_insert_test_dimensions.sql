INSERT INTO app.dimensions (
    width_mm,
    length_mm,
    height_mm,
    size_letters,
    is_standard
)
VALUES
    (263, 176,  99, 'S',  TRUE),
    (303, 233, 172, 'M',  TRUE),
    (403, 290, 189, 'L',  TRUE),
    (503, 360, 229, 'XL', TRUE);


INSERT INTO app.custom_dimensions (
    width_mm,
    length_mm,
    height_mm
)
SELECT
    100 + floor(random() * 200)::INTEGER,
    150 + floor(random() * 200)::INTEGER,
    20  + floor(random() * 200)::INTEGER
FROM generate_series(1, 10);


INSERT INTO app.custom_dimensions (
    width_mm,
    length_mm,
    height_mm
)
SELECT
    100 + floor(random() * 501)::INTEGER,
    150 + floor(random() * 551)::INTEGER,
    20  + floor(random() * 331)::INTEGER
FROM generate_series(1, 36);
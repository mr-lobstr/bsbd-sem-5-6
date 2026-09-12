SET ROLE postgres;

BEGIN;

CREATE FUNCTION query_execution_time(query TEXT)
RETURNS REAL
LANGUAGE plpgsql
AS $$
    DECLARE
        plan JSONB;
    BEGIN
        EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || query
        INTO plan;

        RETURN plan->0->>'Execution Time';
    END;
$$;


CREATE TEMP TABLE raw_addresses_data (
    system VARCHAR(100),
    created_address_id INTEGER,
    raw_text TEXT
);


WITH regions_and_cities AS (
    SELECT 'Московская обл., г. Москва,' AS region_and_city
    UNION ALL SELECT 'Новосибирская обл., г. Новосибирск'
    UNION ALL SELECT 'Ленинградская обл., г. Санкт-Петербург'
    UNION ALL SELECT 'Красноярский кр., г. Красноярск'
), streets AS (
    SELECT 'ул. Октябрьская' AS street
    UNION ALL SELECT 'ул. Ленина'
    UNION ALL SELECT 'ул. Пушкина'
    UNION ALL SELECT 'ул. Советская'
    UNION ALL SELECT 'ул. Кирова'
    UNION ALL SELECT 'ул. Свердлова'
    UNION ALL SELECT 'ул. Гоголя'
    UNION ALL SELECT 'ул. Маяковского'
    UNION ALL SELECT 'ул. Лермонтова'
)
INSERT INTO raw_addresses_data (
    system,
    created_address_id,
    raw_text
)
SELECT
    'external system',
    1 + RANDOM() * 9,
    format(
        '%s %s, д. %s, кв. %s',
        region_and_city,
        street,
        house,
        flat
    )
FROM generate_series(1, 100) house
CROSS JOIN generate_series(1, 100) flat
CROSS JOIN regions_and_cities
CROSS JOIN streets;


TRUNCATE TABLE stg.raw_addresses CASCADE;


CREATE PROCEDURE speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
    RAISE NOTICE 'Insert execution time: % ms', query_execution_time($q$
        INSERT INTO stg.raw_addresses (
			system,
    		created_address_id,
    		raw_text
		)
        SELECT *
        FROM raw_addresses_data;
    $q$);

    RAISE NOTICE 'Search execution time: % ms', query_execution_time($q$
        SELECT raw_text
        FROM stg.raw_addresses ra
        WHERE ra.raw_text LIKE 'Новосибирская обл., г. Новосибирск, ул. Октябрьская%';
    $q$);
    
    RAISE EXCEPTION '';
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
END;
$$;


RESET ROLE;

CALL speed_test();

CREATE INDEX index_raw_addresses
ON stg.raw_addresses
USING SPGIST (raw_text);

CALL speed_test();

ROLLBACK;

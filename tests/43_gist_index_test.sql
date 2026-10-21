SET ROLE postgres;

BEGIN;

CREATE FUNCTION query_execution_time(query TEXT, f BOOLEAN DEFAULT FALSE)
RETURNS REAL
LANGUAGE plpgsql
AS $$
    DECLARE plan JSONB;
BEGIN
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || query
    INTO plan;
    RETURN plan->0->>'Execution Time';
END;
$$;


CREATE TEMP TABLE departures_operations_data (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(100) NOT NULL,
    departure_id INTEGER NOT NULL,
    employe_id INTEGER NOT NULL,
    period TSRANGE NOT NULL
);

CREATE TEMP TABLE departures_operations (
    LIKE departures_operations_data
);


INSERT INTO departures_operations_data (
    operation,
    departure_id,
    employe_id,
    period
)
SELECT
    (ARRAY[
        'приём в пункте отправления',
        'выдача в пункте получения',
        'приём возврата',
        'регистрация внешних повреждений'
    ])[1 + i % 4],
    (i - 1) % 10 + 1,
    (i - 1) % 10 + 1,
    tsrange(ts_beg, ts_beg + '1 h'::INTERVAL * RANDOM())
FROM (
    SELECT
        i,
        (
			NOW() - RANDOM() * '3 y'::INTERVAL
		)::TIMESTAMP AS ts_beg
    FROM generate_series(1, 1000000) AS i
);


CREATE PROCEDURE speed_test(title TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
	RAISE NOTICE '%', title;

	RAISE NOTICE 'Вставка данных: % ms', query_execution_time($q$
        INSERT INTO departures_operations
        SELECT *
        FROM departures_operations_data;
    $q$);

    RAISE NOTICE 'Поиск полных вложений: % ms', query_execution_time($q$
        SELECT COUNT(*)
        FROM departures_operations d
        WHERE tsrange(
			'2025-01-01 00:00:00',
			'2025-01-01 00:10:00'
		) @> d.period;
    $q$);

	RAISE NOTICE 'Поиск пересечейний: % ms', query_execution_time($q$
        SELECT COUNT(*)
        FROM departures_operations d
        WHERE tsrange(
			'2025-01-01 00:00:00',
			'2025-01-01 00:10:00'
		) && d.period;
    $q$);
	
	RAISE NOTICE '';
	RAISE EXCEPTION '';
EXCEPTION WHEN OTHERS THEN
	NULL;
END;
END;
$$;

RESET ROLE;

CALL speed_test('Без индекса');

CREATE INDEX departures_operations_index
ON departures_operations
USING GIST (period);

CALL speed_test('GiST');

ROLLBACK;

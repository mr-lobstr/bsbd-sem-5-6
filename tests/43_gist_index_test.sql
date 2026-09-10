SET ROLE postgres;

BEGIN;

CREATE FUNCTION pg_temp.query_execution_time(query TEXT)
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
    tsrange(ts_beg::TIMESTAMP, ts_beg::TIMESTAMP + '1 hour'::INTERVAL * RANDOM())
FROM (
    SELECT
        i,
        NOW() - RANDOM() * '3 year'::INTERVAL AS ts_beg
    FROM generate_series(1, 1000000) AS i
);



CREATE PROCEDURE pg_temp.speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
    RAISE NOTICE 'Insert execution time: % ms', pg_temp.query_execution_time($q$
        INSERT INTO departures_operations
        SELECT *
        FROM departures_operations_data;
    $q$);

    RAISE NOTICE 'Search execution time: % ms', pg_temp.query_execution_time($q$
        SELECT COUNT(*)
        FROM departures_operations d
        WHERE tsrange('2025-01-01 00:00:00', '2025-01-01 00:10:00') @> d.period;
    $q$);
    
    RAISE EXCEPTION '';
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
END;
$$;


RESET ROLE;

CALL pg_temp.speed_test();

CREATE INDEX departures_operations_index
ON departures_operations
USING GIST (period);

CALL pg_temp.speed_test();

ROLLBACK;
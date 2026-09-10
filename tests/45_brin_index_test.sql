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


CREATE TEMP TABLE brin_data (
    id SERIAL PRIMARY KEY,
    created TIMESTAMP NOT NULL,
    value INTEGER NOT NULL
);


INSERT INTO brin_data (created, value)
SELECT
    TIMESTAMP '2020-01-01'
        + i * INTERVAL '1 minute',
    (RANDOM() * 100000)::INTEGER
FROM generate_series(1, 1000000) AS i;

ANALYZE brin_data;


CREATE PROCEDURE pg_temp.speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN

        RAISE NOTICE 'Insert execution time: % ms',
            pg_temp.query_execution_time($q$
                INSERT INTO brin_data (created, value)
                SELECT
                    TIMESTAMP '2050-01-01'
                        + i * INTERVAL '1 minute',
                    (RANDOM() * 100000)::INTEGER
                FROM generate_series(1, 100000) AS i;
            $q$);


        RAISE NOTICE 'Update execution time: % ms',
            pg_temp.query_execution_time($q$
                UPDATE brin_data
                SET value = 0
                WHERE created >= TIMESTAMP '2021-11-25'
                  AND created <  TIMESTAMP '2021-12-02';
            $q$);


        RAISE EXCEPTION '';

    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END;
$$;


RESET ROLE;


CALL pg_temp.speed_test();

CREATE INDEX index_brin_created
ON brin_data USING BRIN (created);

ANALYZE brin_data;

CALL pg_temp.speed_test();

ROLLBACK;
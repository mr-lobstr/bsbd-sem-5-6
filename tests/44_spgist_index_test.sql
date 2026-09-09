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


CREATE TEMP TABLE spgist_data (
    id SERIAL PRIMARY KEY,
    address INET NOT NULL
);


INSERT INTO spgist_data (address)
SELECT
    (
        (RANDOM() * 223 + 1)::INTEGER || '.' ||
        (RANDOM() * 255)::INTEGER || '.' ||
        (RANDOM() * 255)::INTEGER || '.' ||
        (RANDOM() * 255)::INTEGER
    )::INET
FROM generate_series(1, 1000000);


CREATE PROCEDURE pg_temp.speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN

        RAISE NOTICE 'Insert execution time: % ms',
            pg_temp.query_execution_time($q$
                INSERT INTO spgist_data (address)
                SELECT
                    (
                        (RANDOM() * 223 + 1)::INTEGER || '.' ||
                        (RANDOM() * 255)::INTEGER || '.' ||
                        (RANDOM() * 255)::INTEGER || '.' ||
                        (RANDOM() * 255)::INTEGER
                    )::INET
                FROM generate_series(1, 100000);
            $q$);


        RAISE NOTICE 'Update execution time: % ms',
            pg_temp.query_execution_time($q$
                UPDATE spgist_data
                SET address = '10.0.0.1'
                WHERE address <<= '10.0.0.0/8';
            $q$);


        RAISE EXCEPTION '';

    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END;
$$;


RESET ROLE;

CALL pg_temp.speed_test();

CREATE INDEX index_spgist_address
ON spgist_data
USING SPGIST (address);

CALL pg_temp.speed_test();

ROLLBACK;
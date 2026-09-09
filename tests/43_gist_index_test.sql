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


CREATE TEMP TABLE gist_data (
    id SERIAL PRIMARY KEY,
    area BOX NOT NULL
);


INSERT INTO gist_data (area)
SELECT
    box(
        point(x, y),
        point(x + 10, y + 10)
    )
FROM (
    SELECT
        RANDOM() * 10000 AS x,
        RANDOM() * 10000 AS y
    FROM generate_series(1, 1000000)
) AS data;


CREATE PROCEDURE pg_temp.speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        RAISE NOTICE 'Insert execution time: % ms',
            pg_temp.query_execution_time($q$
                INSERT INTO gist_data (area)
                SELECT
                    box(
                        point(x, y),
                        point(x + 10, y + 10)
                    )
                FROM (
                    SELECT
                        RANDOM() * 10000 AS x,
                        RANDOM() * 10000 AS y
                    FROM generate_series(1, 100000)
                ) AS data;
            $q$);

        RAISE NOTICE 'Update execution time: % ms',
            pg_temp.query_execution_time($q$
                UPDATE gist_data
                SET area = box(
                    point(0, 0),
                    point(10, 10)
                )
                WHERE area <@ box(
                    point(1000, 1000),
    				point(1010, 1010)
                );
            $q$);

        RAISE EXCEPTION '';
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END;
$$;


RESET ROLE;

CALL pg_temp.speed_test();

CREATE INDEX index_gist_area
ON gist_data
USING GIST (area);

CALL pg_temp.speed_test();

ROLLBACK;
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


CREATE TEMP TABLE gin_data (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    search_vector TSVECTOR NOT NULL
);


-- 1 000 000 строк.
-- Только каждая 1000-я строка содержит уникальный искомый термин.
INSERT INTO gin_data (content, search_vector)
SELECT
    CASE
        WHEN i % 1000 = 0
            THEN 'document target_term special'
        ELSE
            'document application database information'
    END,
    to_tsvector(
        'english',
        CASE
            WHEN i % 1000 = 0
                THEN 'document target_term special'
            ELSE
                'document application database information'
        END
    )
FROM generate_series(1, 1000000) AS i;

ANALYZE gin_data;


CREATE PROCEDURE pg_temp.speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN

        RAISE NOTICE 'Insert execution time: % ms',
            pg_temp.query_execution_time($q$
                INSERT INTO gin_data (content, search_vector)
                VALUES (
                    'document target_term special',
                    to_tsvector(
                        'english',
                        'document target_term special'
                    )
                );
            $q$);


        RAISE NOTICE 'Update execution time: % ms',
            pg_temp.query_execution_time($q$
                UPDATE gin_data
                SET content = content || ' updated'
                WHERE search_vector @@
                    to_tsquery('english', 'target_term');
            $q$);


        RAISE EXCEPTION '';

    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END;
$$;


RESET ROLE;

CALL pg_temp.speed_test();

CREATE INDEX index_gin_search_vector
ON gin_data USING GIN (search_vector);

ANALYZE gin_data;

CALL pg_temp.speed_test();

ROLLBACK;
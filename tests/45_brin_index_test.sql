BEGIN;
SET ROLE postgres;

CREATE FUNCTION query_execution_time(query TEXT)
RETURNS REAL
LANGUAGE plpgsql
AS $$
DECLARE
    plan JSONB;
BEGIN
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON, BUFFERS) ' || query
    INTO plan;

    RETURN plan->0->>'Execution Time';
END;
$$;


INSERT INTO audit.temp_access_log (
	request_time,
	caller_role,
	expiries_at
)
SELECT
	NOW() + i * '1 m'::INTERVAL,
	(ARRAY[
		'app_owner',
		'app_reader',
		'app_writer',
		'dml_admin',
		'ddl_admin'
	])[1 + i % 5],
	NOW() + i * '10 m'::INTERVAL
FROM generate_series(1, 1000000) i;


CREATE PROCEDURE speed_test(title TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
	RAISE NOTICE '%', title;
	
    RAISE NOTICE 'Оператор BETWEEN: % ms', query_execution_time($q$
        SELECT COUNT(tal.request_time)
        FROM audit.temp_access_log tal
        WHERE tal.request_time
			BETWEEN NOW() + '3 h'::INTERVAL AND NOW() + '3 h 1 m'::INTERVAL;
    $q$);
END;
END;
$$;


CALL speed_test('Без индекса');

ANALYZE audit.temp_access_log;

CREATE INDEX index_temp_access_log_request_time
ON audit.temp_access_log
USING BRIN (request_time);

CALL speed_test('BRIN');

RESET ROLE;
ROLLBACK;

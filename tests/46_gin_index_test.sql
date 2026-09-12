BEGIN;
SET ROLE postgres;

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


DO $$
BEGIN
	FOR i IN 1..100 LOOP
		UPDATE app.clients
		SET mail = 'test@mail.ru';
	END LOOP;
END
$$;


CREATE PROCEDURE speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
    RAISE NOTICE 'Search execution time: % ms', query_execution_time($q$
        SELECT COUNT(*)
        FROM audit.row_change_log rcl
        WHERE rcl.new_data @> '{"name" : "Михаил"}';
    $q$);
END;
END;
$$;


CALL speed_test();

CREATE INDEX index_row_change_log_new_data
ON audit.row_change_log
USING GIN (new_data);

CALL speed_test();

RESET ROLE;
ROLLBACK;
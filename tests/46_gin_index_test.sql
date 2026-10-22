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
		SET name = CASE
				WHEN RANDOM() > 0.2
				THEN substr(md5(RANDOM()::TEXT), 0, 30)
				ELSE name
			END;
	END LOOP;
END
$$;


CREATE PROCEDURE speed_test(title TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
	RAISE NOTICE '%', title;

	RAISE NOTICE 'Вставка данных: % ms', query_execution_time($q$
		INSERT INTO audit.row_change_log_archive(
			username,
			table_name,
			change_timestamp,
			operation,
			old_data,
			new_data
		)
		SELECT
			username,
			table_name,
			change_timestamp,
			operation,
			old_data,
			new_data
		FROM audit.row_change_log;		
	$q$);
	
    RAISE NOTICE 'Условие "содержит": % ms', query_execution_time($q$
        SELECT COUNT(*)
        FROM audit.row_change_log_archive rcl
        WHERE rcl.new_data @> '{"name" : "Михаил"}';
    $q$);
	
    RAISE NOTICE '';
    RAISE EXCEPTION '';
EXCEPTION WHEN OTHERS THEN
	NULL;
END;
END;
$$;


CALL speed_test('Без индекса');

CREATE INDEX index_row_change_log_archive_new_data
ON audit.row_change_log_archive
USING GIN (new_data);

CALL speed_test('GIN');

RESET ROLE;
ROLLBACK;

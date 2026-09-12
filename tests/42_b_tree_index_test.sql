SET ROLE postgres;

BEGIN;

CREATE FUNCTION query_execution_time(query TEXT)
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


CREATE TEMP TABLE postal_objects_data (
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('склад', 'офис')
    ),
    address_id INTEGER NOT NULL,
    postal_code VARCHAR(6)
);


INSERT INTO postal_objects_data (
    type,
    address_id,
    postal_code
)
SELECT
    (ARRAY['склад', 'офис'])[i % 2 + 1],
    1 + ((i - 1) % 10),
    ((999999 - 100000) * RANDOM() + 100000)::INTEGER::TEXT
FROM generate_series(1, 1000000) AS i;


CREATE PROCEDURE speed_test()
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
	RAISE NOTICE 'Insert execution time: % ms', query_execution_time($q$
        INSERT INTO ref.postal_objects(
			type,
			address_id,
			postal_code
		)
        SELECT *
        FROM postal_objects_data;
    $q$);

	RAISE NOTICE 'Update execution time: % ms', query_execution_time($q$
        UPDATE ref.postal_objects
		SET postal_code = '000000'
		WHERE postal_code = '123456';		
    $q$);

	RAISE NOTICE 'Sort execution time: % ms', query_execution_time($q$
        SELECT postal_code
		FROM ref.postal_objects
		ORDER BY postal_code;		
    $q$);

	RAISE EXCEPTION '';
EXCEPTION WHEN OTHERS THEN
	NULL;
END;
END;
$$;

RESET ROLE;

CALL speed_test();

CREATE INDEX index_postal_code
ON ref.postal_objects(postal_code);

CALL speed_test();

DROP INDEX ref.index_postal_code;
CREATE INDEX index_postal_code
ON ref.postal_objects USING HASH (postal_code);

CALL speed_test();

ROLLBACK;
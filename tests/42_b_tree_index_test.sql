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

	IF f THEN
		RAISE NOTICE '%', plan;
	END IF;
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


CREATE PROCEDURE speed_test(title TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN
	RAISE NOTICE '%', title;

	RAISE NOTICE 'Вставка данных: % ms', query_execution_time($q$
        INSERT INTO ref.postal_objects(
			type,
			address_id,
			postal_code
		)
        SELECT *
        FROM postal_objects_data;
    $q$);

	RAISE NOTICE 'Условие на равенство: % ms', query_execution_time($q$
        UPDATE ref.postal_objects po
		SET postal_code = '000000'
		WHERE po.postal_code = '123456';		
    $q$);

	RAISE NOTICE 'Префиксный поиск: % ms', query_execution_time($q$
        SELECT postal_code
		FROM ref.postal_objects po
		WHERE po.postal_code LIKE '123%';		
    $q$);

	RAISE NOTICE 'Оператор BETWEEN: % ms', query_execution_time($q$
        SELECT postal_code
		FROM ref.postal_objects po
		WHERE po.postal_code BETWEEN '444444' AND '444454';		
    $q$);

	RAISE NOTICE 'Сортировка: % ms', query_execution_time($q$
        SELECT postal_code
		FROM ref.postal_objects po
		ORDER BY po.postal_code;		
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

CREATE INDEX index_postal_code
ON ref.postal_objects(postal_code);

CALL speed_test('B-Tree');

DROP INDEX ref.index_postal_code;
CREATE INDEX index_postal_code
ON ref.postal_objects
USING HASH (postal_code);

CALL speed_test('Hash');

ROLLBACK;

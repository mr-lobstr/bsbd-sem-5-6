BEGIN;

SET ROLE app_owner;

CREATE PROCEDURE pg_temp.print_explain(
    operation VARCHAR(50),
    plan_ JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
    DECLARE plan JSONB;
        rows_ INTEGER;
BEGIN
    plan := plan_->0;

    SELECT COALESCE(
        plan->'Plan'->'Plans'->0->>'Actual Rows',
        plan->'Plan'->>'Actual Rows'
    )::INTEGER
    INTO rows_;


    RAISE NOTICE
    E'%: Время: %,\t\t Строк: %,\t Чтение кеша: (Общий: %,\t Локал.: %),\t Запись в кеш: (Общий: %,\t Локал.: %)',
        operation,
        plan->>'Execution Time',
        rows_,
        plan->'Plan'->>'Shared Hit Blocks',
        plan->'Plan'->>'Local Hit Blocks',
        plan->'Plan'->>'Shared Dirtied Blocks',
        plan->'Plan'->>'Local Dirtied Blocks';
END;
$$;


CREATE PROCEDURE pg_temp.speed_test(
    row_count INTEGER,
    with_rls BOOLEAN,
    with_index BOOLEAN
)
LANGUAGE plpgsql
AS $$
    DECLARE plan JSONB;
        result RECORD;
BEGIN

    CREATE TABLE pg_temp.test_data (
        address_id INTEGER,
        flat INTEGER,
        floor INTEGER,
        entrance INTEGER,
        has_mailbox BOOLEAN,
        intercom_code VARCHAR(6),
        delivery_notes TEXT
    );

    INSERT INTO pg_temp.test_data (
        address_id,
        flat,
        floor,
        entrance,
        has_mailbox,
        intercom_code,
        delivery_notes
    ) SELECT 
        i % 10 + 1,
        i % 10 + 1,
        i % 10 + 1,
        i % 10 + 1,
        i % 2 = 0,
        (i)::TEXT,
        md5((i)::TEXT)
    FROM generate_series(1, row_count) i;


    IF NOT with_rls THEN
        ALTER TABLE app.client_addresses
        DISABLE ROW LEVEL SECURITY;
    END IF;


    IF NOT with_index THEN
        DROP INDEX app.client_addresses_segment_id_idx;
        DROP INDEX app.client_addresses_id_idx;
        DROP INDEX app.client_addresses_address_id_idx;
    END IF;


    EXECUTE $q$
        EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
        INSERT INTO app.client_addresses (
            address_id,
            flat,
            floor,
            entrance,
            has_mailbox,
            intercom_code,
            delivery_notes
        )
        SELECT * FROM pg_temp.test_data;
    $q$
    INTO plan;

    CALL pg_temp.print_explain('INSERT', plan);

    EXECUTE $q$
        EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
        SELECT *
        FROM app.client_addresses
        WHERE address_id = 5;
    $q$
    INTO plan;

    CALL pg_temp.print_explain('SELECT', plan);

    EXECUTE $q$
        EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
        UPDATE app.client_addresses
        SET entrance = 10
        WHERE address_id = 5;
    $q$
    INTO plan;

    CALL pg_temp.print_explain('UPDATE', plan);

    RAISE EXCEPTION '';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '%', SQLERRM;
END;
$$;

DO $$
BEGIN
    PERFORM app.set_session_ctx(1, 1);

    RAISE NOTICE 'Включены RLS, индексы:';
    CALL pg_temp.speed_test(100000, true, true);
    RAISE NOTICE '';

    RAISE NOTICE 'Включены RLS, без индексов:';
    CALL pg_temp.speed_test(100000, true, false);
    RAISE NOTICE '';

    RAISE NOTICE 'Выключены RLS, без индексов:';
    CALL pg_temp.speed_test(100000, false, false);
    RAISE NOTICE '';

END;
$$;

ROLLBACK;
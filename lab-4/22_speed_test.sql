SET ROLE postgres;

BEGIN;

CREATE TABLE pg_temp.test_data (
    address_id INTEGER,
    flat INTEGER,
    floor INTEGER,
    entrance INTEGER,
    has_mailbox BOOLEAN,
    intercom_code VARCHAR(6),
    delivery_notes TEXT
);

DO $$
BEGIN
    PERFORM app.set_session_ctx(1, 1);

    INSERT INTO pg_temp.test_data (
        address_id,
        flat,
        floor,
        entrance,
        has_mailbox,
        intercom_code,
        delivery_notes
    ) SELECT 
        (9 * random() + 1)::INTEGER,
        (10 * random())::INTEGER,
        (10 * random())::INTEGER,
        (100 * random())::INTEGER,
        (random() > 0.5),
        floor(999999 * random())::TEXT,
        md5(random()::TEXT)
    FROM generate_series(1, 10000) i;
END;
$$;


CREATE PROCEDURE pg_temp.print_explain(operation VARCHAR(50), plan_ JSONB)
LANGUAGE plpgsql
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


CREATE PROCEDURE pg_temp.insert_select_update_explain()
LANGUAGE plpgsql
AS $$
    DECLARE plan JSONB;
        result RECORD;
BEGIN
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
    RAISE NOTICE 'Включены RLS, индексы:';
    CALL pg_temp.insert_select_update_explain();
    RAISE NOTICE '';

    DROP INDEX app.client_addresses_segment_id_idx;
    DROP INDEX app.client_addresses_id_idx;
    DROP INDEX app.client_addresses_address_id_idx;
    
    RAISE NOTICE 'Включены RLS, без индексов:';
    CALL pg_temp.insert_select_update_explain();
    RAISE NOTICE '';

    ALTER TABLE app.client_addresses
    DISABLE ROW LEVEL SECURITY;

    RAISE NOTICE 'Выключены RLS, без индексов:';
    CALL pg_temp.insert_select_update_explain();
    RAISE NOTICE '';

END;
$$;

ROLLBACK;
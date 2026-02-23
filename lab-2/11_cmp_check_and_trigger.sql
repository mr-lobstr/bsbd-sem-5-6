SET ROLE app_owner;

BEGIN;

CREATE TEMP TABLE pg_temp.test_raw_addresses_data(
    raw_text TEXT NOT NULL,
    system VARCHAR(100) NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP
) ON COMMIT DROP;


CREATE TEMP TABLE pg_temp.test_raw_addresses_with_check(
    raw_text TEXT NOT NULL,
    system VARCHAR(100) NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP,

    CONSTRAINT received_before_processed
    CHECK (processed_at IS NULL OR received_at <= processed_at)
) ON COMMIT DROP;


CREATE TEMP TABLE pg_temp.test_raw_addresses_with_trigger(
    raw_text TEXT NOT NULL,
    system VARCHAR(100) NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP
) ON COMMIT DROP;

CREATE OR REPLACE FUNCTION pg_temp.test_raw_addresses_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.processed_at IS NOT NULL AND NEW.processed_at < NEW.received_at THEN
        RAISE EXCEPTION 
            'Дата обработки адреса (%) не может следовать раньше даты его получения (%)',
            NEW.received_at,
            NEW.processed_at;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER test_raw_addresses_trg
BEFORE INSERT ON pg_temp.test_raw_addresses_with_trigger
FOR EACH ROW
EXECUTE FUNCTION pg_temp.test_raw_addresses_trigger();


INSERT INTO pg_temp.test_raw_addresses_data(
    raw_text,
    system,
    received_at,
    processed_at
) SELECT 
    'test text',
    'test system',
    NOW(),
    NOW() + random() * interval '365 days'
FROM generate_series(1, 10000) i;


DO $$
DECLARE
    rec RECORD;
    plan JSONB;
    failed_count INTEGER := 0;
BEGIN
    EXECUTE $q$
        EXPLAIN (ANALYZE, FORMAT JSON)
        INSERT INTO pg_temp.test_raw_addresses_with_check
        SELECT * FROM pg_temp.test_raw_addresses_data;
    $q$
    INTO plan;

    RAISE NOTICE 'Время выполнения вставки с CHECK: % ms', plan->0->>'Execution Time';

    EXECUTE $q$
        EXPLAIN (ANALYZE, FORMAT JSON)
        INSERT INTO pg_temp.test_raw_addresses_with_trigger
        SELECT * FROM pg_temp.test_raw_addresses_data;
    $q$
    INTO plan;

    RAISE NOTICE 'Время выполнения вставки с TRIGGER: % ms', plan->0->>'Execution Time';
END;
$$;

TRUNCATE TABLE pg_temp.test_raw_addresses_data;

INSERT INTO pg_temp.test_raw_addresses_data(
    raw_text,
    system,
    received_at,
    processed_at
) SELECT 
    'test text',
    'test system',
    NOW() + random() * interval '365 days',
    NOW() + random() * interval '365 days'
FROM generate_series(1, 10000) i;

DO $$
DECLARE
    rec RECORD;
    failed_count INTEGER := 0;
BEGIN
    FOR rec IN SELECT * FROM pg_temp.test_raw_addresses_data LOOP
        BEGIN
            INSERT INTO pg_temp.test_raw_addresses_with_check(
				raw_text,
				system,
				received_at,
				processed_at
			) VALUES(
                rec.raw_text,
                rec.system,
                rec.received_at,
                rec.processed_at
            );
        EXCEPTION WHEN OTHERS THEN
            failed_count := failed_count + 1;
        END;
    END LOOP;

    RAISE NOTICE 'Тест CHECK, строк с некорректными данными: %', failed_count;

    failed_count := 0;

    FOR rec IN SELECT * FROM pg_temp.test_raw_addresses_data LOOP
        BEGIN
            INSERT INTO pg_temp.test_raw_addresses_with_trigger(
				raw_text,
				system,
				received_at,
				processed_at
			) VALUES(
                rec.raw_text,
                rec.system,
                rec.received_at,
                rec.processed_at
            );
        EXCEPTION WHEN OTHERS THEN
            failed_count := failed_count + 1;
        END;
    END LOOP;

    RAISE NOTICE 'Тест TRIGGER, строк с некорректными данными: %', failed_count;

    BEGIN
        INSERT INTO pg_temp.test_raw_addresses_with_check(
			raw_text,
			system,
			received_at,
			processed_at
		) VALUES(
            'test text',
            'test system',
            '2026-02-02',
            '2026-02-01'
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Сообщение об ошибке CHECK: %', SQLERRM;
    END;

    BEGIN
        INSERT INTO pg_temp.test_raw_addresses_with_trigger(
			raw_text,
			system,
			received_at,
			processed_at
		) VALUES(
            'test text',
            'test system',
            '2026-02-02',
            '2026-02-01'
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Сообщение об ошибке TRIGGER: %', SQLERRM;
    END;
END;
$$;

COMMIT;

RESET ROLE;
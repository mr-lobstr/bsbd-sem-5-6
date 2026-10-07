SET ROLE postgres;

CREATE FUNCTION app.operation_log_create()
RETURNS event_trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE operation_log(
        cnt INTEGER
            DEFAULT 1,
        schema_ VARCHAR(63),
        table_ VARCHAR(63),
        operation VARCHAR(20),
        at_ TIMESTAMP
            DEFAULT NOW()      
    );

    CREATE INDEX operation_log_index
    ON operation_log(schema_, table_, operation, at_);
END;
$$;

CREATE EVENT TRIGGER operation_log_create
ON LOGIN
EXECUTE FUNCTION app.operation_log_create();


CREATE FUNCTION app.operation_rate_limit_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE cnt_ INTEGER;
BEGIN
    SELECT ol.cnt
    INTO cnt_
    FROM operation_log ol
    WHERE ol.schema_ = TG_TABLE_SCHEMA
        AND ol.table_ = TG_TABLE_NAME
        AND ol.operation = TG_OP
        AND ol.at_ = NOW();

    IF cnt_ IS NULL
    THEN
        INSERT INTO operation_log (
            schema_,
            table_,
            operation
        ) VALUES (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            TG_OP
        );

        cnt_ := 1;
        RAISE NOTICE '%', NOW();
    ELSE
        UPDATE operation_log ol
        SET cnt = cnt + 1
        WHERE ol.schema_ = TG_TABLE_SCHEMA
            AND ol.table_ = TG_TABLE_NAME
            AND ol.operation = TG_OP
            AND ol.at_ = NOW();
        
        cnt_ := cnt_ + 1;
    END IF;

    IF cnt_ >= TG_ARGV[0]::INTEGER THEN
        RAISE NOTICE '%', NOW();
        RAISE EXCEPTION
            'Привышен лимит (%) количества операций % для таблицы "%.%"',
            TG_ARGV[0],
            TG_OP,
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER operation_filter_orders_delete_trg
AFTER DELETE
ON app.orders
FOR EACH ROW
EXECUTE FUNCTION app.operation_rate_limit_row(1000);


CREATE FUNCTION app.operation_rate_limit_statement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE cnt_ INTEGER;
BEGIN
    SELECT SUM(ol.cnt)
    INTO cnt_
    FROM operation_log ol
    WHERE ol.schema_ = TG_TABLE_SCHEMA
        AND ol.table_ = TG_TABLE_NAME
        AND ol.operation = TG_OP
        AND NOW() - ol.at_ <= TG_ARGV[1]::INTERVAL;

    IF cnt_ IS NOT NULL AND cnt_ > TG_ARGV[0]::INTEGER
    THEN
        RAISE EXCEPTION
            'Привышен лимит (% за %) количества операций % для таблицы "%.%"',
            TG_ARGV[0],
            TG_ARGV[1],
            TG_OP,
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER operation_filter2_orders_delete_trg
AFTER DELETE
ON app.orders
FOR EACH STATEMENT
EXECUTE FUNCTION app.operation_rate_limit_statement(3000, '5 minutes');

RESET ROLE;
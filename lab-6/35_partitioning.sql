SET ROLE app_owner;

CREATE TABLE app.orders_partition (
    id INTEGER,
    departure_id INTEGER NOT NULL
        REFERENCES app.departures(id),
    delivery_id INTEGER NOT NULL
        REFERENCES app.delivery(id),
    price NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMP,
    segment_id INTEGER NOT NULL
        DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER
        REFERENCES ref.postal_objects
) PARTITION BY RANGE (created_at);

COMMENT ON TABLE app.orders_partition
IS 'История заказов с декларативным секционирование по диапазону';


CREATE TABLE app.orders_partition_current
PARTITION OF app.orders_partition
FOR VALUES
FROM ((NOW() - '1 month'::INTERVAL)::DATE)
TO ((NOW() + '1 day'::INTERVAL)::DATE);

COMMENT ON TABLE app.orders_partition_current
IS 'Заказы за отчетный период (последний месяц)';


CREATE TABLE app.orders_partition_archive
PARTITION OF app.orders_partition
DEFAULT;

COMMENT ON TABLE app.orders_partition_archive
IS 'Заказы за предыдущие годы/месяцы';


SET ROLE postgres;

SELECT app.set_session_ctx(1, 1);

INSERT INTO app.orders_partition
SELECT *
FROM app.orders;

RESET ROLE;
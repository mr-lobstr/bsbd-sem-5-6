SET ROLE app_owner;

CREATE TABLE app.orders_partition (
    id INTEGER,
    departure_id
        INTEGER NOT NULL
        REFERENCES app.departures(id),
    delivery_id INTEGER
        NOT NULL
        REFERENCES app.delivery(id),
    price NUMERIC(10, 2)
        NOT NULL,
    created_at TIMESTAMP
        NOT NULL,
    paid_at TIMESTAMP,
    closed_at TIMESTAMP,
    segment_id INTEGER
        NOT NULL
        REFERENCES ref.postal_objects
) PARTITION BY RANGE (paid_at);

COMMENT ON TABLE app.orders_partition
IS 'История заказов с декларативным секционирование по диапазону';


CREATE TABLE app.orders_partition_current
PARTITION OF app.orders_partition
FOR VALUES
FROM (DATE_TRUNC('month', NOW()))
TO (DATE_TRUNC('month', NOW()) + '1 mon'::INTERVAL);

COMMENT ON TABLE app.orders_partition_current
IS 'Заказы за отчетный период (последний месяц)';


CREATE TABLE app.orders_partition_archive
PARTITION OF app.orders_partition
DEFAULT;

COMMENT ON TABLE app.orders_partition_archive
IS 'Заказы за предыдущие месяцы/годы';


SET ROLE postgres;

SELECT app.set_session_ctx(1, 1);

INSERT INTO app.orders_partition
SELECT *
FROM app.orders;

RESET ROLE;
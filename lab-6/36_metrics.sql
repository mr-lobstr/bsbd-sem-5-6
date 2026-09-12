WITH orders_with_client_info AS (
    SELECT
        sender_id,
        c.name,
        op.price
    FROM app.orders_partition op
    JOIN app.departures d ON d.id = op.departure_id
    JOIN app.clients c ON c.id = sender_id
    WHERE NOT op.closed_at IS NULL
)
SELECT
    sender_id,
    name,
    SUM(price) AS LTV
FROM orders_with_client_info
GROUP BY sender_id, name
ORDER BY LTV DESC
LIMIT 50;


WITH orders_with_client_info AS (
    SELECT
        sender_id,
        c.name,
        op.price
    FROM app.orders_partition op
    JOIN app.departures d ON d.id = op.departure_id
    JOIN app.clients c ON c.id = sender_id
    WHERE NOT op.closed_at IS NULL
)
SELECT
    sender_id,
    name,
    (SUM(price)/COUNT(price))::NUMERIC(10, 2) AS AOV
FROM orders_with_client_info
GROUP BY sender_id, name
ORDER BY AOV DESC
LIMIT 5;


WITH active_clients_count AS (
    SELECT COUNT(*) AS cnt
    FROM app.clients c
    WHERE EXISTS (
		SELECT 1
		FROM app.orders_partition op
		JOIN app.departures d ON d.id = op.departure_id
		WHERE d.sender_id = c.id
	)
), revenue_for_month AS (
    SELECT
        SUM(op.price) AS rev
    FROM app.orders_partition op
    WHERE NOW() - '1 month'::INTERVAL <= op.created_at AND op.created_at < NOW()
)
SELECT (rev / cnt)::NUMERIC(10, 2) AS ARPU
FROM active_clients_count
JOIN revenue_for_month ON TRUE;


WITH orders_for_month AS (
    SELECT *
    FROM app.orders_partition op
    WHERE NOW() - '1 month'::INTERVAL <= op.created_at AND op.created_at < NOW()
), revenue_for_month AS (
	SELECT
        SUM(price) AS rev
	FROM orders_for_month
), payng_clients_count AS (
	SELECT
        COUNT(DISTINCT d.sender_id) AS cnt
	FROM orders_for_month o
	JOIN app.departures d ON d.id = o.departure_id
)
SELECT (rev / cnt)::NUMERIC(10, 2) AS ARPPU
FROM revenue_for_month
JOIN payng_clients_count ON TRUE;


-- EXPLAIN (ANALYZE, FORMAT JSON)
WITH orders_for_month AS (
	SELECT *
	FROM app.orders_partition op
	WHERE NOW() - '1 month'::INTERVAL <= op.created_at AND op.created_at < NOW()
), departures_types_and_counts AS (
	SELECT
		COUNT(*) AS cnt,
		d.type_id
	FROM orders_for_month o
	JOIN app.departures d ON d.id = o.departure_id
	GROUP BY d.type_id
)
SELECT
	dt.id,
	dt.type,
	dt.subtype,
	cnt
FROM departures_types_and_counts d
JOIN ref.departure_types dt ON dt.id = d.type_id
ORDER BY cnt DESC
LIMIT 3;
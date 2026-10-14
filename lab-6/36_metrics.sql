WITH paid_orders AS (
	SELECT
		op.departure_id,
		op.price
	FROM app.orders_partition op
	WHERE op.paid_at IS NOT NULL
)
SELECT
    d.sender_id,
    c.name,
    SUM(po.price) AS LTV
FROM paid_orders po
JOIN app.departures d
    ON d.id = po.departure_id
JOIN app.clients c
    ON c.id = d.sender_id
GROUP BY
    d.sender_id,
    c.name
ORDER BY LTV DESC
LIMIT 5;


WITH paid_orders AS (
	SELECT
		op.departure_id,
		op.price
	FROM app.orders_partition op
)
SELECT
    d.sender_id,
    c.name,
    ROUND(AVG(po.price), 2) AS AOV
FROM paid_orders po
JOIN app.departures d
    ON d.id = po.departure_id
JOIN app.clients c
	ON c.id = d.sender_id
GROUP BY
    d.sender_id,
    c.name
ORDER BY AOV DESC
LIMIT 5;


WITH date_range AS (
    SELECT
        DATE_TRUNC('month', NOW()) AS beg,
        DATE_TRUNC('month', NOW()) + '1 mon'::INTERVAL AS end
), active_clients AS (
	SELECT NULLIF(COUNT(DISTINCT d.sender_id), 0) AS cnt
	FROM app.orders_partition op
	JOIN app.departures d
    	ON d.id = op.departure_id
),sum_price_for_month AS (
    SELECT SUM(op.price) AS price
    FROM
        app.orders_partition op,
        date_range dr
    WHERE dr.beg <= op.paid_at
        AND op.paid_at < dr.end
)
SELECT ROUND(sp.price/ac.cnt, 2) AS ARPU
FROM
    active_clients ac,
    sum_price_for_month sp;


EXPLAIN(ANALYZE, FORMAT JSON)
WITH date_range AS (
    SELECT
        DATE_TRUNC('month', NOW()) AS beg,
        DATE_TRUNC('month', NOW()) + '1 mon'::INTERVAL AS end
), price_and_count AS (
	SELECT
		SUM(op.price) AS price,
		NULLIF(COUNT(DISTINCT d.sender_id), 0) AS cnt
	FROM app.orders_partition op
	JOIN app.departures d
		ON d.id = op.departure_id
	JOIN date_range dr
		ON TRUE
	WHERE dr.beg <= op.paid_at
		AND op.paid_at < dr.end
		AND op.closed_at IS NOT NULL
)
SELECT ROUND(pc.price/pc.cnt, 2) AS ARPPU
FROM price_and_count pc;


WITH date_range AS (
    SELECT
        DATE_TRUNC('month', NOW()) AS beg,
        DATE_TRUNC('month', NOW()) + '1 mon'::INTERVAL AS end
), departures_types_and_counts AS (
	SELECT
		COUNT(*) AS cnt,
		d.type_id
	FROM app.orders_partition op
	JOIN app.departures d
        ON d.id = op.departure_id
	JOIN date_range dr
		ON TRUE
	WHERE dr.beg <= op.paid_at
        AND op.paid_at < dr.end
		AND op.closed_at IS NOT NULL
	GROUP BY d.type_id
)
SELECT
	dt.id,
	dt.type,
	dt.subtype,
	cnt
FROM departures_types_and_counts d
JOIN ref.departure_types dt
    ON dt.id = d.type_id
ORDER BY cnt ASC
LIMIT 3;

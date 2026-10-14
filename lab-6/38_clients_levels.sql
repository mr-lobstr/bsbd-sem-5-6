SET ROLE app_owner;

CREATE TABLE ref.client_levels (
    id SERIAL
        PRIMARY KEY,
    name VARCHAR(50)
        NOT NULL
        UNIQUE,
    min_ltv NUMERIC(10, 2)
        NOT NULL,
    discount NUMERIC(5, 4)
        NOT NULL
        CHECK (0 <= discount AND discount < 1)
);

SET ROLE postgres;

INSERT INTO ref.client_levels (
    id, 
    name,
    min_ltv,
    discount
) VALUES
    (1, 'Базовый', 0, 0),
    (2, 'Бронзовый', 10000, 0.01),
    (3, 'Серебряный', 25000, 0.03),
    (4, 'Золотой', 50000, 0.05),
    (5, 'Платиновый', 100000, 0.10);


ALTER TABLE app.clients
    ADD COLUMN level_id INTEGER
        NOT NULL
        DEFAULT 1
        REFERENCES ref.client_levels(id);


SELECT app.set_session_ctx(1, 1);

WITH paid_orders AS (
	SELECT
		op.departure_id,
		op.price
	FROM app.orders_partition op
	WHERE op.paid_at IS NOT NULL
), clients_ltv AS (
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
), clients_levels AS (
	SELECT
		DISTINCT ON (cl.sender_id)
		cl.sender_id AS id,
		l.id AS level_id
	FROM clients_ltv cl
	JOIN ref.client_levels l
		ON l.min_ltv < cl.ltv
	ORDER BY
		cl.sender_id,
		l.min_ltv
		DESC
)
UPDATE app.clients c
SET level_id = cl.level_id
FROM clients_levels cl
WHERE c.id = cl.id;

RESET ROLE;

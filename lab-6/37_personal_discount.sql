SET ROLE app_owner;

CREATE TABLE app.temporary_personal_discount (
    id SERIAL
        PRIMARY KEY,
    client_id INTEGER
        NOT NULL
        REFERENCES app.clients(id)
            ON DELETE CASCADE,
    departure_type_id INTEGER
        NOT NULL
        REFERENCES ref.departure_types(id)
            ON DELETE CASCADE,
    discount REAL
        NOT NULL
        CHECK (0 < discount AND discount < 1),
    valid_until DATE
        NOT NULL,

    UNIQUE(client_id, departure_type_id)
);


WITH date_range AS (
    SELECT
        DATE_TRUNC('month', NOW()) AS beg,
        DATE_TRUNC('month', NOW()) + '1 mon'::INTERVAL AS end
), paying_clients AS (
	SELECT d.sender_id
	FROM app.orders_partition op
	JOIN app.departures d
		ON d.id = op.departure_id
	JOIN date_range dr
		ON TRUE
	WHERE op.paid_at >= dr.beg
		AND op.paid_at < dr.end
)
INSERT INTO app.temporary_personal_discount(
	client_id,
	departure_type_id,
	discount,
	valid_until
)
SELECT
	c.id,
	RANDOM() * 9 + 1,
	0.02,
	DATE_TRUNC('month', NOW()) + '2 mon'::INTERVAL
FROM app.clients c
WHERE NOT c.id IN (
	SELECT *
	FROM paying_clients
);

RESET ROLE;

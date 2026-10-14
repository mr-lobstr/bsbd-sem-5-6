SET ROLE app_owner;

CREATE TABLE ref.client_levels (
    id SERIAL
        PRIMARY KEY,
    name VARCHAR(50)
        NOT NULL
        UNIQUE,
    min_ltv NUMERIC(10, 2)
        NOT NULL,
    discount NUMERIC(5, 2)
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

RESET ROLE;

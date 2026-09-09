SET ROLE app_owner;

CREATE TABLE app.discounts_for_unpopular_products (
    id SERIAL PRIMARY KEY,
    departure_type_id INTEGER NOT NULL
        REFERENCES ref.departure_types(id) ON DELETE CASCADE,
    discount REAL NOT NULL CHECK (
        0 < discount AND discount < 1
    ),
    valid_until DATE NOT NULL
);

RESET ROLE;
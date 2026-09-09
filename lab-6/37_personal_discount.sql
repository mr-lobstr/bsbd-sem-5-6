SET ROLE app_owner;

CREATE TABLE app.temporary_personal_discount (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL
        REFERENCES app.clients(id) ON DELETE CASCADE,
    departure_type_id INTEGER NOT NULL
        REFERENCES ref.departure_types(id) ON DELETE CASCADE,
    discount REAL NOT NULL CHECK (
        0 < discount AND discount < 1
    ),
    valid_until DATE NOT NULL,

    UNIQUE(client_id, departure_type_id)
);

RESET ROLE;
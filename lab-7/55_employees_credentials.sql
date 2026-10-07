SET ROLE app_owner;

CREATE TABLE app.employees_credentials (
    id SERIAL
        PRIMARY KEY,
    employee_id INTEGER
        NOT NULL
        UNIQUE
        REFERENCES app.employees(id),
    login_ VARCHAR(50)
        NOT NULL
        UNIQUE,
    password_hash TEXT
        NOT NULL,
    salt TEXT,
    is_admin BOOLEAN
        NOT NULL
        DEFAULT FALSE,
    segment_id INTEGER
        NOT NULL
        DEFAULT app.get_segment_id()
);


CREATE TABLE app.password_change_requests (
    id SERIAL
        PRIMARY KEY,
    requester_id INTEGER
        NOT NULL
        REFERENCES app.employees(id),
    requested_at TIMESTAMP
        NOT NULL
        DEFAULT NOW(),
    approved BOOLEAN
        NOT NULL
        DEFAULT FALSE,
    approver_id INTEGER
        REFERENCES app.employees(id),
    approved_at TIMESTAMP,
    expiried_at TIMESTAMP,
    closed BOOLEAN
        NOT NULL
        DEFAULT FALSE
);


SELECT app.set_session_ctx(1, 1);


INSERT INTO app.employees_credentials (
    employee_id,
    login_,
    password_hash
)
SELECT
    e.id,
    'login_' || e.id::TEXT,
    md5(RANDOM()::TEXT)
FROM app.employees e;


UPDATE app.employees_credentials ec
SET is_admin = TRUE
WHERE ec.id = 1;

RESET ROLE;
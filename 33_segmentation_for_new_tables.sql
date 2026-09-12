SET ROLE app_owner;

ALTER TABLE app.dimensions
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.departures
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.delivery
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.status_history
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.orders
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;


UPDATE app.dimensions
SET segment_id = (id - 1) % 10 + 1;

UPDATE app.departures
SET segment_id = (id - 1) % 10 + 1;

UPDATE app.delivery
SET segment_id = (id - 1) % 10 + 1;

UPDATE app.status_history
SET segment_id = 9 * RANDOM() + 1;

UPDATE app.orders
SET segment_id = (id - 1) % 10 + 1;


ALTER TABLE app.dimensions
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.dimensions
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.departures
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.departures
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.delivery
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.delivery
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.status_history
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.status_history
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.orders
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.orders
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;


RESET ROLE;
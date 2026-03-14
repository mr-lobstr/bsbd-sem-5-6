SET ROLE app_owner;

ALTER TABLE app.client_addresses
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.clients
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.packages
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.status_history
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;

ALTER TABLE app.movement_history
ADD COLUMN segment_id INTEGER
REFERENCES ref.postal_objects;


UPDATE app.client_addresses
SET segment_id = id;

UPDATE app.clients
SET segment_id = id;

UPDATE app.packages
SET segment_id = id;

UPDATE app.status_history
SET segment_id = id;

UPDATE app.movement_history
SET segment_id = id;


ALTER TABLE app.client_addresses
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.client_addresses
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.clients
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.clients
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.packages
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.packages
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.status_history
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.status_history
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

ALTER TABLE app.movement_history
ALTER COLUMN segment_id SET NOT NULL;

ALTER TABLE app.movement_history
ALTER COLUMN segment_id
SET DEFAULT (NULLIF(current_setting('app.segment_id'), ''))::INTEGER;

RESET ROLE;
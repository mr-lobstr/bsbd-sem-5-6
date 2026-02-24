SET ROLE app_owner;

ALTER TABLE app.client_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.client_addresses FORCE ROW LEVEL SECURITY;

ALTER TABLE app.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.clients FORCE ROW LEVEL SECURITY;

ALTER TABLE app.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.packages FORCE ROW LEVEL SECURITY;

ALTER TABLE app.status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.status_history FORCE ROW LEVEL SECURITY;

ALTER TABLE app.movement_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.movement_history FORCE ROW LEVEL SECURITY;


CREATE POLICY client_addresses_select_rls
ON app.client_addresses
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY client_addresses_insert_rls
ON app.client_addresses
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY client_addresses_update_rls
ON app.client_addresses
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY client_addresses_delete_rls
ON app.client_addresses
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY clients_select_rls
ON app.clients
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY clients_insert_rls
ON app.clients
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY clients_update_rls
ON app.clients
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY clients_delete_rls
ON app.clients
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY packages_select_rls
ON app.packages
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY packages_insert_rls
ON app.packages
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY packages_update_rls
ON app.packages
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY packages_delete_rls
ON app.packages
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY status_history_select_rls
ON app.status_history
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY status_history_insert_rls
ON app.status_history
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY status_history_update_rls
ON app.status_history
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY status_history_delete_rls
ON app.status_history
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY movement_history_select_rls
ON app.movement_history
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY movement_history_insert_rls
ON app.movement_history
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY movement_history_update_rls
ON app.movement_history
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY movement_history_delete_rls
ON app.movement_history
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

RESET ROLE;
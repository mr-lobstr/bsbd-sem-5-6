SET ROLE app_owner;

ALTER TABLE app.dimensions ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.dimensions FORCE ROW LEVEL SECURITY;

ALTER TABLE app.departures ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.departures FORCE ROW LEVEL SECURITY;

ALTER TABLE app.delivery ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.delivery FORCE ROW LEVEL SECURITY;

ALTER TABLE app.status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.status_history FORCE ROW LEVEL SECURITY;

ALTER TABLE app.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.orders FORCE ROW LEVEL SECURITY;


CREATE POLICY dimensions_select_rls
ON app.dimensions
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY dimensions_insert_rls
ON app.dimensions
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY dimensions_update_rls
ON app.dimensions
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY dimensions_delete_rls
ON app.dimensions
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY departures_select_rls
ON app.departures
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY departures_insert_rls
ON app.departures
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY departures_update_rls
ON app.departures
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY departures_delete_rls
ON app.departures
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);


CREATE POLICY delivery_select_rls
ON app.delivery
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY delivery_insert_rls
ON app.delivery
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY delivery_update_rls
ON app.delivery
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY delivery_delete_rls
ON app.delivery
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


CREATE POLICY orders_select_rls
ON app.orders
FOR SELECT
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY orders_insert_rls
ON app.orders
FOR INSERT
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY orders_update_rls
ON app.orders
FOR UPDATE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
)
WITH CHECK (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

CREATE POLICY orders_delete_rls
ON app.orders
FOR DELETE
USING (
    segment_id = NULLIF(current_setting('app.segment_id'), '')::INTEGER
);

RESET ROLE;
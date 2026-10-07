SET ROLE app_owner;

CREATE OR REPLACE FUNCTION app.set_session_ctx(
    segment_id INTEGER,
    actor_id INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM app.employees
        WHERE id = actor_id AND postal_object_id = segment_id
    ) THEN
        PERFORM set_config('app.segment_id', NULL::TEXT, false);
        RETURN false;
    END IF;

    PERFORM set_config('app.segment_id', segment_id::TEXT, false);
    RETURN true;
END;
$$;

RESET ROLE;
SET ROLE app_owner;

CREATE FUNCTION app.get_segment_id()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
    DECLARE segment_id TEXT;
BEGIN
    segment_id := current_setting('app.segment_id', true);

    IF segment_id IS NULL OR segment_id = '' THEN
        RAISE EXCEPTION 'Параметр app.segment_id в текущей сессии не установлен';
    END IF;

    RETURN segment_id;
END;
$$;

RESET ROLE;
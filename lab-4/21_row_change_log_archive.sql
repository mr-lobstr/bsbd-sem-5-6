SET ROLE app_owner;

CREATE TABLE audit.row_change_log_archive (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL DEFAULT current_user,
    table_name VARCHAR(50) NOT NULL,
    change_timestamp  TIMESTAMP NOT NULL DEFAULT NOW(),
    old_data JSONB,
    new_data JSONB
);

COMMENT ON TABLE audit.row_change_log_archive
IS 'Архив изменений строк в ключевых таблицах';


CREATE PROCEDURE audit.backup_audit_logs(days_interval INT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = audit
AS $$
BEGIN
    WITH moved_rows AS (
        DELETE FROM audit.row_change_log
        WHERE (NOW() - change_timestamp) >= (days_interval || ' days')::INTERVAL
        RETURNING *
    )
    INSERT INTO audit.row_change_log_archive
    SELECT *
    FROM moved_rows;
END;
$$;

RESET ROLE;

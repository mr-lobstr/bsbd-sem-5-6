SET ROLE app_owner;

CREATE FUNCTION app.check_password_change_permission()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM app.password_change_requests pcr
        WHERE pcr.requester_id = NEW.employee_id
            AND pcr.approved
            AND NOW() < pcr.expiried_at
            AND NOT closed
    ) THEN
        RAISE EXCEPTION
            'Смена пароля сотрудником (id=%) не одобрена администратором',
            NEW.employee_id;
    END IF;

    UPDATE app.password_change_requests pcr
    SET closed = TRUE
    WHERE pcr.requester_id = NEW.employee_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_password_change_permission_trg
BEFORE UPDATE
OF password_hash ON app.employees_credentials
FOR EACH ROW
EXECUTE FUNCTION app.check_password_change_permission();

RESET ROLE;
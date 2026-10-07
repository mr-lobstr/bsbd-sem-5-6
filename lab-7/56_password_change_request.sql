SET ROLE app_owner;

CREATE PROCEDURE app.password_change_request(requester_id_ INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO app.password_change_requests (
        requester_id
    ) VALUES (
        requester_id_
    );
END;
$$;


CREATE PROCEDURE app.password_change_approve(
    requester_id_ INTEGER,
    approver_id_ INTEGER,
    exp_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM app.employees_credentials ec
        WHERE ec.employee_id = approver_id_
            AND ec.is_admin
    ) THEN
        RAISE EXCEPTION 'Сотрудник (id=%) не является администратором', approver_id_;
    END IF;

    UPDATE app.password_change_requests pcr
    SET
        approved = TRUE,
        approver_id = approver_id_,
        approved_at = NOW(),
        expiried_at = exp_at
    WHERE pcr.requester_id = requester_id_;
END;
$$;

RESET ROLE;
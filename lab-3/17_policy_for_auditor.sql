SET ROLE postgres;

GRANT USAGE ON SCHEMA app TO auditor;

GRANT SELECT ON ALL TABLES IN SCHEMA app TO auditor;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app
GRANT SELECT ON TABLES TO auditor;


SET ROLE app_owner;

CREATE POLICY su_auditor_client_addresses_select_rls
ON app.client_addresses
FOR SELECT
USING (current_user = 'auditor');

CREATE POLICY su_auditor_clients_select_rls
ON app.clients
FOR SELECT
USING (current_user = 'auditor');

CREATE POLICY su_auditor_packages_select_rls
ON app.packages
FOR SELECT
USING (current_user = 'auditor');

CREATE POLICY su_auditor_status_history_select_rls
ON app.status_history
FOR SELECT
USING (current_user = 'auditor');

CREATE POLICY su_auditor_movement_history_select_rls
ON app.movement_history
FOR SELECT
USING (current_user = 'auditor');

RESET ROLE;
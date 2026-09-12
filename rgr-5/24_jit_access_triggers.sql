SET ROLE postgres;

CREATE TRIGGER check_jit_for_packges_triggers
BEFORE INSERT
    OR UPDATE
    OR DELETE
ON app.packages
FOR EACH STATEMENT
EXECUTE FUNCTION app.check_jit_access();

CREATE TRIGGER check_jit_for_client_addresses_triggers
BEFORE INSERT
    OR UPDATE
    OR DELETE
ON app.client_addresses
FOR EACH STATEMENT
EXECUTE FUNCTION app.check_jit_access();

RESET ROLE;
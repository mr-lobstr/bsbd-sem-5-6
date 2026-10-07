SELECT relname, relfilenode, oid
FROM pg_class
WHERE relname IN ('pg_authid', 'pg_authid_fsm', 'pg_authid_vm');


SHOW password_encryption;


SET password_encryption = 'md5';

CREATE ROLE test
PASSWORD 'test_password';

SELECT *
FROM pg_catalog.pg_authid;

SET password_encryption = 'scram-sha-256';

-- https://postgrespro.ru/docs/postgresql/18/auth-password
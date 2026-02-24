SET ROLE postgres;

CREATE ROLE app_owner WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

ALTER SCHEMA app OWNER TO app_owner;
ALTER SCHEMA ref OWNER TO app_owner;
ALTER SCHEMA stg OWNER TO app_owner;
ALTER SCHEMA audit OWNER TO app_owner;

COMMENT ON ROLE app_owner IS 'Владелец объектов БД';


CREATE ROLE security_admin WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    CREATEROLE;

GRANT USAGE ON SCHEMA app, ref, stg, audit TO security_admin;

COMMENT ON ROLE security_admin IS 'Администратор безопасности';


CREATE ROLE ddl_admin WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

GRANT USAGE, CREATE ON SCHEMA app TO ddl_admin;
GRANT USAGE, CREATE ON SCHEMA ref TO ddl_admin;
GRANT USAGE, CREATE ON SCHEMA stg TO ddl_admin;

GRANT REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA app, ref, stg
TO ddl_admin;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner
IN SCHEMA app, ref, stg
GRANT REFERENCES, TRIGGER ON TABLES TO ddl_admin;

COMMENT ON ROLE ddl_admin IS 'Администратор структуры БД';


CREATE ROLE dml_admin WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

GRANT USAGE ON SCHEMA app, ref, stg TO dml_admin;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN SCHEMA app, ref, stg TO dml_admin;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA app, ref, stg TO dml_admin;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app, ref, stg
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO dml_admin;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app, ref, stg
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO dml_admin;

COMMENT ON ROLE dml_admin IS 'Администратор данных БД';


CREATE ROLE auditor WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

GRANT USAGE ON SCHEMA audit TO auditor;

GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner
IN SCHEMA audit
GRANT SELECT ON TABLES TO auditor;

COMMENT ON ROLE auditor IS 'Роль для проведения аудита';


CREATE ROLE app_writer WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

GRANT USAGE ON SCHEMA app, ref TO app_writer;

GRANT USAGE
ON ALL SEQUENCES IN SCHEMA app, ref TO app_writer;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA app, ref TO app_writer;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app, ref
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app, ref
GRANT USAGE ON SEQUENCES TO app_writer;

COMMENT ON ROLE app_writer IS 'Роль для изменения данных в таблицах БД';


CREATE ROLE app_reader WITH
    LOGIN
    PASSWORD 'pass'
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

GRANT USAGE ON SCHEMA app, ref TO app_reader;

GRANT SELECT
ON ALL TABLES IN SCHEMA app, ref TO app_reader;

ALTER DEFAULT PRIVILEGES
FOR ROLE app_owner, ddl_admin
IN SCHEMA app, ref
GRANT SELECT ON TABLES TO app_reader;

COMMENT ON ROLE app_reader IS 'Роль для чтения данных из таблиц БД';

RESET ROLE;
SET ROLE postgres;

CREATE SCHEMA IF NOT EXISTS ref;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA app IS 'Бизнес-данные';
COMMENT ON SCHEMA ref IS 'Справочные данные';
COMMENT ON SCHEMA stg IS 'Временные и технические таблицы';
COMMENT ON SCHEMA audit IS 'Журналы действий и безопасности';

REVOKE ALL ON SCHEMA public, app, ref, stg, audit FROM PUBLIC;

RESET ROLE;
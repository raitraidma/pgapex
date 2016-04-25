SET client_min_messages TO WARNING;

DROP OWNED BY :DB_APP_USER;
DROP USER IF EXISTS :DB_APP_USER;
CREATE USER :DB_APP_USER WITH LOGIN PASSWORD ':DB_APP_USER_PASS';

-- Revoke permissions from PUBLIC
REVOKE ALL PRIVILEGES ON DATABASE :DB_DATABASE FROM PUBLIC;
REVOKE ALL PRIVILEGES ON SCHEMA pgapex FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA pgapex FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA pgapex FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA pgapex FROM PUBLIC;

-- Revoke permissions from :DB_APP_USER
REVOKE ALL PRIVILEGES ON DATABASE :DB_DATABASE FROM :DB_APP_USER;
REVOKE ALL PRIVILEGES ON SCHEMA pgapex FROM :DB_APP_USER;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA pgapex FROM :DB_APP_USER;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA pgapex FROM :DB_APP_USER;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA pgapex FROM :DB_APP_USER;

GRANT CONNECT ON DATABASE :DB_DATABASE TO :DB_APP_USER;
GRANT USAGE ON SCHEMA pgapex TO :DB_APP_USER;

GRANT EXECUTE ON FUNCTION
  pgapex.f_is_superuser(VARCHAR, VARCHAR)
, pgapex.f_user_exists(VARCHAR, VARCHAR)
, pgapex.f_refresh_database_objects()
-- APPLICATION --
, pgapex.f_application_get_applications()
, pgapex.f_application_get_application(pgapex.application.application_id%TYPE)
, pgapex.f_application_delete_application(pgapex.application.application_id%TYPE)
, pgapex.f_application_get_application_authentication(pgapex.application.application_id%TYPE)
, pgapex.f_application_application_may_have_an_alias(pgapex.application.application_id%TYPE, pgapex.application.alias%TYPE)
, pgapex.f_application_save_application(pgapex.application.application_id%TYPE, pgapex.application.name%TYPE, pgapex.application.alias%TYPE, pgapex.application.database_name%TYPE, pgapex.application.database_username%TYPE, pgapex.application.database_password%TYPE)
, pgapex.f_application_save_application_authentication(pgapex.application.application_id%TYPE, pgapex.application.authentication_scheme_id%TYPE, pgapex.application.authentication_function_schema_name%TYPE, pgapex.application.authentication_function_name%TYPE, pgapex.application.login_page_template_id%TYPE)
-- DATABASE OBJECT --
, pgapex.f_database_object_get_databases()
, pgapex.f_database_object_get_authentication_functions(pgapex.application.application_id%TYPE)
-- TEMPLATE --
, pgapex.f_template_get_login_templates()
TO :DB_APP_USER;
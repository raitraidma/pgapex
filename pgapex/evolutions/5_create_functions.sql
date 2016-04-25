SET client_min_messages TO WARNING;

CREATE OR REPLACE FUNCTION pgapex.f_is_superuser(
  username VARCHAR
, password VARCHAR
)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1
    FROM pg_catalog.pg_shadow
    WHERE usename = $1
      AND (passwd = 'md5' || md5($2 || $1)
        OR passwd IS NULL
      )
      AND usesuper = TRUE
      AND (valuntil IS NULL
        OR valuntil > current_timestamp
      )
  );
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_user_exists(
  username VARCHAR
, password VARCHAR
)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1
    FROM pg_catalog.pg_shadow
    WHERE usename = $1
      AND (passwd = 'md5' || md5($2 || $1)
        OR passwd IS NULL
      )
      AND (valuntil IS NULL
        OR valuntil > current_timestamp
      )
  );
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;
--------------------------------
---------- APPLICATION ----------
--------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_application_get_applications()
RETURNS json AS $$
  SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      application_id AS id
    , 'application' AS type
    , json_build_object(
        'alias', alias
      , 'name', name
    ) AS attributes
    FROM pgapex.application
  ) a
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_get_application(
  i_id    pgapex.application.application_id%TYPE
)
  RETURNS json AS $$
SELECT
  json_build_object(
      'id', application_id
      , 'type', 'application'
      , 'attributes', json_build_object(
          'name', name
          , 'alias', alias
          , 'database', database_name
          , 'databaseUsername', database_username
      )
  )
FROM pgapex.application
WHERE application_id = i_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_get_application_authentication(
  i_id    pgapex.application.application_id%TYPE
)
  RETURNS json AS $$
  SELECT
  json_build_object(
    'id', application_id
  , 'type', 'application-authentication'
  , 'attributes', json_build_object(
      'authenticationScheme', authentication_scheme_id
    , 'authenticationFunction', json_build_object(
        'database', database_name
      , 'schema', authentication_function_schema_name
      , 'function', authentication_function_name
      )
    , 'loginPageTemplate', login_page_template_id
    )
  )
  FROM pgapex.application
  WHERE application_id = i_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_delete_application(
  i_id pgapex.application.application_id%TYPE
)
  RETURNS boolean AS $$
BEGIN
  DELETE FROM pgapex.application
  WHERE application_id = i_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_application_may_have_an_alias(
  i_id    pgapex.application.application_id%TYPE
, v_alias pgapex.application.alias%TYPE
)
RETURNS boolean AS $$
DECLARE
  b_alias_already_exists BOOLEAN;
BEGIN
  IF i_id IS NULL THEN
    SELECT COUNT(1) = 0 INTO b_alias_already_exists FROM pgapex.application WHERE alias = v_alias;
  ELSE
    SELECT COUNT(1) = 0 INTO b_alias_already_exists FROM pgapex.application WHERE alias = v_alias AND application_id <> i_id;
  END IF;
  RETURN b_alias_already_exists;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_save_application(
  i_id                 pgapex.application.application_id%TYPE
, v_name               pgapex.application.name%TYPE
, v_alias              pgapex.application.alias%TYPE
, v_database           pgapex.application.database_name%TYPE
, v_database_username  pgapex.application.database_username%TYPE
, v_database_password  pgapex.application.database_password%TYPE
)
RETURNS boolean AS $$
BEGIN
  IF pgapex.f_user_exists(v_database_username, v_database_password) = FALSE THEN
    RAISE EXCEPTION 'Application username and password do not match.';
  END IF;
  IF (v_alias ~* '.*[a-z].*') = FALSE OR (v_alias ~* '^\w*$') = FALSE THEN
    RAISE EXCEPTION 'Application alias must contain characters (included underscore) and may contain numbers.';
  END IF;
  IF pgapex.f_application_application_may_have_an_alias(i_id, v_alias) = FALSE THEN
    RAISE EXCEPTION 'Application alias is already taken.';
  END IF;
  IF i_id IS NULL THEN
    INSERT INTO pgapex.application (name, alias, database_name, database_username, database_password)
    VALUES (v_name, v_alias, v_database, v_database_username, v_database_password);
  ELSE
    UPDATE pgapex.application
    SET name = v_name
    ,   alias = v_alias
    ,   database_name = v_database
    ,   database_username = v_database_username
    ,   database_password = v_database_password
    WHERE application_id = i_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_application_save_application_authentication(
  i_id                                  pgapex.application.application_id%TYPE
, v_authentication_scheme               pgapex.application.authentication_scheme_id%TYPE
, v_authentication_function_schema_name pgapex.application.authentication_function_schema_name%TYPE
, v_authentication_function_name        pgapex.application.authentication_function_name%TYPE
, i_login_page_template                 pgapex.application.login_page_template_id%TYPE
)
RETURNS boolean AS $$
BEGIN
  UPDATE pgapex.application
  SET authentication_scheme_id = v_authentication_scheme
  ,   authentication_function_schema_name = v_authentication_function_schema_name
  ,   authentication_function_name = v_authentication_function_name
  ,   login_page_template_id = i_login_page_template
  WHERE application_id = i_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

-------------------------------------
---------- DATABASE OBJECT ----------
-------------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_database_object_get_databases()
RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
FROM (
       SELECT
           database_name AS id
         , 'database' AS type
         , json_build_object(
               'name', database_name
           ) AS attributes
       FROM pgapex.database
     ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_database_object_get_authentication_functions(
  i_id pgapex.application.application_id%TYPE
)
RETURNS json AS $$
  WITH boolean_functions_with_two_parameters AS (
      SELECT f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
      FROM pgapex.application a
        LEFT JOIN pgapex.function f ON a.database_name = f.database_name
        LEFT JOIN pgapex.parameter p ON (a.database_name = p.database_name AND p.schema_name = f.schema_name AND p.function_name = f.function_name)
      WHERE f.return_type = 'bool'
        AND a.application_id = $1
      GROUP BY f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
      HAVING MAX(p.ordinal_position) = 2
  )
  SELECT json_agg(
    json_build_object(
      'type', 'login-function'
    , 'attributes', json_build_object(
        'database', f.database_name
        , 'schema',   f.schema_name
        , 'function', f.function_name
      )
    )
  )
  FROM boolean_functions_with_two_parameters f
  WHERE f.parameter_type IN ('text', 'varchar')
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;


------------------------------
---------- TEMPLATE ----------
------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_login_templates()
RETURNS json AS $$
  SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'login-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.page_template pt
    LEFT JOIN pgapex.template t ON pt.template_id = t.template_id
    WHERE pt.page_type_id = 'LOGIN'
  ) a
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;
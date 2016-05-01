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
    ORDER BY name
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
  IF v_authentication_scheme = 'NO_AUTHENTICATION' THEN
    UPDATE pgapex.application
    SET authentication_scheme_id = v_authentication_scheme
      ,   authentication_function_schema_name = NULL
      ,   authentication_function_name = NULL
      ,   login_page_template_id = NULL
    WHERE application_id = i_id;
  ELSE
    UPDATE pgapex.application
    SET authentication_scheme_id = v_authentication_scheme
    ,   authentication_function_schema_name = v_authentication_function_schema_name
    ,   authentication_function_name = v_authentication_function_name
    ,   login_page_template_id = i_login_page_template
    WHERE application_id = i_id;
  END IF;
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
       ORDER BY database_name
     ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_database_object_get_authentication_functions(
  i_application_id pgapex.application.application_id%TYPE
)
RETURNS json AS $$
  WITH boolean_functions_with_two_parameters AS (
      SELECT f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
      FROM pgapex.application a
        LEFT JOIN pgapex.function f ON a.database_name = f.database_name
        LEFT JOIN pgapex.parameter p ON (a.database_name = p.database_name AND p.schema_name = f.schema_name AND p.function_name = f.function_name)
      WHERE f.return_type = 'bool'
        AND a.application_id = i_application_id
      GROUP BY f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
      HAVING MAX(p.ordinal_position) = 2
      ORDER BY f.database_name, f.schema_name, f.function_name
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

----------

CREATE OR REPLACE FUNCTION pgapex.f_database_object_get_views_with_columns(
  i_application_id pgapex.application.application_id%TYPE
)
RETURNS JSON AS $$
WITH views_with_columns AS (
    SELECT
      json_build_object(
            'id', vc.database_name || '.' || vc.schema_name || '.' || vc.view_name
          , 'type', 'view'
          , 'attributes', json_build_object(
                'schema', vc.schema_name
              , 'name', vc.view_name
              , 'columns', json_agg(
                  json_build_object(
                        'id', vc.database_name || '.' || vc.schema_name || '.' || vc.view_name || '.' || vc.column_name
                      , 'type', 'column'
                      , 'attributes', json_build_object(
                          'name', vc.column_name
                      )
                  )
              )
          )
      ) AS vwc
    FROM pgapex.application a
      LEFT JOIN pgapex.view_column vc ON a.database_name = vc.database_name
    WHERE a.application_id = i_application_id
    GROUP BY vc.database_name, vc.schema_name, vc.view_name
)
SELECT
  COALESCE(json_agg(views_with_columns.vwc), '[]')
FROM views_with_columns;
$$ LANGUAGE SQL
SECURITY DEFINER
SET search_path = pgapex, PUBLIC, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_database_object_get_functions_with_parameters(
  i_application_id pgapex.application.application_id%TYPE
)
RETURNS JSON AS $$
WITH functions_with_parameters AS (
    SELECT
      json_build_object(
            'id', p.database_specific_name
          , 'type', 'function'
          , 'attributes', json_build_object(
                'schema', p.schema_name
              , 'name', p.function_name
              , 'parameters', json_agg(
                  json_build_object(
                        'id', p.database_name || '.' || p.schema_name || '.' || p.function_name || '.' || p.ordinal_position
                      , 'type', 'parameter'
                      , 'attributes', json_build_object(
                          'name', p.parameter_name
                        , 'argumentType', p.parameter_type
                        , 'ordinalPosition', p.ordinal_position
                      )
                  )
              )
          )
      ) AS fwp
    FROM pgapex.application a
    LEFT JOIN pgapex.parameter p ON a.database_name = p.database_name
    WHERE a.application_id = i_application_id
    GROUP BY p.database_specific_name, p.database_name, p.schema_name, p.function_name
    ORDER BY p.database_name, p.schema_name, p.function_name
)
SELECT
  COALESCE(json_agg(functions_with_parameters.fwp), '[]')
FROM functions_with_parameters;
$$ LANGUAGE SQL
SECURITY DEFINER
SET search_path = pgapex, PUBLIC, pg_temp;

------------------------------
---------- TEMPLATE ----------
------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_page_templates(
  v_page_type pgapex.page_template.page_type_id%TYPE
)
RETURNS json AS $$
  SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , lower(v_page_type) || '-page-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.page_template pt
    LEFT JOIN pgapex.template t ON pt.template_id = t.template_id
    WHERE pt.page_type_id = v_page_type
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_region_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
FROM (
       SELECT
           t.template_id AS id
         , 'region-template' AS type
         , json_build_object(
               'name', t.name
           ) AS attributes
       FROM pgapex.region_template rt
         LEFT JOIN pgapex.template t ON rt.template_id = t.template_id
       ORDER BY t.name
     ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_navigation_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'navigation-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.navigation_template nt
    LEFT JOIN pgapex.template t ON nt.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_report_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'report-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.report_template rt
    LEFT JOIN pgapex.template t ON rt.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_form_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'form-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.form_template ft
    LEFT JOIN pgapex.template t ON ft.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_button_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'button-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.button_template bt
    LEFT JOIN pgapex.template t ON bt.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_textarea_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'textarea-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.textarea_template tt
    LEFT JOIN pgapex.template t ON tt.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_drop_down_templates()
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , 'drop-down-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.drop_down_template ddt
    LEFT JOIN pgapex.template t ON ddt.template_id = t.template_id
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_template_get_input_templates(
  v_input_template_type pgapex.input_template.input_template_type_id%TYPE
)
  RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      t.template_id AS id
    , lower(v_input_template_type) || '-input-template' AS type
    , json_build_object(
        'name', t.name
    ) AS attributes
    FROM pgapex.input_template it
    LEFT JOIN pgapex.template t ON it.template_id = t.template_id
    WHERE it.input_template_type_id = v_input_template_type
    ORDER BY t.name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

--------------------------
---------- PAGE ----------
--------------------------

CREATE OR REPLACE FUNCTION pgapex.f_page_get_pages(
  i_application_id pgapex.page.application_id%TYPE
)
RETURNS json AS $$
  SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      page_id AS id
    , 'page' AS type
    , json_build_object(
        'title', title
      , 'alias', alias
      , 'isHomepage', is_homepage
      , 'isAuthenticationRequired', is_authentication_required
    ) AS attributes
    FROM pgapex.page
    WHERE application_id = i_application_id
    ORDER BY title, alias
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_page_save_page(
  i_page_id                    pgapex.page.page_id%TYPE
, i_application_id             pgapex.page.application_id%TYPE
, i_template_id                pgapex.page.template_id%TYPE
, v_title                      pgapex.page.title%TYPE
, v_alias                      pgapex.page.alias%TYPE
, b_is_homepage                pgapex.page.is_homepage%TYPE
, b_is_authentication_required pgapex.page.is_authentication_required%TYPE
)
RETURNS boolean AS $$
DECLARE
  b_homepage_exists BOOLEAN;
BEGIN
  IF (v_alias ~* '.*[a-z].*') = FALSE OR (v_alias ~* '^\w*$') = FALSE THEN
    RAISE EXCEPTION 'Page alias must contain characters (included underscore) and may contain numbers.';
  END IF;
  IF b_is_homepage THEN
    UPDATE pgapex.page
    SET is_homepage = FALSE
    WHERE application_id = i_application_id;
  ELSE
    SELECT count(1) > 0 INTO b_homepage_exists
    FROM pgapex.page
    WHERE application_id = i_application_id
      AND is_homepage = TRUE
      AND page_id <> COALESCE(i_page_id, -1);
    IF b_homepage_exists = FALSE THEN
      b_is_homepage = TRUE;
    END IF;
  END IF;
  IF i_page_id IS NULL THEN
    INSERT INTO pgapex.page (application_id, template_id, title, alias, is_homepage, is_authentication_required)
    VALUES (i_application_id, i_template_id, v_title, v_alias, b_is_homepage, b_is_authentication_required);
  ELSE
    UPDATE pgapex.page
    SET application_id = i_application_id
    ,   template_id = i_template_id
    ,   title = v_title
    ,   alias = v_alias
    ,   is_homepage = b_is_homepage
    ,   is_authentication_required = b_is_authentication_required
    WHERE page_id = i_page_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_page_get_page(
  i_page_id    pgapex.page.page_id%TYPE
)
RETURNS json AS $$
  SELECT
  json_build_object(
    'id', application_id
  , 'type', 'page'
  , 'attributes', json_build_object(
      'title', title
    , 'alias', alias
    , 'template', template_id
    , 'isHomepage', is_homepage
    , 'isAuthenticationRequired', is_authentication_required
    )
  )
  FROM pgapex.page
  WHERE page_id = i_page_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_page_delete_page(
  i_page_id pgapex.page.page_id%TYPE
)
RETURNS boolean AS $$
DECLARE
  b_homepage_exists BOOLEAN;
  i_application_id INT;
BEGIN
  SELECT application_id INTO i_application_id
  FROM pgapex.page WHERE page_id = i_page_id;

  DELETE FROM pgapex.page WHERE page_id = i_page_id;

  SELECT count(1) > 0 INTO b_homepage_exists
  FROM pgapex.page
  WHERE application_id = i_application_id
        AND is_homepage = TRUE;

  IF b_homepage_exists = FALSE THEN
    UPDATE pgapex.page
    SET is_homepage = TRUE
    WHERE page_id = (
      SELECT page_id FROM pgapex.page ORDER BY is_authentication_required ASC LIMIT 1
    );
  END IF;
  RETURN TRUE;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

--------------------------------
---------- NAVIGATION ----------
--------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_get_navigations(
  i_application_id pgapex.navigation.application_id%TYPE
)
  RETURNS json AS $$
  SELECT COALESCE(JSON_AGG(a), '[]')
  FROM (
    SELECT
      navigation_id AS id
    , 'navigation' AS type
    , json_build_object(
        'name', name
    ) AS attributes
    FROM pgapex.navigation
    WHERE application_id = i_application_id
    ORDER BY name
  ) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_save_navigation(
  i_navigation_id  pgapex.navigation.navigation_id%TYPE
, i_application_id pgapex.navigation.application_id%TYPE
, v_name           pgapex.navigation.name%TYPE
)
RETURNS boolean AS $$
BEGIN
  IF i_navigation_id IS NULL THEN
    INSERT INTO pgapex.navigation (application_id, name) VALUES (i_application_id, v_name);
  ELSE
    UPDATE pgapex.navigation
    SET application_id = i_application_id
    ,   name = v_name
    WHERE navigation_id = i_navigation_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_get_navigation(
  i_navigation_id    pgapex.navigation.navigation_id%TYPE
)
  RETURNS json AS $$
  SELECT
  json_build_object(
    'id', navigation_id
  , 'type', 'navigation'
  , 'attributes', json_build_object(
      'name', name
    )
  )
  FROM pgapex.navigation
  WHERE navigation_id = i_navigation_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_delete_navigation(
  i_navigation_id pgapex.navigation.navigation_id%TYPE
)
RETURNS boolean AS $$
BEGIN
  DELETE FROM pgapex.navigation WHERE navigation_id = i_navigation_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_get_navigation_items(
  i_navigation_id pgapex.navigation_item.navigation_id%TYPE
)
RETURNS json AS $$
SELECT COALESCE(JSON_AGG(a), '[]')
FROM (
  SELECT
    ni.navigation_item_id AS id
  , 'navigation-item' AS type
  , json_build_object(
      'name', ni.name
    , 'parentNavigationItemId', ni.parent_navigation_item_id
    , 'sequence', ni.sequence
    , 'url', ni.url
    , 'page', (
        CASE
          WHEN ni.page_id IS NULL THEN NULL
          ELSE json_build_object(
              'id', ni.page_id
            , 'title', p.title
          )
        END
      )
    ) AS attributes
  FROM pgapex.navigation_item AS ni
  LEFT JOIN pgapex.page AS p ON ni.page_id = p.page_id
  WHERE ni.navigation_id = i_navigation_id
  ORDER BY ni.sequence, ni.name
) a
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_delete_navigation_item(
  i_navigation_item_id pgapex.navigation_item.navigation_item_id%TYPE
)
RETURNS boolean AS $$
BEGIN
  DELETE FROM pgapex.navigation_item WHERE navigation_item_id = i_navigation_item_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_get_navigation_item(
  i_navigation_item_id pgapex.navigation_item.navigation_item_id%TYPE
)
RETURNS json AS $$
  SELECT
  json_build_object(
    'id', navigation_id
  , 'type', 'navigation-item'
  , 'attributes', json_build_object(
      'name', name
    , 'parentNavigationItemId', parent_navigation_item_id
    , 'sequence', sequence
    , 'page', page_id
    , 'url', url
    )
  )
  FROM pgapex.navigation_item
  WHERE navigation_item_id = i_navigation_item_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_navigation_save_navigation_item(
  i_navigation_item_id         pgapex.navigation_item.navigation_item_id%TYPE
, i_parent_navigation_item_id  pgapex.navigation_item.parent_navigation_item_id%TYPE
, i_navigation_id              pgapex.navigation_item.navigation_id%TYPE
, v_name                       pgapex.navigation_item.name%TYPE
, i_sequence                   pgapex.navigation_item.sequence%TYPE
, i_page_id                    pgapex.navigation_item.page_id%TYPE
, v_url                        pgapex.navigation_item.url%TYPE
)
RETURNS boolean AS $$
BEGIN
  IF i_navigation_item_id IS NULL THEN
    INSERT INTO pgapex.navigation_item (parent_navigation_item_id, navigation_id, name, sequence, page_id, url)
    VALUES (i_parent_navigation_item_id, i_navigation_id, v_name, i_sequence, i_page_id, v_url);
  ELSE
    UPDATE pgapex.navigation_item
    SET parent_navigation_item_id = i_parent_navigation_item_id
    ,   navigation_id = i_navigation_id
    ,   name = v_name
    ,   sequence = i_sequence
    ,   page_id = i_page_id
    ,   url = v_url
    WHERE navigation_item_id = i_navigation_item_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------------------------
---------- REGION ----------
----------------------------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_display_points_with_regions(
  i_page_id pgapex.page.page_id%TYPE
)
RETURNS json AS $$
  SELECT json_agg(json_build_object(
      'id', ptdp.page_template_display_point_id
    , 'type', 'page-template-display-point'
    , 'attributes', json_build_object(
          'displayPointName', ptdp.display_point_id
        , 'description', ptdp.description
        , 'regions', (
          SELECT coalesce(json_agg(json_build_object(
               'id', r.region_id
             , 'type', 'region'
             , 'attributes', json_build_object(
                   'name', r.name
                 , 'sequence', r.sequence
                 , 'isVisible', r.is_visible
                 , 'type', (
                   CASE
                     WHEN hr.region_id IS NOT NULL THEN 'HTML'
                     WHEN nr.region_id IS NOT NULL THEN 'NAVIGATION'
                     WHEN fr.region_id IS NOT NULL THEN 'FORM'
                     WHEN rr.region_id IS NOT NULL THEN 'REPORT'
                     ELSE 'UNKNOWN'
                   END
                 )
             )
           )), '[]')
          FROM pgapex.region r
            LEFT JOIN pgapex.html_region hr ON r.region_id = hr.region_id
            LEFT JOIN pgapex.navigation_region nr ON r.region_id = nr.region_id
            LEFT JOIN pgapex.form_region fr ON r.region_id = fr.region_id
            LEFT JOIN pgapex.report_region rr ON r.region_id = rr.region_id
          WHERE r.page_template_display_point_id = ptdp.page_template_display_point_id
                AND r.page_id = p.page_id
        )
    )
  ))
  FROM pgapex.page p
    LEFT JOIN pgapex.page_template pt ON p.template_id = pt.template_id
    LEFT JOIN pgapex.page_template_display_point ptdp ON pt.template_id = ptdp.page_template_id
  WHERE p.page_id = i_page_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_region(
  i_region_id pgapex.region.region_id%TYPE
)
RETURNS json AS $$
DECLARE
  j_result JSON;
BEGIN
  IF (SELECT EXISTS (SELECT 1 FROM pgapex.html_region WHERE region_id = i_region_id)) = TRUE THEN
    SELECT pgapex.f_region_get_html_region(i_region_id) INTO j_result;
  ELSIF (SELECT EXISTS (SELECT 1 FROM pgapex.navigation_region WHERE region_id = i_region_id)) = TRUE THEN
    SELECT pgapex.f_region_get_navigation_region(i_region_id) INTO j_result;
  ELSIF (SELECT EXISTS (SELECT 1 FROM pgapex.report_region WHERE region_id = i_region_id)) = TRUE THEN
    SELECT pgapex.f_region_get_report_region(i_region_id) INTO j_result;
  ELSIF (SELECT EXISTS (SELECT 1 FROM pgapex.form_region WHERE region_id = i_region_id)) = TRUE THEN
    SELECT pgapex.f_region_get_form_region(i_region_id) INTO j_result;
  END IF;
  RETURN j_result;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_delete_region(
  i_region_id pgapex.region.region_id%TYPE
)
RETURNS boolean AS $$
BEGIN
  DELETE FROM pgapex.region WHERE region_id = i_region_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_html_region(
    i_region_id                      pgapex.region.region_id%TYPE
  , i_page_id                        pgapex.region.page_id%TYPE
  , i_region_template_id             pgapex.region.template_id%TYPE
  , i_page_template_display_point_id pgapex.region.page_template_display_point_id%TYPE
  , v_name                           pgapex.region.name%TYPE
  , i_sequence                       pgapex.region.sequence%TYPE
  , b_is_visible                     pgapex.region.is_visible%TYPE
  , t_content                        pgapex.html_region.content%TYPE
)
  RETURNS boolean AS $$
DECLARE
  i_new_region_id INT;
BEGIN
  IF i_region_id IS NULL THEN
    SELECT nextval('pgapex.region_region_id_seq') INTO i_new_region_id;

    INSERT INTO pgapex.region (region_id, page_id, template_id, page_template_display_point_id, name, sequence, is_visible)
    VALUES (i_new_region_id, i_page_id, i_region_template_id, i_page_template_display_point_id, v_name, i_sequence, b_is_visible);

    INSERT INTO pgapex.html_region (region_id, content)
    VALUES (i_new_region_id, t_content);
  ELSE
    UPDATE pgapex.region
    SET page_id = i_page_id
    ,   template_id = i_region_template_id
    ,   page_template_display_point_id = i_page_template_display_point_id
    ,   name = v_name
    ,   sequence = i_sequence
    ,   is_visible = b_is_visible
    WHERE region_id = i_region_id;

    UPDATE pgapex.html_region
    SET content = t_content
    WHERE region_id = i_region_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_html_region(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS json AS $$
  SELECT
  json_build_object(
    'id', r.region_id
  , 'type', 'html-region'
  , 'attributes', json_build_object(
      'name', r.name
    , 'sequence', r.sequence
    , 'regionTemplate', r.template_id
    , 'isVisible', r.is_visible
    , 'content', hr.content
    )
  )
  FROM pgapex.region r
  LEFT JOIN pgapex.html_region hr ON r.region_id = hr.region_id
  WHERE r.region_id = i_region_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_navigation_region(
  i_region_id                      pgapex.region.region_id%TYPE
, i_page_id                        pgapex.region.page_id%TYPE
, i_region_template_id             pgapex.region.template_id%TYPE
, i_page_template_display_point_id pgapex.region.page_template_display_point_id%TYPE
, v_name                           pgapex.region.name%TYPE
, i_sequence                       pgapex.region.sequence%TYPE
, b_is_visible                     pgapex.region.is_visible%TYPE
, i_navigation_type_id             pgapex.navigation_region.navigation_type_id%TYPE
, i_navigation_id                  pgapex.navigation_region.navigation_id%TYPE
, i_navigation_template_id         pgapex.navigation_region.template_id%TYPE
, b_repeat_last_level              pgapex.navigation_region.repeat_last_level%TYPE
)
  RETURNS boolean AS $$
DECLARE
  i_new_region_id INT;
BEGIN
  IF i_region_id IS NULL THEN
    SELECT nextval('pgapex.region_region_id_seq') INTO i_new_region_id;

    INSERT INTO pgapex.region (region_id, page_id, template_id, page_template_display_point_id, name, sequence, is_visible)
    VALUES (i_new_region_id, i_page_id, i_region_template_id, i_page_template_display_point_id, v_name, i_sequence, b_is_visible);

    INSERT INTO pgapex.navigation_region (region_id, navigation_type_id, navigation_id, template_id, repeat_last_level)
    VALUES (i_new_region_id, i_navigation_type_id, i_navigation_id, i_navigation_template_id, b_repeat_last_level);
  ELSE
    UPDATE pgapex.region
    SET page_id = i_page_id
    ,   template_id = i_region_template_id
    ,   page_template_display_point_id = i_page_template_display_point_id
    ,   name = v_name
    ,   sequence = i_sequence
    ,   is_visible = b_is_visible
    WHERE region_id = i_region_id;

    UPDATE pgapex.navigation_region
    SET navigation_type_id = i_navigation_type_id
      , navigation_id = i_navigation_id
      , template_id = i_navigation_template_id
      , repeat_last_level = b_repeat_last_level
    WHERE region_id = i_region_id;
  END IF;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_navigation_region(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS json AS $$
  SELECT
  json_build_object(
    'id', r.region_id
  , 'type', 'navigation-region'
  , 'attributes', json_build_object(
      'name', r.name
    , 'sequence', r.sequence
    , 'regionTemplate', r.template_id
    , 'isVisible', r.is_visible

    , 'navigationTemplate', nr.template_id
    , 'navigationType', nr.navigation_type_id
    , 'navigation', nr.navigation_id
    , 'repeatLastLevel', nr.repeat_last_level
    )
  )
  FROM pgapex.region r
  LEFT JOIN pgapex.navigation_region nr ON r.region_id = nr.region_id
  WHERE r.region_id = i_region_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_report_region(
    i_region_id                      pgapex.region.region_id%TYPE
  , i_page_id                        pgapex.region.page_id%TYPE
  , i_region_template_id             pgapex.region.template_id%TYPE
  , i_page_template_display_point_id pgapex.region.page_template_display_point_id%TYPE
  , v_name                           pgapex.region.name%TYPE
  , i_sequence                       pgapex.region.sequence%TYPE
  , b_is_visible                     pgapex.region.is_visible%TYPE
  , i_report_template_id             pgapex.report_region.template_id%TYPE
  , v_schema_name                    pgapex.report_region.schema_name%TYPE
  , v_view_name                      pgapex.report_region.view_name%TYPE
  , i_items_per_page                 pgapex.report_region.items_per_page%TYPE
  , b_show_header                    pgapex.report_region.show_header%TYPE
  , v_pagination_query_parameter     pgapex.page_item.name%TYPE
)
  RETURNS int AS $$
DECLARE
  i_new_region_id INT;
BEGIN
  IF i_region_id IS NULL THEN
    SELECT nextval('pgapex.region_region_id_seq') INTO i_new_region_id;

    INSERT INTO pgapex.region (region_id, page_id, template_id, page_template_display_point_id, name, sequence, is_visible)
    VALUES (i_new_region_id, i_page_id, i_region_template_id, i_page_template_display_point_id, v_name, i_sequence, b_is_visible);

    INSERT INTO pgapex.report_region (region_id, template_id, schema_name, view_name, items_per_page, show_header)
    VALUES (i_new_region_id, i_report_template_id, v_schema_name, v_view_name, i_items_per_page, b_show_header);

    INSERT INTO pgapex.page_item (page_id, region_id, name) VALUES (i_page_id, i_new_region_id, v_pagination_query_parameter);
    RETURN i_new_region_id;
  ELSE
    UPDATE pgapex.region
    SET page_id = i_page_id
    ,   template_id = i_region_template_id
    ,   page_template_display_point_id = i_page_template_display_point_id
    ,   name = v_name
    ,   sequence = i_sequence
    ,   is_visible = b_is_visible
    WHERE region_id = i_region_id;

    UPDATE pgapex.report_region
    SET template_id = i_report_template_id
      , schema_name = v_schema_name
      , view_name = v_view_name
      , items_per_page = i_items_per_page
      , show_header = b_show_header
    WHERE region_id = i_region_id;

    UPDATE pgapex.page_item
    SET name = v_pagination_query_parameter;
    RETURN i_region_id;
  END IF;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_delete_report_region_columns(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS boolean AS $$
BEGIN
  DELETE FROM pgapex.report_column WHERE region_id = i_region_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_create_report_region_column(
    i_region_id             pgapex.report_column.region_id%TYPE
  , v_view_column_name      pgapex.report_column.view_column_name%TYPE
  , v_heading               pgapex.report_column.heading%TYPE
  , i_sequence              pgapex.report_column.sequence%TYPE
  , b_is_text_escaped       pgapex.report_column.is_text_escaped%TYPE
)
  RETURNS boolean AS $$
DECLARE
  i_new_report_column_id INT;
BEGIN
  SELECT nextval('pgapex.report_column_report_column_id_seq') INTO i_new_report_column_id;
  INSERT INTO pgapex.report_column (report_column_id, region_id, report_column_type_id, view_column_name, heading, sequence, is_text_escaped)
    VALUES (i_new_report_column_id, i_region_id, 'COLUMN', v_view_column_name, v_heading, i_sequence, b_is_text_escaped);
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_create_report_region_link(
    i_region_id             pgapex.report_column.region_id%TYPE
  , v_heading               pgapex.report_column.heading%TYPE
  , i_sequence              pgapex.report_column.sequence%TYPE
  , b_is_text_escaped       pgapex.report_column.is_text_escaped%TYPE
  , v_url                   pgapex.report_column_link.url%TYPE
  , v_link_text             pgapex.report_column_link.link_text%TYPE
  , v_attributes            pgapex.report_column_link.attributes%TYPE
)
  RETURNS boolean AS $$
DECLARE
  i_new_report_column_id INT;
BEGIN
  SELECT nextval('pgapex.report_column_report_column_id_seq') INTO i_new_report_column_id;
  INSERT INTO pgapex.report_column (report_column_id, region_id, report_column_type_id, heading, sequence, is_text_escaped)
    VALUES (i_new_report_column_id, i_region_id, 'LINK', v_heading, i_sequence, b_is_text_escaped);
  INSERT INTO pgapex.report_column_link (report_column_id, url, link_text, attributes)
    VALUES (i_new_report_column_id, v_url, v_link_text, v_attributes);
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_report_region(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS json AS $$
  SELECT
    json_build_object(
          'id', r.region_id
        , 'type', 'report-region'
        , 'attributes', json_build_object(
              'name', r.name
            , 'sequence', r.sequence
            , 'regionTemplate', r.template_id
            , 'isVisible', r.is_visible

            , 'reportTemplate', rr.template_id
            , 'schemaName', rr.schema_name
            , 'viewName', rr.view_name
            , 'showHeader', rr.show_header
            , 'itemsPerPage', rr.items_per_page
            , 'paginationQueryParameter', pi.name
            , 'reportColumns', json_agg(
                CASE
                WHEN rcl.report_column_link_id IS NULL THEN
                  json_build_object(
                        'id', rc.report_column_id
                      , 'type', 'report-column'
                      , 'attributes', json_build_object(
                          'type', 'COLUMN'
                          , 'isTextEscaped', rc.is_text_escaped
                          , 'heading', rc.heading
                          , 'sequence', rc.sequence
                          , 'column', rc.view_column_name
                      )
                  )
                ELSE
                  json_build_object(
                        'id', rc.report_column_id
                      , 'type', 'report-link'
                      , 'attributes', json_build_object(
                            'type', 'LINK'
                          , 'isTextEscaped', rc.is_text_escaped
                          , 'heading', rc.heading
                          , 'sequence', rc.sequence
                          , 'linkUrl', rcl.url
                          , 'linkText', rcl.link_text
                          , 'linkAttributes', rcl.attributes
                      )
                  )
                END
            )
        )
    )
  FROM pgapex.region r
    LEFT JOIN pgapex.report_region rr ON r.region_id = rr.region_id
    LEFT JOIN pgapex.page_item pi ON pi.region_id = rr.region_id
    LEFT JOIN pgapex.report_column rc ON rc.region_id = rr.region_id
    LEFT JOIN pgapex.report_column_link rcl ON rcl.report_column_id = rc.report_column_id
  WHERE r.region_id = i_region_id
  GROUP BY r.region_id, r.name, r.sequence, r.template_id, r.is_visible,
    rr.template_id, rr.schema_name, rr.view_name, rr.show_header,
    rr.items_per_page, pi.name
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_delete_form_pre_fill_and_form_field(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS boolean AS $$
DECLARE
  i_form_pre_fill_id INT;
BEGIN
  SELECT form_pre_fill_id INTO i_form_pre_fill_id FROM pgapex.form_region WHERE region_id = i_region_id;
  IF i_form_pre_fill_id IS NOT NULL THEN
    DELETE FROM pgapex.form_pre_fill WHERE form_pre_fill_id = i_form_pre_fill_id;
  END IF;
  DELETE FROM pgapex.form_field WHERE region_id = i_region_id;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_form_region(
    i_region_id                      pgapex.region.region_id%TYPE
  , i_page_id                        pgapex.region.page_id%TYPE
  , i_region_template_id             pgapex.region.template_id%TYPE
  , i_page_template_display_point_id pgapex.region.page_template_display_point_id%TYPE
  , v_name                           pgapex.region.name%TYPE
  , i_sequence                       pgapex.region.sequence%TYPE
  , b_is_visible                     pgapex.region.is_visible%TYPE
  , i_form_pre_fill_id               pgapex.form_region.form_pre_fill_id%TYPE
  , i_form_template_id               pgapex.form_region.template_id%TYPE
  , i_button_template_id             pgapex.form_region.button_template_id%TYPE
  , v_schema_name                    pgapex.form_region.schema_name%TYPE
  , v_function_name                  pgapex.form_region.function_name%TYPE
  , v_button_label                   pgapex.form_region.button_label%TYPE
  , v_success_message                pgapex.form_region.success_message%TYPE
  , v_error_message                  pgapex.form_region.error_message%TYPE
  , v_redirect_url                   pgapex.form_region.redirect_url%TYPE
)
  RETURNS int AS $$
DECLARE
  i_new_region_id INT;
BEGIN
  IF i_region_id IS NULL THEN
    SELECT nextval('pgapex.region_region_id_seq') INTO i_new_region_id;

    INSERT INTO pgapex.region (region_id, page_id, template_id, page_template_display_point_id, name, sequence, is_visible)
    VALUES (i_new_region_id, i_page_id, i_region_template_id, i_page_template_display_point_id, v_name, i_sequence, b_is_visible);

    INSERT INTO pgapex.form_region (region_id, form_pre_fill_id, template_id, button_template_id, schema_name, function_name, button_label, success_message, error_message, redirect_url)
    VALUES (i_new_region_id, i_form_pre_fill_id, i_form_template_id, i_button_template_id, v_schema_name, v_function_name, v_button_label, v_success_message, v_error_message, v_redirect_url);

    RETURN i_new_region_id;
  ELSE
    UPDATE pgapex.region
    SET page_id = i_page_id
    ,   template_id = i_region_template_id
    ,   page_template_display_point_id = i_page_template_display_point_id
    ,   name = v_name
    ,   sequence = i_sequence
    ,   is_visible = b_is_visible
    WHERE region_id = i_region_id;

    UPDATE pgapex.form_region
    SET form_pre_fill_id   = i_form_pre_fill_id
      , template_id        = i_form_template_id
      , button_template_id = i_button_template_id
      , schema_name        = v_schema_name
      , function_name      = v_function_name
      , button_label       = v_button_label
      , success_message    = v_success_message
      , error_message      = v_error_message
      , redirect_url       = v_redirect_url
    WHERE region_id = i_region_id;
    RETURN i_region_id;
  END IF;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_form_pre_fill(
    v_schema_name pgapex.form_pre_fill.schema_name%TYPE
  , v_view_name   pgapex.form_pre_fill.view_name%TYPE
)
  RETURNS int AS $$
DECLARE
  i_new_form_pre_fill_id INT;
BEGIN
  SELECT nextval('pgapex.form_pre_fill_form_pre_fill_id_seq') INTO i_new_form_pre_fill_id;
  INSERT INTO pgapex.form_pre_fill (form_pre_fill_id, schema_name, view_name)
  VALUES (i_new_form_pre_fill_id, v_schema_name, v_view_name);
  RETURN i_new_form_pre_fill_id;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_fetch_row_condition(
    i_form_pre_fill_id pgapex.fetch_row_condition.form_pre_fill_id%TYPE
  , i_region_id        pgapex.region.region_id%TYPE
  , v_url_parameter    pgapex.page_item.name%TYPE
  , v_view_column_name pgapex.fetch_row_condition.view_column_name%TYPE
)
RETURNS void AS $$
  INSERT INTO pgapex.fetch_row_condition (form_pre_fill_id, url_parameter_id, view_column_name)
  VALUES (i_form_pre_fill_id, (
    SELECT pi.page_item_id
    FROM pgapex.region r
    LEFT JOIN pgapex.page_item pi ON pi.page_id = r.page_id
    WHERE r.region_id = i_region_id
      AND pi.name = v_url_parameter
  ), v_view_column_name);
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_form_field(
    i_region_id                           pgapex.form_field.region_id%TYPE
  , v_field_type_id                       pgapex.form_field.field_type_id%TYPE
  , i_list_of_values_id                   pgapex.form_field.list_of_values_id%TYPE
  , i_form_field_template_id              pgapex.template.template_id%TYPE
  , v_field_pre_fill_view_column_name     pgapex.form_field.field_pre_fill_view_column_name%TYPE
  , v_form_element_name                   pgapex.page_item.name%TYPE
  , v_label                               pgapex.form_field.label%TYPE
  , i_sequence                            pgapex.form_field.sequence%TYPE
  , b_is_mandatory                        pgapex.form_field.is_mandatory%TYPE
  , b_is_visible                          pgapex.form_field.is_visible%TYPE
  , v_default_value                       pgapex.form_field.default_value%TYPE
  , v_help_text                           pgapex.form_field.help_text%TYPE
  , v_function_parameter_type             pgapex.form_field.function_parameter_type%TYPE
  , v_function_parameter_ordinal_position pgapex.form_field.function_parameter_ordinal_position%TYPE
)
RETURNS void AS $$
DECLARE
  i_new_form_field_id INT;
  i_page_id INT;
BEGIN
  SELECT nextval('pgapex.form_field_form_field_id_seq') INTO i_new_form_field_id;
  SELECT page_id INTO i_page_id FROM pgapex.region WHERE region_id = i_region_id;

  INSERT INTO pgapex.form_field (form_field_id, region_id, field_type_id, list_of_values_id, input_template_id, drop_down_template_id, textarea_template_id,
                                 field_pre_fill_view_column_name, label, sequence, is_mandatory, is_visible, default_value, help_text,
                                 function_parameter_type, function_parameter_ordinal_position
  )
  VALUES (i_new_form_field_id, i_region_id, v_field_type_id, i_list_of_values_id, (
    CASE
      WHEN v_field_type_id IN ('TEXT', 'PASSWORD', 'RADIO', 'CHECKBOX') THEN i_form_field_template_id
      ELSE NULL
    END
  ), (
    CASE
    WHEN v_field_type_id = 'DROP_DOWN' THEN i_form_field_template_id
    ELSE NULL
    END
  ), (
    CASE
    WHEN v_field_type_id = 'TEXTAREA' THEN i_form_field_template_id
    ELSE NULL
    END
  ),
  v_field_pre_fill_view_column_name, v_label, i_sequence, b_is_mandatory, b_is_visible, v_default_value, v_help_text,
  v_function_parameter_type, v_function_parameter_ordinal_position);

  INSERT INTO pgapex.page_item (page_id, form_field_id, name) VALUES (i_page_id, i_new_form_field_id, v_form_element_name);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_save_list_of_values(
  v_value_view_column_name pgapex.list_of_values.value_view_column_name%TYPE
, v_label_view_column_name pgapex.list_of_values.label_view_column_name%TYPE
, v_view_name              pgapex.list_of_values.view_name%TYPE
, v_schema_name            pgapex.list_of_values.schema_name%TYPE
)
  RETURNS int AS $$
DECLARE
  i_new_list_of_values_id INT;
BEGIN
  SELECT nextval('pgapex.list_of_values_list_of_values_id_seq') INTO i_new_list_of_values_id;
  INSERT INTO pgapex.list_of_values (list_of_values_id, value_view_column_name, label_view_column_name, view_name, schema_name)
  VALUES (i_new_list_of_values_id, v_value_view_column_name, v_label_view_column_name, v_view_name, v_schema_name);
  RETURN i_new_list_of_values_id;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_region_get_form_region(
  i_region_id pgapex.region.region_id%TYPE
)
  RETURNS json AS $$
  SELECT
    json_build_object(
          'id', r.region_id
        , 'type', 'form-region'
        , 'attributes', json_build_object(
              'name', r.name
            , 'sequence', r.sequence
            , 'regionTemplate', r.template_id
            , 'isVisible', r.is_visible

            , 'formTemplate', fr.template_id
            , 'buttonTemplate', fr.button_template_id
            , 'buttonLabel', fr.button_label
            , 'successMessage', fr.success_message
            , 'errorMessage', fr.error_message
            , 'redirectUrl', fr.redirect_url
            , 'function', json_build_object(
                'type', 'function'
              , 'attributes', json_build_object(
                  'schema', fr.schema_name
                , 'name', fr.function_name
                )
              )
            , 'formPreFill', (fr.form_pre_fill_id IS NOT NULL)
            , 'formPreFillView', json_build_object(
                'id', fpf.form_pre_fill_id
              , 'type', 'form-pre-fill'
              , 'attributes', json_build_object(
                  'schema', fpf.schema_name
                , 'name', fpf.view_name
                )
              )
            , 'formPreFillColumns', (SELECT json_agg(json_build_object(
                                       'value', pi.name
                                     , 'column', json_build_object(
                                         'type', 'view-column'
                                       , 'attributes', json_build_object(
                                           'name', vc.column_name
                                         )
                                       )
                                     ))
                                     FROM pgapex.view_column vc
                                     LEFT JOIN pgapex.fetch_row_condition frc ON vc.column_name = frc.view_column_name
                                     LEFT JOIN pgapex.page_item pi ON pi.page_item_id = frc.url_parameter_id
                                     WHERE vc.database_name = a.database_name
                                           AND vc.schema_name = fpf.schema_name
                                           AND vc.view_name = fpf.view_name)
            , 'functionParameters', (SELECT json_agg(ff_agg.ff_obj) FROM (
                                    SELECT json_build_object(
                                      'fieldType', ff.field_type_id
                                    , 'fieldTemplate', COALESCE(ff.input_template_id, ff.drop_down_template_id, ff.textarea_template_id)
                                    , 'label', ff.label
                                    , 'inputName', pi.name
                                    , 'sequence', ff.sequence
                                    , 'isMandatory', ff.is_mandatory
                                    , 'isVisible', ff.is_visible
                                    , 'defaultValue', ff.default_value
                                    , 'helpText', ff.help_text
                                    , 'attributes', json_build_object(
                                        'name', par.parameter_name
                                      , 'argumentType', ff.function_parameter_type
                                      , 'ordinalPosition', ff.function_parameter_ordinal_position
                                      )
                                    , 'preFillColumn', ff.field_pre_fill_view_column_name
                                    , 'listOfValuesView', json_build_object(
                                        'attributes', json_build_object(
                                          'schema', lov.schema_name
                                        , 'name', lov.view_name
                                        , 'columns', (SELECT json_agg(lov_cols.c) FROM (SELECT json_build_object(
                                            'attributes', json_build_object(
                                              'name', lov_vc.column_name
                                            )
                                          ) c FROM pgapex.view_column lov_vc
                                            WHERE lov_vc.database_name = a.database_name
                                              AND lov_vc.schema_name = lov.schema_name
                                              AND lov_vc.view_name = lov.view_name
                                          ) lov_cols)
                                        )
                                      )
                                    , 'listOfValuesValue', json_build_object(
                                        'attributes', json_build_object(
                                          'name', lov.value_view_column_name
                                        )
                                      )
                                    , 'listOfValuesLabel', json_build_object(
                                        'attributes', json_build_object(
                                          'name', lov.label_view_column_name
                                        )
                                      )
                                    ) ff_obj
                                    FROM pgapex.form_field ff
                                    LEFT JOIN pgapex.page_item pi ON pi.form_field_id = ff.form_field_id
                                    LEFT JOIN pgapex.list_of_values lov ON lov.list_of_values_id = ff.list_of_values_id
                                    LEFT JOIN pgapex.parameter par ON (par.database_name = a.database_name AND par.schema_name = fr.schema_name AND par.function_name = fr.function_name AND par.parameter_type = ff.function_parameter_type AND par.ordinal_position = ff.function_parameter_ordinal_position)
                                    WHERE ff.region_id = r.region_id
                                    ORDER BY ff.function_parameter_ordinal_position) ff_agg
              )
        )
    )
  FROM pgapex.region r
    LEFT JOIN pgapex.form_region fr ON r.region_id = fr.region_id
    LEFT JOIN pgapex.form_pre_fill fpf ON fpf.form_pre_fill_id = fr.form_pre_fill_id
    LEFT JOIN pgapex.page p ON p.page_id = r.page_id
    LEFT JOIN pgapex.application a ON a.application_id = p.application_id
  WHERE r.region_id = i_region_id
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

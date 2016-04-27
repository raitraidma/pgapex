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
       ORDER BY database_name
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
  -- TODO: some region types require more than just on delete cascade.
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
  , i_template_id                    pgapex.region.template_id%TYPE
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
    VALUES (i_new_region_id, i_page_id, i_template_id, i_page_template_display_point_id, v_name, i_sequence, b_is_visible);

    INSERT INTO pgapex.html_region (region_id, content)
    VALUES (i_new_region_id, t_content);
  ELSE
    UPDATE pgapex.region
    SET page_id = i_page_id
    ,   template_id = i_template_id
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
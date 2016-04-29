CREATE OR REPLACE FUNCTION pgapex.f_app_query_page(
  v_application_root VARCHAR
, v_application_id   VARCHAR
, v_page_id          VARCHAR
, v_method           VARCHAR
, j_headers          JSONB
, j_get_params       JSONB
, j_post_params      JSONB
)
  RETURNS JSON AS $$
DECLARE
  j_response       JSON;
  t_response_body  TEXT;
  i_application_id INT;
  i_page_id        INT;
BEGIN
  PERFORM pgapex.f_app_create_temp_tables();
  SELECT pgapex.f_app_get_application_id(v_application_id) INTO i_application_id;

  IF i_application_id IS NULL THEN
    SELECT pgapex.f_app_error('Application does not exist: ' || v_application_id) INTO t_response_body;
    SELECT pgapex.f_app_create_response(t_response_body) INTO j_response;
    RETURN j_response;
  END IF;

  PERFORM pgapex.f_app_open_session(v_application_root, i_application_id, j_headers);

  SELECT pgapex.f_app_get_page_id(i_application_id, v_page_id) INTO i_page_id;

  IF i_page_id IS NULL THEN
    SELECT page_id INTO i_page_id FROM pgapex.page WHERE application_id = i_application_id AND is_homepage = true;
    IF i_page_id IS NULL THEN
      SELECT pgapex.f_app_error('Application does not have any pages') INTO t_response_body;
      SELECT pgapex.f_app_create_response(t_response_body) INTO j_response;
      RETURN j_response;
    ELSE
      PERFORM pgapex.f_app_set_header('location', v_application_root || '/app/' || v_application_id || '/' || i_page_id);
      SELECT pgapex.f_app_create_response('') INTO j_response;
      RETURN j_response;
    END IF;
  END IF;

  BEGIN
    PERFORM pgapex.f_app_dblink_connect(i_application_id);
    PERFORM pgapex.f_app_parse_operation(i_application_id, i_page_id, v_method, j_headers, j_get_params, j_post_params);
    SELECT pgapex.f_app_create_page(i_application_id, i_page_id, j_get_params, j_post_params) INTO t_response_body;
  EXCEPTION
    WHEN OTHERS THEN
      SELECT pgapex.f_app_error('System error: ' || SQLERRM) INTO t_response_body;
  END;
  PERFORM pgapex.f_app_dblink_disconnect();
  SELECT pgapex.f_app_create_response(t_response_body) INTO j_response;
  RETURN j_response;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_logout(
    v_application_root VARCHAR
  , v_application_id   VARCHAR
  , j_headers          JSONB
)
  RETURNS JSON AS $$
DECLARE
  j_response       JSON;
  t_response_body  TEXT;
  i_application_id INT;
BEGIN
  PERFORM pgapex.f_app_create_temp_tables();
  SELECT pgapex.f_app_get_application_id(v_application_id) INTO i_application_id;

  IF i_application_id IS NULL THEN
    SELECT pgapex.f_app_error('Application does not exist: ' || v_application_id) INTO t_response_body;
    SELECT pgapex.f_app_create_response(t_response_body) INTO j_response;
    RETURN j_response;
  END IF;

  PERFORM pgapex.f_app_open_session(v_application_root, i_application_id, j_headers);
  DELETE FROM pgapex.session WHERE session_id = f_app_get_session_id();

  PERFORM pgapex.f_app_set_header('location', v_application_root || '/app/' || v_application_id);
  SELECT pgapex.f_app_create_response('') INTO j_response;
  RETURN j_response;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_create_temp_tables()
RETURNS void AS $$
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS temp_headers (
      transaction_id INT          NOT NULL
    , field_name     VARCHAR(100) NOT NULL
    , value          TEXT         NOT NULL
  );
  CREATE TEMP TABLE IF NOT EXISTS temp_settings (
      transaction_id INT          NOT NULL
    , key            VARCHAR(100) NOT NULL
    , value          TEXT         NOT NULL
  );
  CREATE TEMP TABLE IF NOT EXISTS temp_messages (
      transaction_id INT          NOT NULL
    , type           VARCHAR(10)  NOT NULL CHECK (type IN ('ERROR', 'SUCCESS'))
    , message        TEXT         NOT NULL
  );
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_dblink_connection_name()
  RETURNS VARCHAR AS $$
  SELECT 'dblink_connection_' || txid_current()::varchar;
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_dblink_connect(
  i_application_id INT
)
RETURNS TEXT AS $$
  SELECT dblink_connect(pgapex.f_app_get_dblink_connection_name(),
                       'dbname=' || database_name || ' user=' || database_username || ' password=' || database_password)
  FROM pgapex.application WHERE application_id = i_application_id;
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_dblink_disconnect()
RETURNS TEXT AS $$
  SELECT dblink_disconnect(pgapex.f_app_get_dblink_connection_name());
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_add_error_message(
  t_message      TEXT
)
  RETURNS void AS $$
BEGIN
  INSERT INTO temp_messages(transaction_id, type, message) VALUES (txid_current(), 'ERROR', t_message);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_add_success_message(
  t_message      TEXT
)
  RETURNS void AS $$
BEGIN
  INSERT INTO temp_messages(transaction_id, type, message) VALUES (txid_current(), 'SUCCESS', t_message);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_set_header(
  v_field_name VARCHAR
, t_value      TEXT
)
RETURNS void AS $$
BEGIN
  DELETE FROM temp_headers WHERE transaction_id = txid_current() AND field_name = lower(v_field_name);
  INSERT INTO temp_headers(transaction_id, field_name, value) VALUES (txid_current(), lower(v_field_name), t_value);
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_add_setting(
    v_key   VARCHAR
  , v_value VARCHAR
)
  RETURNS void AS $$
BEGIN
  DELETE FROM temp_settings WHERE transaction_id = txid_current() AND key = lower(v_key);
  INSERT INTO temp_settings(transaction_id, key, value) VALUES (txid_current(), lower(v_key), v_value);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_setting(
    v_key   VARCHAR
)
  RETURNS varchar AS $$
DECLARE
  v_value VARCHAR;
BEGIN
  SELECT value INTO v_value FROM temp_settings WHERE transaction_id = txid_current() AND key = lower(v_key);
  RETURN v_value;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_application_id(
  v_application_id VARCHAR
)
RETURNS int AS $$
  SELECT (
    CASE
      WHEN v_application_id ~ '^[0-9]+$' AND
          (SELECT EXISTS(SELECT 1 FROM pgapex.application WHERE application_id = v_application_id::int)) THEN
            v_application_id::int
      WHEN (SELECT EXISTS(SELECT 1 FROM pgapex.application WHERE alias = v_application_id)) THEN
        (SELECT application_id FROM pgapex.application WHERE alias = v_application_id)
      ELSE
        NULL
    END
  );
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_page_id(
  i_application_id INT
, v_page_id        VARCHAR
)
RETURNS int AS $$
  SELECT (
    CASE
      WHEN v_page_id ~ '^[0-9]+$' AND
          (SELECT EXISTS(SELECT 1 FROM pgapex.page WHERE page_id = v_page_id::int)) THEN
            v_page_id::int
      WHEN (SELECT EXISTS(SELECT 1 FROM pgapex.page WHERE application_id = i_application_id AND alias = v_page_id)) THEN
        (SELECT page_id FROM pgapex.page WHERE application_id = i_application_id AND alias = v_page_id)
      ELSE
        NULL
    END
  );
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_error(
  v_error_message VARCHAR
)
RETURNS text AS $$
  SELECT '<html>
  <head>
    <title>Error</title>
  </head>
  <body>
    <strong>Error!</strong>
    <p>' || v_error_message || '</p>
  </body>
</html>';
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_create_response(
  t_response_body TEXT
)
RETURNS json AS $$
DECLARE
  j_response JSON;
BEGIN
  SELECT json_build_object(
    'headers', coalesce(json_object(array_agg(h.field_name), array_agg(h.value)), '{}'::json)
  , 'body', t_response_body
  )
  INTO j_response
  FROM temp_headers h
  WHERE h.transaction_id = txid_current();

  RETURN j_response;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_open_session(
    v_application_root VARCHAR
  , i_application_id   INT
  , j_headers          JSONB
)
  RETURNS void AS $$
DECLARE
  v_session_id      VARCHAR;
  t_expiration_time TIMESTAMP;
BEGIN
  SELECT pgapex.f_app_get_cookie('PGAPEX_SESSION_' || i_application_id::VARCHAR, j_headers) INTO v_session_id;
  IF v_session_id IS NOT NULL THEN
    SELECT expiration_time INTO t_expiration_time FROM pgapex.session WHERE session_id = v_session_id;
    IF t_expiration_time > current_timestamp THEN
      UPDATE pgapex.session SET expiration_time = (current_timestamp + interval '1 hour') WHERE session_id = v_session_id;
      PERFORM pgapex.f_app_add_setting('session_id', v_session_id);
      RETURN;
    ELSE
      DELETE FROM pgapex.session WHERE session_id = v_session_id;
    END IF;
  END IF;

  SELECT encode(pgapex.digest(current_timestamp::text || random()::text || txid_current()::text || i_application_id::text, 'sha512'), 'hex') INTO v_session_id;
  PERFORM pgapex.f_app_set_cookie('PGAPEX_SESSION_' || i_application_id::VARCHAR, v_session_id || '; Path=' || v_application_root);
  PERFORM pgapex.f_app_add_setting('session_id', v_session_id);
  INSERT INTO pgapex.session (session_id, application_id, data, expiration_time)
  VALUES (v_session_id, i_application_id, '{}'::jsonb, (current_timestamp + interval '1 hour'));
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_session_id()
RETURNS varchar AS $$
  SELECT pgapex.f_app_get_setting('session_id');
$$ LANGUAGE sql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_session_write(
  v_key   VARCHAR
, v_value VARCHAR
)
RETURNS void AS $$
DECLARE
  j_new_session_data JSONB;
BEGIN
  WITH session_data AS (
    SELECT data FROM pgapex.session WHERE session_id = pgapex.f_app_get_session_id()
  ), concat_json AS (
    SELECT s1.key, s1.value FROM jsonb_each(json_build_object(lower(v_key), v_value)::jsonb) s1
    UNION ALL
    SELECT s2.key, s2.value FROM session_data, jsonb_each(session_data.data) s2
  ), with_unique_keys AS (
    SELECT DISTINCT ON (key) key, value FROM concat_json
  )
  SELECT json_object_agg(key, value) INTO j_new_session_data FROM with_unique_keys;

  UPDATE pgapex.session SET data = j_new_session_data
  WHERE session_id = pgapex.f_app_get_session_id();
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_session_read(
  v_key  VARCHAR
)
  RETURNS varchar AS $$
DECLARE
  j_session_data JSONB;
  j_value        VARCHAR;
BEGIN
  SELECT data INTO j_session_data FROM pgapex.session WHERE session_id = pgapex.f_app_get_session_id();
  IF j_session_data IS NOT NULL AND j_session_data ? lower(v_key) THEN
    SELECT j_session_data->>lower(v_key) INTO j_value;
    RETURN j_value;
  END IF;
  RETURN NULL;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_cookie(
    v_cookie_name VARCHAR
  , j_headers     JSONB
)
  RETURNS VARCHAR AS $$
DECLARE
  v_cookie_value VARCHAR;
  v_cookies VARCHAR;
  v_cookie TEXT[];
BEGIN
  IF j_headers IS NULL THEN
    RETURN NULL;
  END IF;
  IF j_headers ? 'HTTP_COOKIE' THEN
  SELECT j_headers->'HTTP_COOKIE'->>0 INTO v_cookies;
  FOR v_cookie IN SELECT regexp_split_to_array(trim(c), E'=') FROM regexp_split_to_table(v_cookies, E';') AS c LOOP
    IF v_cookie[1] = v_cookie_name THEN
      RETURN v_cookie[2];
    END IF;
  END LOOP;
END IF;
RETURN NULL;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_set_cookie(
    v_cookie_name  VARCHAR
  , v_cookie_value VARCHAR
)
  RETURNS void AS $$
BEGIN
  PERFORM pgapex.f_app_set_header('set-cookie', v_cookie_name || '=' || v_cookie_value);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_create_page(
    i_application_id INT
  , i_page_id        INT
  , j_get_params     JSONB
  , j_post_params    JSONB
)
RETURNS text AS $$
DECLARE
  b_is_app_auth_required  BOOLEAN;
  b_is_page_auth_required BOOLEAN;
  t_response              TEXT;
  t_success_message       TEXT;
  t_error_message         TEXT;
BEGIN
  SELECT authentication_scheme_id <> 'NO_AUTHENTICATION' INTO b_is_app_auth_required FROM pgapex.application WHERE application_id = i_application_id;
  SELECT is_authentication_required INTO b_is_page_auth_required FROM pgapex.page WHERE page_id = i_page_id;

  IF b_is_app_auth_required AND b_is_page_auth_required AND pgapex.f_app_is_authenticated() = FALSE THEN
    SELECT pt.header || pt.body || pt.footer, pt.success_message, pt.error_message
    INTO t_response, t_success_message, t_error_message
    FROM pgapex.page_template pt
    WHERE pt.template_id = (SELECT a.login_page_template_id
                            FROM pgapex.application a
                            WHERE a.application_id = i_application_id);
  ELSE
    SELECT 'Page content' INTO t_response;
  END IF;

  t_response := replace(t_response, '#APPLICATION_NAME#', (SELECT name FROM pgapex.application WHERE application_id = i_application_id));
  t_response := replace(t_response, '#TITLE#', (SELECT title FROM pgapex.page WHERE page_id = i_page_id));
  t_response := replace(t_response, '#LOGOUT_LINK#', '');
  t_response := replace(t_response, '#ERROR_MESSAGE#', pgapex.f_app_get_error_message(t_error_message));
  t_response := replace(t_response, '#SUCCESS_MESSAGE#', pgapex.f_app_get_success_message(t_success_message));

  RETURN t_response;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_message(
  v_type                   VARCHAR
, t_message_template TEXT
)
  RETURNS text AS $$
DECLARE
  t_response TEXT;
  t_message TEXT;
BEGIN
  SELECT string_agg(message, '<br />') INTO t_message FROM temp_messages WHERE type = v_type AND transaction_id = txid_current();
  IF t_message <> '' THEN
    RETURN replace(t_message_template, '#MESSAGE#', t_message);
  END IF;
  RETURN '';
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_error_message(
  t_error_message_template TEXT
)
RETURNS text AS $$
BEGIN
  RETURN pgapex.f_app_get_message('ERROR', t_error_message_template);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_success_message(
  t_success_message_template TEXT
)
RETURNS text AS $$
BEGIN
  RETURN pgapex.f_app_get_message('SUCCESS', t_success_message_template);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_is_authenticated()
  RETURNS boolean AS $$
DECLARE
  b_is_authenticated BOOLEAN;
BEGIN
  SELECT pgapex.f_app_session_read('is_authenticated')::BOOLEAN INTO b_is_authenticated;
  IF b_is_authenticated IS NOT NULL AND b_is_authenticated = TRUE THEN
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_parse_operation(
    i_application_id   INT
  , i_page_id          INT
  , v_method           VARCHAR
  , j_headers          JSONB
  , j_get_params       JSONB
  , j_post_params      JSONB
)
  RETURNS void AS $$
DECLARE
  b_is_permitted BOOLEAN;
BEGIN
  IF upper(v_method) <> 'POST' THEN
    RETURN;
  END IF;

  IF j_post_params ? 'PGAPEX_OP' AND j_post_params ? 'USERNAME' AND j_post_params ? 'PASSWORD' AND j_post_params->>'PGAPEX_OP' = 'LOGIN' THEN
    SELECT is_permitted INTO b_is_permitted
    FROM pgapex.application a,
        dblink(
          pgapex.f_app_get_dblink_connection_name()
        , 'select ' || a.authentication_function_schema_name || '.' || a.authentication_function_name || '(' || quote_nullable(j_post_params->>'USERNAME') || ',' || quote_nullable(j_post_params->>'PASSWORD') || ')'
        , false
        ) AS ( is_permitted BOOLEAN )
    WHERE application_id = i_application_id;

    IF b_is_permitted THEN
      PERFORM pgapex.f_app_session_write('is_authenticated', TRUE::VARCHAR);
      --PERFORM pgapex.f_app_add_success_message('Allowed');
    ELSE
      PERFORM pgapex.f_app_add_error_message('Permission denied!');
    END IF;
  END IF;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;
CREATE OR REPLACE FUNCTION pgapex.f_app_query_page(
  v_application_id VARCHAR
, v_page_id        VARCHAR
, v_method         VARCHAR
, j_headers        JSONB
, j_get_params     JSONB
, j_post_params    JSONB
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

  PERFORM pgapex.f_app_open_session(i_application_id, j_headers);

  SELECT pgapex.f_app_create_response('Rakendus: ' || v_application_id) INTO j_response;
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
    i_application_id INT
  , j_headers        JSONB
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
  PERFORM pgapex.f_app_set_cookie('PGAPEX_SESSION_' || i_application_id::VARCHAR, v_session_id);
  INSERT INTO pgapex.session (session_id, application_id, data, expiration_time)
  VALUES (v_session_id, i_application_id, '{}'::jsonb, (current_timestamp + interval '1 hour'));
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
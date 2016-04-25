SET client_min_messages TO WARNING;

---------------------------------
---------- APPLICATION ----------
---------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_trig_application_authentication_function_exists()
RETURNS trigger AS $$
DECLARE
	b_authentication_function_exists BOOLEAN;
BEGIN
  IF NEW.authentication_scheme_id <> 'USER_FUNCTION' THEN
    RETURN NEW;
  END IF;

  WITH boolean_functions_with_two_parameters AS (
    SELECT f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
    FROM pgapex.function f
    LEFT JOIN pgapex.parameter p ON (f.database_name = p.database_name AND f.schema_name = p.schema_name AND f.function_name = p.function_name)
    WHERE f.database_name = NEW.database_name
      AND f.schema_name = NEW.authentication_function_schema_name
      AND f.function_name = NEW.authentication_function_name
      AND f.return_type = 'bool'
    GROUP BY f.database_name, f.schema_name, f.function_name, f.return_type, p.parameter_type
    HAVING max(p.ordinal_position) = 2
  )
  SELECT count(1) = 1 INTO b_authentication_function_exists FROM boolean_functions_with_two_parameters f
  WHERE f.parameter_type IN ('text', 'varchar');

	IF b_authentication_function_exists = FALSE THEN
		RAISE EXCEPTION 'Application authentication function does not exist';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trig_application_authentication_function_exists ON pgapex.application;

CREATE CONSTRAINT TRIGGER trig_application_authentication_function_exists AFTER INSERT OR UPDATE ON pgapex.application
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW EXECUTE PROCEDURE pgapex.f_trig_application_authentication_function_exists();

----------


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

--------------------------
---------- PAGE ----------
--------------------------

CREATE OR REPLACE FUNCTION pgapex.f_trig_page_only_one_homepage_per_application()
RETURNS trigger AS $$
DECLARE
	b_application_has_more_than_one_homepage BOOLEAN;
BEGIN
  SELECT count(1) > 0 INTO b_application_has_more_than_one_homepage
  FROM pgapex.page
  WHERE is_homepage = TRUE
  GROUP BY application_id
  HAVING COUNT(1) > 1;

	IF b_application_has_more_than_one_homepage THEN
		RAISE EXCEPTION 'Application may have only one homepage';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trig_page_only_one_homepage_per_application ON pgapex.page;

CREATE CONSTRAINT TRIGGER trig_page_only_one_homepage_per_application AFTER INSERT OR UPDATE ON pgapex.page
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW EXECUTE PROCEDURE pgapex.f_trig_page_only_one_homepage_per_application();

----------------------------
---------- REGION ----------
----------------------------

CREATE OR REPLACE FUNCTION pgapex.f_trig_form_pre_fill_must_be_deleted_with_form_region()
RETURNS trigger AS $$
BEGIN
	IF OLD.form_pre_fill_id IS NOT NULL THEN
		DELETE FROM pgapex.form_pre_fill WHERE form_pre_fill_id = OLD.form_pre_fill_id;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trig_form_pre_fill_must_be_deleted_with_form_region ON pgapex.form_region;

CREATE CONSTRAINT TRIGGER trig_form_pre_fill_must_be_deleted_with_form_region AFTER DELETE ON pgapex.form_region
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW EXECUTE PROCEDURE pgapex.f_trig_form_pre_fill_must_be_deleted_with_form_region();

----------

CREATE OR REPLACE FUNCTION pgapex.f_trig_list_of_values_must_be_deleted_with_form_field()
RETURNS trigger AS $$
BEGIN
	IF OLD.list_of_values_id IS NOT NULL THEN
		DELETE FROM pgapex.list_of_values WHERE list_of_values_id = OLD.list_of_values_id;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trig_list_of_values_must_be_deleted_with_form_field ON pgapex.form_field;

CREATE CONSTRAINT TRIGGER trig_list_of_values_must_be_deleted_with_form_field AFTER DELETE ON pgapex.form_field
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW EXECUTE PROCEDURE pgapex.f_trig_list_of_values_must_be_deleted_with_form_field();

--------------------------------
---------- NAVIGATION ----------
--------------------------------

CREATE OR REPLACE FUNCTION pgapex.f_trig_navigation_item_may_not_contain_cycles()
RETURNS trigger AS $$
BEGIN
  IF pgapex.f_navigation_navigation_item_contains_cycle(NEW.navigation_item_id, NEW.parent_navigation_item_id) THEN
    RAISE EXCEPTION 'Navigation may not contain cycles';
  END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trig_navigation_item_may_not_contain_cycles ON pgapex.navigation_item;

CREATE CONSTRAINT TRIGGER trig_navigation_item_may_not_contain_cycles AFTER INSERT OR UPDATE ON pgapex.navigation_item
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW EXECUTE PROCEDURE pgapex.f_trig_navigation_item_may_not_contain_cycles();
CREATE OR REPLACE FUNCTION pgapex.f_is_superuser(
  username VARCHAR
, password VARCHAR
)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1
    FROM pg_catalog.pg_shadow
    WHERE (passwd = 'md5' || md5($2 || $1))
      AND usesuper = TRUE
  );
$$ LANGUAGE sql
  SECURITY DEFINER
  SET search_path = pgapex, public, pg_temp;
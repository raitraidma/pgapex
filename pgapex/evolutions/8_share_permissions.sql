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
, pgapex.f_database_object_get_views_with_columns(pgapex.application.application_id%TYPE)
-- TEMPLATE --
, pgapex.f_template_get_page_templates(pgapex.page_template.page_type_id%TYPE)
, pgapex.f_template_get_region_templates()
, pgapex.f_template_get_navigation_templates()
, pgapex.f_template_get_report_templates()
-- PAGE --
, pgapex.f_page_get_pages(pgapex.page.application_id%TYPE)
, pgapex.f_page_save_page(pgapex.page.page_id%TYPE, pgapex.page.application_id%TYPE, pgapex.page.template_id%TYPE, pgapex.page.title%TYPE, pgapex.page.alias%TYPE, pgapex.page.is_homepage%TYPE, pgapex.page.is_authentication_required%TYPE)
, pgapex.f_page_get_page(pgapex.page.page_id%TYPE)
, pgapex.f_page_delete_page(pgapex.page.page_id%TYPE)
-- NAVIGATION --
, pgapex.f_navigation_get_navigations(pgapex.navigation.application_id%TYPE)
, pgapex.f_navigation_save_navigation(pgapex.navigation.navigation_id%TYPE, pgapex.navigation.application_id%TYPE, pgapex.navigation.name%TYPE)
, pgapex.f_navigation_get_navigation(pgapex.navigation.navigation_id%TYPE)
, pgapex.f_navigation_delete_navigation(pgapex.navigation.navigation_id%TYPE)

, pgapex.f_navigation_get_navigation_items(pgapex.navigation_item.navigation_id%TYPE)
, pgapex.f_navigation_delete_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE)
, pgapex.f_navigation_get_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE)
, pgapex.f_navigation_save_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE, pgapex.navigation_item.parent_navigation_item_id%TYPE, pgapex.navigation_item.navigation_id%TYPE, pgapex.navigation_item.name%TYPE, pgapex.navigation_item.sequence%TYPE, pgapex.navigation_item.page_id%TYPE, pgapex.navigation_item.url%TYPE)
-- REGION --
, pgapex.f_region_get_display_points_with_regions(pgapex.page.page_id%TYPE)
, pgapex.f_region_get_region(pgapex.region.region_id%TYPE)
, pgapex.f_region_delete_region(pgapex.region.region_id%TYPE)
, pgapex.f_region_save_html_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.html_region.content%TYPE)
, pgapex.f_region_save_navigation_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.navigation_region.navigation_type_id%TYPE, pgapex.navigation_region.navigation_id%TYPE, pgapex.navigation_region.template_id%TYPE, pgapex.navigation_region.repeat_last_level%TYPE)
, pgapex.f_region_save_report_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.report_region.template_id%TYPE, pgapex.report_region.schema_name%TYPE, pgapex.report_region.view_name%TYPE, pgapex.report_region.items_per_page%TYPE, pgapex.report_region.show_header%TYPE, pgapex.page_item.name%TYPE)
, pgapex.f_region_delete_report_region_columns(pgapex.region.region_id%TYPE)
, pgapex.f_region_create_report_region_column(pgapex.report_column.region_id%TYPE, pgapex.report_column.view_column_name%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE)
, pgapex.f_region_create_report_region_link(pgapex.report_column.region_id%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE, pgapex.report_column_link.url%TYPE, pgapex.report_column_link.link_text%TYPE, pgapex.report_column_link.attributes%TYPE)
TO :DB_APP_USER;
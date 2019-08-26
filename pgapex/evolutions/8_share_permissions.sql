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
, pgapex.f_application_application_may_have_a_name(pgapex.application.application_id%TYPE, pgapex.application.name%TYPE)
, pgapex.f_application_save_application(pgapex.application.application_id%TYPE, pgapex.application.name%TYPE, pgapex.application.alias%TYPE, pgapex.application.database_name%TYPE, pgapex.application.database_username%TYPE, pgapex.application.database_password%TYPE)
, pgapex.f_application_save_application_authentication(pgapex.application.application_id%TYPE, pgapex.application.authentication_scheme_id%TYPE, pgapex.application.authentication_function_schema_name%TYPE, pgapex.application.authentication_function_name%TYPE, pgapex.application.login_page_template_id%TYPE)
-- DATABASE OBJECT --
, pgapex.f_database_object_get_databases()
, pgapex.f_database_object_get_authentication_functions(pgapex.application.application_id%TYPE)
, pgapex.f_database_object_get_views_with_columns(pgapex.application.application_id%TYPE)
, pgapex.f_database_object_get_functions_with_parameters(pgapex.application.application_id%TYPE)
-- TEMPLATE --
, pgapex.f_template_get_page_templates(pgapex.page_template.page_type_id%TYPE)
, pgapex.f_template_get_region_templates()
, pgapex.f_template_get_navigation_templates()
, pgapex.f_template_get_report_templates()
, pgapex.f_template_get_form_templates()
, pgapex.f_template_get_button_templates()
, pgapex.f_template_get_textarea_templates()
, pgapex.f_template_get_drop_down_templates()
, pgapex.f_template_get_input_templates(pgapex.input_template.input_template_type_id%TYPE)
, pgapex.f_template_get_report_link_templates()
, pgapex.f_template_get_detailview_templates()
, pgapex.f_template_get_tabularform_templates()
, pgapex.f_template_get_tabularform_button_templates()
-- PAGE --
, pgapex.f_page_get_pages(pgapex.page.application_id%TYPE)
, pgapex.f_page_save_page(pgapex.page.page_id%TYPE, pgapex.page.application_id%TYPE, pgapex.page.template_id%TYPE, pgapex.page.title%TYPE, pgapex.page.alias%TYPE, pgapex.page.is_homepage%TYPE, pgapex.page.is_authentication_required%TYPE)
, pgapex.f_page_get_page(pgapex.page.page_id%TYPE)
, pgapex.f_page_delete_page(pgapex.page.page_id%TYPE)
, pgapex.f_page_page_may_have_an_alias(pgapex.page.page_id%TYPE, pgapex.page.application_id%TYPE, pgapex.page.alias%TYPE)
-- NAVIGATION --
, pgapex.f_navigation_get_navigations(pgapex.navigation.application_id%TYPE)
, pgapex.f_navigation_save_navigation(pgapex.navigation.navigation_id%TYPE, pgapex.navigation.application_id%TYPE, pgapex.navigation.name%TYPE)
, pgapex.f_navigation_get_navigation(pgapex.navigation.navigation_id%TYPE)
, pgapex.f_navigation_delete_navigation(pgapex.navigation.navigation_id%TYPE)

, pgapex.f_navigation_get_navigation_items(pgapex.navigation_item.navigation_id%TYPE)
, pgapex.f_navigation_delete_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE)
, pgapex.f_navigation_get_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE)
, pgapex.f_navigation_save_navigation_item(pgapex.navigation_item.navigation_item_id%TYPE, pgapex.navigation_item.parent_navigation_item_id%TYPE, pgapex.navigation_item.navigation_id%TYPE, pgapex.navigation_item.name%TYPE, pgapex.navigation_item.sequence%TYPE, pgapex.navigation_item.page_id%TYPE, pgapex.navigation_item.url%TYPE)

, pgapex.f_navigation_navigation_may_have_a_name(pgapex.navigation.navigation_id%TYPE, pgapex.navigation.application_id%TYPE, pgapex.navigation.name%TYPE)
, pgapex.f_navigation_navigation_item_contains_cycle(pgapex.navigation_item.navigation_item_id%TYPE, pgapex.navigation_item.navigation_item_id%TYPE)
, pgapex.f_navigation_navigation_item_may_have_a_sequence(pgapex.navigation_item.navigation_item_id%TYPE, pgapex.navigation_item.navigation_id%TYPE, pgapex.navigation_item.parent_navigation_item_id%TYPE, pgapex.navigation_item.sequence%TYPE)
, pgapex.f_navigation_navigation_item_may_refer_to_page(pgapex.navigation_item.navigation_item_id%TYPE, pgapex.navigation_item.navigation_id%TYPE, pgapex.navigation_item.page_id%TYPE)
-- REGION --
, pgapex.f_region_get_display_points_with_regions(pgapex.page.page_id%TYPE)
, pgapex.f_region_get_region(pgapex.region.region_id%TYPE)
, pgapex.f_region_delete_region(pgapex.region.region_id%TYPE)
, pgapex.f_region_save_html_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.html_region.content%TYPE)
, pgapex.f_region_save_navigation_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.navigation_region.navigation_type_id%TYPE, pgapex.navigation_region.navigation_id%TYPE, pgapex.navigation_region.template_id%TYPE, pgapex.navigation_region.repeat_last_level%TYPE)
, pgapex.f_region_save_report_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.report_region.template_id%TYPE, pgapex.report_region.schema_name%TYPE, pgapex.report_region.view_name%TYPE, pgapex.report_region.items_per_page%TYPE, pgapex.report_region.show_header%TYPE, pgapex.report_region.unique_id%TYPE, pgapex.report_region.link_template_id%TYPE, pgapex.page_item.name%TYPE)
, pgapex.f_region_delete_report_region_columns(pgapex.region.region_id%TYPE)
, pgapex.f_region_create_report_region_column(pgapex.report_column.region_id%TYPE, pgapex.report_column.view_column_name%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE)
, pgapex.f_region_create_report_region_link(pgapex.report_column.region_id%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE, pgapex.report_column_link.url%TYPE, pgapex.report_column_link.link_text%TYPE, pgapex.report_column_link.attributes%TYPE)
, pgapex.f_region_delete_form_pre_fill_and_form_field(pgapex.region.region_id%TYPE)
, pgapex.f_region_save_form_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.form_region.form_pre_fill_id%TYPE, pgapex.form_region.template_id%TYPE, pgapex.form_region.button_template_id%TYPE, pgapex.form_region.schema_name%TYPE, pgapex.form_region.function_name%TYPE, pgapex.form_region.button_label%TYPE, pgapex.form_region.success_message%TYPE, pgapex.form_region.error_message%TYPE, pgapex.form_region.redirect_url%TYPE)
, pgapex.f_region_save_form_pre_fill(pgapex.form_pre_fill.schema_name%TYPE, pgapex.form_pre_fill.view_name%TYPE)
, pgapex.f_region_save_fetch_row_condition(pgapex.fetch_row_condition.form_pre_fill_id%TYPE, pgapex.region.region_id%TYPE, pgapex.page_item.name%TYPE, pgapex.fetch_row_condition.view_column_name%TYPE)
, pgapex.f_region_save_form_field(pgapex.form_field.region_id%TYPE, pgapex.form_field.field_type_id%TYPE, pgapex.form_field.list_of_values_id%TYPE, pgapex.template.template_id%TYPE, pgapex.form_field.field_pre_fill_view_column_name%TYPE, pgapex.page_item.name%TYPE, pgapex.form_field.label%TYPE, pgapex.form_field.sequence%TYPE, pgapex.form_field.is_mandatory%TYPE, pgapex.form_field.is_visible%TYPE, pgapex.form_field.default_value%TYPE, pgapex.form_field.help_text%TYPE, pgapex.form_field.function_parameter_type%TYPE, pgapex.form_field.function_parameter_ordinal_position%TYPE)
, pgapex.f_region_save_list_of_values(pgapex.list_of_values.value_view_column_name%TYPE, pgapex.list_of_values.label_view_column_name%TYPE, pgapex.list_of_values.view_name%TYPE, pgapex.list_of_values.schema_name%TYPE)
, pgapex.f_region_region_may_have_a_sequence(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.sequence%TYPE)
, pgapex.f_region_delete_report_region_columns(pgapex.region.region_id%TYPE)
, pgapex.f_region_create_report_region_column(pgapex.report_column.region_id%TYPE, pgapex.report_column.view_column_name%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE)
, pgapex.f_region_create_report_region_link(pgapex.report_column.region_id%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE, pgapex.report_column_link.url%TYPE, pgapex.report_column_link.link_text%TYPE, pgapex.report_column_link.attributes%TYPE)
, pgapex.f_region_save_tabularform_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.tabularform_region.template_id%TYPE, pgapex.tabularform_region.schema_name%TYPE, pgapex.tabularform_region.view_name%TYPE, pgapex.tabularform_region.items_per_page%TYPE, pgapex.tabularform_region.show_header%TYPE, pgapex.tabularform_region.unique_id%TYPE, pgapex.page_item.name%TYPE)
, pgapex.f_region_create_tabularform_region_column(pgapex.tabularform_column.region_id%TYPE, pgapex.tabularform_column.view_column_name%TYPE, pgapex.tabularform_column.heading%TYPE, pgapex.tabularform_column.sequence%TYPE, pgapex.tabularform_column.is_text_escaped%TYPE)
, pgapex.f_region_create_tabularform_region_link(pgapex.tabularform_column.region_id%TYPE, pgapex.tabularform_column.heading%TYPE, pgapex.tabularform_column.sequence%TYPE, pgapex.tabularform_column.is_text_escaped%TYPE, pgapex.tabularform_column_link.url%TYPE, pgapex.tabularform_column_link.link_text%TYPE, pgapex.tabularform_column_link.attributes%TYPE)
, pgapex.f_region_delete_tabularform_region_columns(pgapex.region.region_id%TYPE)
, pgapex.f_region_create_tabularform_region_function(pgapex.tabularform_function.region_id%TYPE, pgapex.tabularform_function.button_template_id%TYPE, pgapex.tabularform_function.schema_name%TYPE, pgapex.tabularform_function.function_name%TYPE, pgapex.tabularform_function.button_label%TYPE, pgapex.tabularform_function.sequence%TYPE, pgapex.tabularform_function.success_message%TYPE, pgapex.tabularform_function.error_message%TYPE, pgapex.tabularform_function.app_user%TYPE)
, pgapex.f_region_delete_tabularform_region_functions(pgapex.region.region_id%TYPE)
, pgapex.f_region_delete_tabularform_functions(pgapex.region.region_id%TYPE)
, pgapex.f_region_save_detailview_region(pgapex.region.region_id%TYPE, pgapex.region.page_id%TYPE, pgapex.region.template_id%TYPE, pgapex.region.page_template_display_point_id%TYPE, pgapex.region.name%TYPE, pgapex.region.sequence%TYPE, pgapex.region.is_visible%TYPE, pgapex.detailview_region.report_region_id%TYPE, pgapex.detailview_region.template_id%TYPE, pgapex.detailview_region.schema_name%TYPE, pgapex.detailview_region.view_name%TYPE, pgapex.detailview_region.unique_id%TYPE)
, pgapex.f_region_create_detailview_region_column(pgapex.detailview_column.region_id%TYPE, pgapex.detailview_column.view_column_name%TYPE, pgapex.detailview_column.heading%TYPE, pgapex.detailview_column.sequence%TYPE, pgapex.detailview_column.is_text_escaped%TYPE)
, pgapex.f_region_create_detailview_region_link(pgapex.detailview_column.region_id%TYPE, pgapex.detailview_column.heading%TYPE, pgapex.detailview_column.sequence%TYPE, pgapex.detailview_column.is_text_escaped%TYPE, pgapex.detailview_column_link.url%TYPE, pgapex.detailview_column_link.link_text%TYPE, pgapex.detailview_column_link.attributes%TYPE)
, pgapex.f_region_delete_detailview_region_columns(pgapex.region.region_id%TYPE)
, pgapex.f_region_save_report_subregion(pgapex.subregion.subregion_id%TYPE, pgapex.subregion.template_id%TYPE, pgapex.subregion.name%TYPE, pgapex.subregion.sequence%TYPE, pgapex.subregion.is_visible%TYPE, pgapex.subregion.query_parameter%TYPE, pgapex.subregion.parent_region_id%TYPE, pgapex.report_region.template_id%TYPE, pgapex.report_region.schema_name%TYPE, pgapex.report_region.view_name%TYPE, pgapex.report_region.items_per_page%TYPE, pgapex.report_region.show_header%TYPE, pgapex.report_region.unique_id%TYPE)
, pgapex.f_subregion_delete_subregion(pgapex.subregion.parent_region_id%TYPE)
, pgapex.f_subregion_delete_report_subregion_columns(pgapex.subregion.subregion_id%TYPE)
, pgapex.f_subregion_create_report_subregion_column(pgapex.report_column.subregion_id%TYPE, pgapex.report_column.view_column_name%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE)
, pgapex.f_subregion_create_report_subregion_link(pgapex.report_column.subregion_id%TYPE, pgapex.report_column.heading%TYPE, pgapex.report_column.sequence%TYPE, pgapex.report_column.is_text_escaped%TYPE, pgapex.report_column_link.url%TYPE, pgapex.report_column_link.link_text%TYPE, pgapex.report_column_link.attributes%TYPE)
, pgapex.f_region_get_tabularform_region(pgapex.region.region_id%TYPE)
, pgapex.f_region_get_report_subregions(pgapex.detailview_region.region_id%TYPE)
, pgapex.f_region_get_detailview_region_id_by_report_region_id(pgapex.report_region.region_id%TYPE)
, pgapex.f_region_get_report_and_detailview_region_by_report_id(pgapex.region.region_id%TYPE)
, pgapex.f_region_get_report_and_detailview_region_by_detailview_id(pgapex.region.region_id%TYPE)
-- APP --
, pgapex.f_app_query_page(VARCHAR, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, JSONB)
, pgapex.f_app_logout(VARCHAR, VARCHAR, JSONB)
TO :DB_APP_USER;

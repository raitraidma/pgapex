CREATE OR REPLACE FUNCTION pgapex.f_app_get_tabularform_region_with_template(
  i_region_id               INT
, j_data                    JSON
, v_pagination_query_param  VARCHAR
, i_page_count              INT
, i_current_page            INT
, b_show_header             BOOLEAN
)
  RETURNS TEXT AS $$
DECLARE
  t_response                TEXT;
  t_pagination              TEXT     := '';
  v_url_prefix              VARCHAR;
  t_tabularform_begin       TEXT;
  t_tabularform_end         TEXT;
  t_form_begin              TEXT;
  t_buttons_row_begin       TEXT;
  t_buttons_row_content     TEXT;
  t_buttons_row_end         TEXT;
  t_table_begin             TEXT;
  t_table_header_begin      TEXT;
  t_table_header_row_begin  TEXT;
  t_table_header_checkbox   TEXT;
  t_table_header_cell       TEXT;
  t_table_header_row_end    TEXT;
  t_table_header_end        TEXT;
  t_table_body_begin        TEXT;
  t_table_body_row_begin    TEXT;
  t_table_body_row_checkbox TEXT;
  t_table_body_row_cell     TEXT;
  t_table_body_row_end      TEXT;
  t_table_body_end          TEXT;
  t_table_end               TEXT;
  t_form_end                TEXT;
  t_pagination_begin        TEXT;
  t_pagination_end          TEXT;
  t_previous_page           TEXT;
  t_next_page               TEXT;
  t_active_page             TEXT;
  t_inactive_page           TEXT;
  t_unique_id               TEXT;
  r_tabularform_column      pgapex.t_tabularform_column_with_link;
  r_tabularform_columns     pgapex.t_tabularform_column_with_link[];
  r_tabularform_button      pgapex.t_tabularform_button;
  r_tabularform_buttons     pgapex.t_tabularform_button[];
  t_button                  TEXT;
  t_body_checkbox           TEXT;
  j_row                     JSON;
  r_column                  RECORD;
  t_cell_content            TEXT;
BEGIN
  SELECT tft.tabularform_begin, tft.tabularform_end, tft.form_begin, tft.buttons_row_begin, tft.buttons_row_content,
         tft.buttons_row_end, tft.table_begin, tft.table_header_begin, tft.table_header_row_begin,
         tft.table_header_checkbox, tft.table_header_cell, tft.table_header_row_end, tft.table_header_end,
         tft.table_body_begin, tft.table_body_row_begin, tft.table_body_row_checkbox, tft.table_body_row_cell,
         tft.table_body_row_end, tft.table_body_end, tft.table_end, tft.form_end, tft.pagination_begin,
         tft.pagination_end, tft.previous_page, tft.next_page, tft.active_page, tft.inactive_page, tfr.unique_id
  INTO t_tabularform_begin, t_tabularform_end, t_form_begin, t_buttons_row_begin, t_buttons_row_content,
         t_buttons_row_end, t_table_begin, t_table_header_begin, t_table_header_row_begin,
         t_table_header_checkbox, t_table_header_cell, t_table_header_row_end, t_table_header_end,
         t_table_body_begin, t_table_body_row_begin, t_table_body_row_checkbox, t_table_body_row_cell,
         t_table_body_row_end, t_table_body_end, t_table_end, t_form_end, t_pagination_begin,
         t_pagination_end, t_previous_page, t_next_page, t_active_page, t_inactive_page, t_unique_id
  FROM pgapex.tabularform_region tfr
  LEFT JOIN pgapex.tabularform_template tft ON tft.template_id = tfr.template_id
  WHERE tfr.region_id = i_region_id;

  SELECT ARRAY(
      SELECT ROW(tfc.view_column_name, tfc.heading, tfc.sequence, tfc.is_text_escaped, tfcl.url, tfcl.link_text, tfcl.attributes)
      FROM pgapex.tabularform_column tfc
      LEFT JOIN pgapex.tabularform_column_link tfcl ON tfcl.tabularform_column_id = tfc.tabularform_column_id
      WHERE tfc.region_id = i_region_id
      ORDER BY tfc.sequence
  ) INTO r_tabularform_columns;

  SELECT ARRAY(
      SELECT ROW(tff.tabularform_function_id::text, tff.button_label, tfbt.template)
      FROM pgapex.tabularform_function tff
	    INNER JOIN pgapex.tabularform_button_template tfbt ON tff.template_id=tfbt.template_id
	    WHERE tff.region_id = i_region_id
	    ORDER BY tff.sequence
  ) INTO r_tabularform_buttons;

  t_form_begin := replace(t_form_begin, '#TABULARFORM_FUNCTION_ID#', i_region_id::text);

  t_response := t_tabularform_begin || t_form_begin || t_buttons_row_begin;

  FOREACH r_tabularform_button IN ARRAY r_tabularform_buttons
    LOOP
      t_button := r_tabularform_button.template;
      t_button := replace(t_button, '#VALUE#', r_tabularform_button.tabularform_function_id);
      t_button := replace(t_button, '#LABEL#', r_tabularform_button.button_label);
      t_response := t_response || t_button;
  END LOOP;

  t_response := t_response || t_buttons_row_end || t_table_begin;

  IF b_show_header THEN
    t_response := t_response || t_table_header_begin || t_table_header_row_begin || t_table_header_checkbox;

    FOREACH r_tabularform_column IN ARRAY r_tabularform_columns
    LOOP
      t_response := t_response || replace(t_table_header_cell, '#CELL_CONTENT#', r_tabularform_column.heading);
    END LOOP;

    t_response := t_response || t_table_header_row_end || t_table_header_end;
  END IF;

  t_response := t_response || t_table_body_begin;

  IF j_data IS NOT NULL THEN
    FOR j_row IN SELECT * FROM json_array_elements(j_data)
    LOOP
      t_body_checkbox := t_table_body_row_checkbox;
      t_body_checkbox := replace(t_body_checkbox, '#UNIQUE_ID_VALUE#', (j_row->>t_unique_id)::text);

      t_response := t_response || t_table_body_row_begin || t_body_checkbox;
        FOREACH r_tabularform_column IN ARRAY r_tabularform_columns
        LOOP
          IF r_tabularform_column.view_column_name IS NOT NULL THEN
            t_cell_content := COALESCE(j_row->>r_tabularform_column.view_column_name, '');
            IF r_tabularform_column.is_text_escaped THEN
              t_cell_content := pgapex.f_app_html_special_chars(t_cell_content);
            END IF;
            t_response := t_response || replace(t_table_body_row_cell, '#CELL_CONTENT#', t_cell_content);
          ELSE
            FOR r_column IN SELECT * FROM json_each_text(j_row)
            LOOP
              r_tabularform_column.link_text := replace(r_tabularform_column.link_text, '%' || r_column.key || '%', coalesce(r_column.value, ''));
              r_tabularform_column.url := replace(r_tabularform_column.url, '%' || r_column.key || '%', coalesce(r_column.value, ''));
            END LOOP;
            IF r_tabularform_column.is_text_escaped THEN
              r_tabularform_column.link_text := pgapex.f_app_html_special_chars(r_tabularform_column.link_text);
            END IF;
            t_response := t_response || replace(t_table_body_row_cell, '#CELL_CONTENT#', '<a href="' || r_tabularform_column.url || '" ' || COALESCE(r_tabularform_column.attributes, '') || '>' || r_tabularform_column.link_text || '</a>');
          END IF;
        END LOOP;
      t_response := t_response || t_table_body_row_end;
    END LOOP;
  END IF;

  t_response := t_response || t_table_body_end || t_table_end|| t_form_end || t_tabularform_end;

  v_url_prefix := pgapex.f_app_get_setting('application_root') || '/app/' || pgapex.f_app_get_setting('application_id') || '/' || pgapex.f_app_get_setting('page_id') || '?' || v_pagination_query_param || '=';

  IF i_page_count > 1 THEN
    t_pagination := t_pagination_begin;

    IF i_current_page > 1 THEN
      t_pagination := t_pagination || replace(t_previous_page, '#LINK#', v_url_prefix || 1);
    END IF;

    FOR p in 1 .. i_page_count
    LOOP
      IF p = i_current_page THEN
        t_pagination := t_pagination || replace(replace(t_active_page, '#LINK#', v_url_prefix || p), '#NUMBER#', p::varchar);
      ELSE
        t_pagination := t_pagination || replace(replace(t_inactive_page, '#LINK#', v_url_prefix || p), '#NUMBER#', p::varchar);
      END IF;
    END LOOP;

    IF i_current_page < i_page_count THEN
      t_pagination := t_pagination || replace(t_next_page, '#LINK#', v_url_prefix || i_page_count);
    END IF;

    t_pagination := t_pagination || t_pagination_end;
  END IF;

  RETURN replace(t_response, '#PAGINATION#', t_pagination);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_tabularform_region(
    i_region_id  INT
  , j_get_params JSONB
)
  RETURNS TEXT AS $$
DECLARE
  t_region_template         TEXT;
  v_schema_name             VARCHAR;
  v_view_name               VARCHAR;
  i_items_per_page          INT;
  b_show_header             BOOLEAN;
  v_pagination_query_param  VARCHAR;
  i_current_page            INT      := 1;
  i_row_count               INT;
  i_page_count              INT;
  i_offset                  INT      := 0;
  j_rows                    JSON;
  v_query                   VARCHAR;
BEGIN
  SELECT tfr.schema_name, tfr.view_name, tfr.items_per_page, tfr.show_header, pi.name
  INTO v_schema_name, v_view_name, i_items_per_page, b_show_header, v_pagination_query_param
  FROM pgapex.tabularform_region tfr
  LEFT JOIN pgapex.page_item pi ON tfr.region_id = pi.tabularform_region_id
  WHERE tfr.region_id = i_region_id;

  IF j_get_params IS NOT NULL AND j_get_params ? v_pagination_query_param THEN
    i_current_page := (j_get_params->>v_pagination_query_param)::INT;
  END IF;

  i_row_count := pgapex.f_app_get_row_count(v_schema_name, v_view_name);
  i_page_count := ceil(i_row_count::float/i_items_per_page::float);

  IF (i_page_count < i_current_page) OR (i_current_page < 1) THEN
    i_current_page := 1;
  END IF;

  i_offset := (i_current_page - 1) * i_items_per_page;

  v_query := 'SELECT json_agg(a) FROM (SELECT * FROM ' || v_schema_name || '.' || v_view_name || ' LIMIT ' || i_items_per_page || ' OFFSET ' || i_offset || ') AS a';

  SELECT res_rows INTO j_rows FROM dblink(pgapex.f_app_get_dblink_connection_name(), v_query, FALSE) AS ( res_rows JSON );

  RETURN pgapex.f_app_get_tabularform_region_with_template(i_region_id, j_rows, v_pagination_query_param, i_page_count, i_current_page, b_show_header);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_detailview_table_with_template(
  i_region_id              INT
, j_data                   JSON
, v_pagination_query_param VARCHAR
, i_page_count             INT
, i_current_page           INT
, b_show_header            BOOLEAN
)
  RETURNS TEXT AS $$
DECLARE
  t_response                TEXT;
  t_pagination              TEXT     := '';
  v_url_prefix              VARCHAR;
  t_detailview_table_begin  TEXT;
  t_detailview_table_end    TEXT;
  t_header_begin            TEXT;
  t_header_row_begin        TEXT;
  t_header_cell             TEXT;
  t_header_row_end          TEXT;
  t_header_end              TEXT;
  t_body_begin              TEXT;
  t_body_row_begin          TEXT;
  t_body_row_link_to_page   TEXT;
  t_body_row_cell_content   TEXT;
  t_body_row_end            TEXT;
  t_body_end                TEXT;
  t_pagination_begin        TEXT;
  t_pagination_end          TEXT;
  t_previous_page           TEXT;
  t_next_page               TEXT;
  t_active_page             TEXT;
  t_inactive_page           TEXT;
  t_unique_id               TEXT;
  r_detailview_column       pgapex.t_column_with_link;
  r_detailview_columns      pgapex.t_column_with_link[];
  j_row                     JSON;
  r_column                  RECORD;
  t_cell_content            TEXT;
BEGIN
  SELECT dvtt.detailview_table_begin, dvtt.detailview_table_end, dvtt.header_begin, dvtt.header_row_begin,
         dvtt.header_cell, dvtt.header_row_end, dvtt.header_end, dvtt.body_begin, dvtt.body_row_begin,
         dvtt.body_row_link_to_page, dvtt.body_row_cell_content, dvtt.body_row_end, dvtt.body_end,
         dvtt.pagination_begin, dvtt.pagination_end, dvtt.previous_page, dvtt.next_page, dvtt.active_page,
         dvtt.inactive_page, dvr.unique_id
  INTO t_detailview_table_begin, t_detailview_table_end, t_header_begin, t_header_row_begin,
       t_header_cell, t_header_row_end, t_header_end, t_body_begin, t_body_row_begin,
       t_body_row_link_to_page, t_body_row_cell_content, t_body_row_end, t_body_end,
       t_pagination_begin, t_pagination_end, t_previous_page, t_next_page, t_active_page, t_inactive_page, t_unique_id
  FROM pgapex.detailview_region dvr
  LEFT JOIN pgapex.detailview_table_template dvtt ON dvr.table_template_id = dvtt.template_id
  WHERE dvr.region_id = i_region_id;

  SELECT ARRAY(
	    SELECT ROW(dvc.view_column_name, dvc.heading, dvc.sequence, dvc.is_text_escaped, dvcl.url, dvcl.link_text, dvcl.attributes)
	    FROM pgapex.detailview_column dvc
	    LEFT JOIN pgapex.detailview_column_link dvcl ON dvc.detailview_column_id = dvcl.detailview_column_id
	    WHERE dvc.region_id = i_region_id
	    ORDER BY dvc.sequence
  ) INTO r_detailview_columns;

  t_response := t_detailview_table_begin;

  IF b_show_header THEN
    t_response := t_response || t_header_begin || t_header_row_begin || '<th></th>';

    FOREACH r_detailview_column IN ARRAY r_detailview_columns
    LOOP
      t_response := t_response || replace(t_header_cell, '#CELL_CONTENT#', r_detailview_column.heading);
    END LOOP;

    t_response := t_response || t_header_row_end || t_header_end;
  END IF;

  t_response := t_response || t_body_begin;

  IF j_data IS NOT NULL THEN
    FOR j_row IN SELECT * FROM json_array_elements(j_data)
    LOOP
      t_response := t_response || t_body_row_begin || t_body_row_link_to_page;
        FOREACH r_detailview_column IN ARRAY r_detailview_columns
        LOOP
          IF r_detailview_column.view_column_name IS NOT NULL THEN
            t_cell_content := COALESCE(j_row->>r_detailview_column.view_column_name, '');
            IF r_detailview_column.is_text_escaped THEN
              t_cell_content := pgapex.f_app_html_special_chars(t_cell_content);
            END IF;
            t_response := t_response || replace(t_body_row_cell_content, '#CELL_CONTENT#', t_cell_content);
          ELSE
            FOR r_column IN SELECT * FROM json_each_text(j_row)
            LOOP
              r_detailview_column.link_text := replace(r_detailview_column.link_text, '%' || r_column.key || '%', coalesce(r_column.value, ''));
              r_detailview_column.url := replace(r_detailview_column.url, '%' || r_column.key || '%', coalesce(r_column.value, ''));
            END LOOP;
            IF r_detailview_column.is_text_escaped THEN
              r_detailview_column.link_text := pgapex.f_app_html_special_chars(r_detailview_column.link_text);
            END IF;
            t_response := t_response || replace(t_body_row_cell_content, '#CELL_CONTENT#', '<a href="' || r_detailview_column.url || '" ' || COALESCE(r_detailview_column.attributes, '') || '>' || r_detailview_column.link_text || '</a>');
          END IF;
        END LOOP;
      t_response := t_response || t_body_row_end;
    END LOOP;
  END IF;

  t_response := t_response || t_body_end || t_detailview_table_end;

  v_url_prefix := pgapex.f_app_get_setting('application_root') || '/app/' || pgapex.f_app_get_setting('application_id') || '/' || pgapex.f_app_get_setting('page_id') || '?' || v_pagination_query_param || '=';

  IF i_page_count > 1 THEN
    t_pagination := t_pagination_begin;

    IF i_current_page > 1 THEN
      t_pagination := t_pagination || replace(t_previous_page, '#LINK#', v_url_prefix || 1);
    END IF;

    FOR p in 1 .. i_page_count
    LOOP
      IF p = i_current_page THEN
        t_pagination := t_pagination || replace(replace(t_active_page, '#LINK#', v_url_prefix || p), '#NUMBER#', p::varchar);
      ELSE
        t_pagination := t_pagination || replace(replace(t_inactive_page, '#LINK#', v_url_prefix || p), '#NUMBER#', p::varchar);
      END IF;
    END LOOP;

    IF i_current_page < i_page_count THEN
      t_pagination := t_pagination || replace(t_next_page, '#LINK#', v_url_prefix || i_page_count);
    END IF;

    t_pagination := t_pagination || t_pagination_end;
  END IF;

  RETURN replace(t_response, '#PAGINATION#', t_pagination);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_detail_view_table(
    i_region_id  INT
  , j_get_params JSONB
)
  RETURNS TEXT AS $$
DECLARE
  t_region_template        TEXT;
  v_schema_name            VARCHAR;
  v_view_name              VARCHAR;
  i_items_per_page         INT;
  b_show_header            BOOLEAN;
  v_pagination_query_param VARCHAR;
  i_current_page           INT      := 1;
  i_row_count              INT;
  i_page_count             INT;
  i_offset                 INT      := 0;
  j_rows                   JSON;
  v_query                  VARCHAR;
BEGIN
  SELECT dvr.schema_name, dvr.view_name, dvr.items_per_page, dvr.show_header, pi.name
  INTO v_schema_name, v_view_name, i_items_per_page, b_show_header, v_pagination_query_param
  FROM pgapex.detailview_region dvr
  LEFT JOIN pgapex.page_item pi ON dvr.region_id = pi.detailview_region_id
  WHERE dvr.region_id = i_region_id;

  IF j_get_params IS NOT NULL AND j_get_params ? v_pagination_query_param THEN
    i_current_page := (j_get_params->>v_pagination_query_param)::INT;
  END IF;

  i_row_count := pgapex.f_app_get_row_count(v_schema_name, v_view_name);
  i_page_count := ceil(i_row_count::float/i_items_per_page::float);

  IF (i_page_count < i_current_page) OR (i_current_page < 1) THEN
    i_current_page := 1;
  END IF;

  i_offset := (i_current_page - 1) * i_items_per_page;

  v_query := 'SELECT json_agg(a) FROM (SELECT * FROM ' || v_schema_name || '.' || v_view_name || ' LIMIT ' || i_items_per_page || ' OFFSET ' || i_offset || ') AS a';

  SELECT res_rows INTO j_rows FROM dblink(pgapex.f_app_get_dblink_connection_name(), v_query, FALSE) AS ( res_rows JSON );

  RETURN pgapex.f_app_get_detailview_table_with_template(i_region_id, j_rows, v_pagination_query_param, i_page_count, i_current_page, b_show_header);
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_detail_view_with_template(
    i_region_id   INT
  , j_row         JSON
)
  RETURNS TEXT AS $$
DECLARE
  t_detailview_begin    TEXT;
  t_detailview_end      TEXT;
  t_column_heading      TEXT;
  t_column_content      TEXT;
  t_response            TEXT;
  r_detailview_column   pgapex.t_column_with_link;
  r_detailview_columns  pgapex.t_column_with_link[];
  t_heading             TEXT;
  t_content             TEXT;
  r_column              RECORD;
BEGIN
  SELECT dvt.detailview_begin, dvt.detailview_end, dvt.column_heading, dvt.column_content
  INTO t_detailview_begin, t_detailview_end, t_column_heading, t_column_content
  FROM pgapex.detailview_region dvr
  LEFT JOIN pgapex.detailview_template dvt ON dvr.template_id = dvt.template_id
  WHERE dvr.region_id = i_region_id;

  SELECT ARRAY (
	  SELECT ROW(dvc.view_column_name, dvc.heading, dvc.sequence, dvc.is_text_escaped, dvcl.url, dvcl.link_text, dvcl.attributes)
	  FROM pgapex.detailview_column dvc
	  LEFT JOIN pgapex.detailview_column_link dvcl ON dvc.detailview_column_id = dvcl.detailview_column_id
	  WHERE dvc.region_id = i_region_id
	  ORDER BY dvc.sequence
  ) INTO r_detailview_columns;

  t_response := t_detailview_begin;

  IF j_row IS NOT NULL THEN
    FOREACH r_detailview_column IN ARRAY r_detailview_columns
      LOOP
        IF r_detailview_column.view_column_name IS NOT NULL THEN
          t_heading := r_detailview_column.heading;
          t_content := COALESCE(j_row->>r_detailview_column.view_column_name, '');

          t_response := t_response || replace(t_column_heading, '#COLUMN_HEADING#', t_heading);
          t_response := t_response || replace(t_column_content, '#COLUMN_CONTENT#', t_content);
        ELSE
          FOR r_column IN SELECT * FROM json_each_text(j_row)
            LOOP
              r_detailview_column.link_text := replace(r_detailview_column.link_text, '%' || r_column.key || '%', coalesce(r_column.value, ''));
              r_detailview_column.url := replace(r_detailview_column.url, '%' || r_column.key || '%', coalesce(r_column.value, ''));
            END LOOP;
            IF r_detailview_column.is_text_escaped THEN
              r_detailview_column.link_text := pgapex.f_app_html_special_chars(r_detailview_column.link_text);
            END IF;
            t_heading := r_detailview_column.heading;

            t_response := t_response || replace(t_column_heading, '#COLUMN_HEADING#', t_heading);
            t_response := t_response || replace(t_column_content, '#COLUMN_CONTENT#', '<a href="' ||
              r_detailview_column.url || '" ' || COALESCE(r_detailview_column.attributes, '') || '>' || r_detailview_column.link_text || '</a>');
        END IF;
      END LOOP;
  END IF;

  t_response := t_response || t_detailview_end;

  RETURN t_response;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

----------

CREATE OR REPLACE FUNCTION pgapex.f_app_get_detail_view(
    i_region_id  INT
  , j_get_params JSONB
)
  RETURNS TEXT AS $$
DECLARE
  v_schema_name       VARCHAR;
  v_view_name         VARCHAR;
  v_linked_column     VARCHAR;
  v_page_query_param  VARCHAR;
  v_query             VARCHAR;
  v_argument          VARCHAR;
  t_negative_response TEXT;
  j_row               JSONB;
BEGIN
  SELECT dvr.schema_name, dvr.view_name, dvr.linked_column, pi.name
  INTO v_schema_name, v_view_name, v_linked_column, v_page_query_param
  FROM pgapex.detailview_region dvr
  LEFT JOIN pgapex.page_item pi ON dvr.region_id = pi.detailview_region_id
  WHERE dvr.region_id = i_region_id;

  SELECT (j_get_params->>v_linked_column)::varchar INTO v_argument;

  IF (v_argument = '') IS FALSE THEN
    v_query := 'SELECT json_agg(a) FROM (SELECT * FROM ' || v_schema_name || '.' || v_view_name || ' WHERE ' ||
      v_linked_column || ' = ' || quote_literal(v_argument) || ' LIMIT 1) AS a';
  ELSE
    v_query := 'SELECT json_agg(a) FROM (SELECT * FROM ' || v_schema_name || '.' || v_view_name || ' LIMIT 1) AS a';
  END IF;

  SELECT res_rows INTO j_row FROM dblink(pgapex.f_app_get_dblink_connection_name(), v_query, FALSE) AS (res_rows JSON);

  IF j_row IS NOT NULL THEN
    RETURN pgapex.f_app_get_detail_view_with_template(i_region_id, (j_row->>0)::json);
  ELSE
    t_negative_response := '<h4></span>Row not found</h4>';
    t_negative_response := t_negative_response || '<h5>View <b>' || v_schema_name || '.' || v_view_name ||
      '</b> has not row, where <b>' || v_linked_column || '</b> is <b>' || v_argument || '</b></h5>';

    RETURN t_negative_response;
  END IF;
END
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pgapex, public, pg_temp;

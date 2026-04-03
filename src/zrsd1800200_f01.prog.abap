*&---------------------------------------------------------------------*
*&  Include           ZRSDX00200_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialization .

  p_vbtyp = 'C'.

  DATA(lv_curr_year)  = sy-datum+0(4).
  DATA(lv_curr_month) = sy-datum+4(2).

  IF lv_curr_month = 1.
    DATA(lv_prev_month) = 12.
    DATA(lv_prev_year)  = lv_curr_year - 1.
  ELSE.
    lv_prev_month = lv_curr_month - 1.
    lv_prev_year  = lv_curr_year.
  ENDIF.

  DATA(lv_audat) = lv_prev_year && lv_prev_month && '01'.
  s_audat = VALUE #( sign = 'I' option = 'BT' low = lv_audat high = sy-datum ).
  APPEND s_audat. CLEAR s_audat.



ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM at_selection_screen_output .

  LOOP AT SCREEN.
    IF radi1 EQ abap_true. "'X'
      IF screen-group1 EQ 'M1'.
        screen-active = 0.
      ENDIF.
    ELSEIF radi2 EQ abap_true.
      IF screen-group1 EQ 'M1'.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " AT_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM at_selection_screen .

  IF s_audat-high > sy-datum.
    MESSAGE '미래 날자는 입력할 수 없습니다.' TYPE 'E'.
  ENDIF.

ENDFORM.                    " AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT *
    FROM vbak
    INTO TABLE gt_data
    WHERE vbtyp = p_vbtyp
      AND audat IN s_audat
      AND vbeln IN s_vbeln.

  IF sy-subrc = 0.
  ELSE.
    gv_err = 'X'.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ADD_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_add_info .

ENDFORM.                    " GET_ADD_INFO
*&---------------------------------------------------------------------*
*&      Form  START_OF_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_of_selection .
  PERFORM get_data.

  IF gt_data IS NOT INITIAL.
    PERFORM get_add_info.
  ELSE.
*    MESSAGE E003(ZSYMS25).
*    MESSAGE S003(ZSYMS25) DISPLAY LIKE 'E'.
*    MESSAGE S003(ZSYMS25).
*    MESSAGE S003(ZSYMS25) DISPLAY LIKE 'I'.
*    MESSAGE I003(ZSYMS25).
    MESSAGE I003(ZSYMS25) DISPLAY LIKE 'S'.
    EXIT.
  ENDIF.

ENDFORM.                    " START_OF_SELECTION
*&---------------------------------------------------------------------*
*&      Form  BUILD_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_grid .
  PERFORM create_container.

  PERFORM set_grid_layout USING 'P'
                                gs_layout
                                gs_variant.

  PERFORM fieldcatalog_merge  TABLES gt_fieldcat
                                     gt_data
                               USING 'GS_DATA'.

  PERFORM fieldcatalog_modify TABLES gt_fieldcat.

*  PERFORM set_grid_fcode USING gt_exclude.

  PERFORM event_handler_register.

*  PERFORM build_cell_tab.

*  PERFORM alv_display_head.

*  PERFORM set_f4_field_0100 USING go_grid.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_variant                    = gs_variant
      i_save                        = 'A'
      i_default                     = abap_true
      is_layout                     = gs_layout
      it_toolbar_excluding          = gt_exclude
    CHANGING
      it_outtab                     = gt_data
      it_fieldcatalog               = gt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.



ENDFORM.                    " BUILD_GRID
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GO_GRID  text
*----------------------------------------------------------------------*
FORM refresh_grid  USING po_grid TYPE REF TO cl_gui_alv_grid.
  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_on.
  ls_stable-col = abap_on.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.
ENDFORM.                    " REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_container .
  CREATE OBJECT go_cont_doc_0100
    EXPORTING
      repid     = sy-repid
      dynnr     = sy-dynnr
      side      = cl_gui_docking_container=>dock_at_left
      extension = 2000.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_cont_doc_0100.
ENDFORM.                    " CREATE_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0163   text
*      -->P_GS_LAYOUT  text
*      -->P_GS_VARIANT  text
*----------------------------------------------------------------------*
FORM set_grid_layout  USING    pv_gubun
                               ps_layout TYPE lvc_s_layo
                               ps_variant TYPE disvariant.
  CLEAR: ps_layout, ps_variant.

  ps_layout-zebra      = abap_on.
  ps_layout-sel_mode   = 'D'.
  ps_layout-no_rowmark = 'X'.
  ps_layout-cwidth_opt = abap_on.
  ps_layout-col_opt    = abap_on.
  ps_layout-info_fname = text-f71.   "'LINECOLOR'.
*  ps_layout-edit = abap_true.

  IF pv_gubun NE 'T'.
    ps_layout-stylefname = gc_fname_celltab.
  ENDIF.

  ps_variant-report = sy-repid.
  ps_variant-handle = pv_gubun.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  FIELDCATALOG_MERGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text
*      -->P_GT_DATA  text
*      -->P_0172   text
*----------------------------------------------------------------------*
FORM fieldcatalog_merge  TABLES pt_fcat TYPE lvc_t_fcat
                                pt_table
                          USING pv_itab_name.
  DATA: lt_fieldcat       TYPE slis_t_fieldcat_alv.
  DATA: lv_memory_id_clear TYPE string,
        lv_memory_id_hash  TYPE hash160.

  DATA: lv_structure_name  TYPE dd02l-tabname.
  DATA: lv_alvbuffer(11).

*-- 버퍼에 삭제.
  IF pv_itab_name IS NOT INITIAL.

    CONCATENATE sy-repid pv_itab_name
           INTO lv_memory_id_clear.

    CALL FUNCTION 'CALCULATE_HASH_FOR_CHAR'
      EXPORTING
        data   = lv_memory_id_clear
      IMPORTING
        hash   = lv_memory_id_hash
      EXCEPTIONS
        OTHERS = 1.

    FREE MEMORY ID lv_memory_id_hash.

  ENDIF.

*  LV_ALVBUFFER = 'BFOFF EUOFF'.
*  SET PARAMETER ID 'ALVBUFFER' FIELD LV_ALVBUFFER.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = pv_itab_name
      i_structure_name       = lv_structure_name
      i_client_never_display = abap_true
      i_inclname             = sy-repid
      i_bypassing_buffer     = abap_true
      i_buffer_active        = space
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      OTHERS                 = 1.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fieldcat
    IMPORTING
      et_fieldcat_lvc = pt_fcat[]
    TABLES
      it_data         = pt_table
    EXCEPTIONS
      OTHERS          = 1.

*-- pt_fcat 변수에 p_itab_name 구조대로 헤더가 셋팅이 됨.
  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
      i_refresh_buffer = abap_true
    CHANGING
      ct_fieldcat      = pt_fcat[]
    EXCEPTIONS
      OTHERS           = 1.

ENDFORM.                    " FIELDCATALOG_MERGE
*&---------------------------------------------------------------------*
*&      Form  FIELDCATALOG_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcatalog_modify  TABLES pt_fcat TYPE lvc_t_fcat.
  DATA: ls_fcat TYPE lvc_s_fcat.

  SORT pt_fcat BY fieldname.
  LOOP AT pt_fcat INTO ls_fcat.
    ls_fcat-key        = space.
    ls_fcat-no_merging = abap_true.

    CASE ls_fcat-fieldname.
      WHEN 'VBELN'.
        ls_fcat-col_pos = 1.
        ls_fcat-coltext  = text-f01.
        ls_fcat-key  = gc_x.
      WHEN 'VBTYP'.
        ls_fcat-col_pos = 2.
        ls_fcat-coltext  = text-f02.
        ls_fcat-key  = gc_x.
        ls_fcat-just     = gc_c.
      WHEN 'VKORG'.
        ls_fcat-col_pos = 3.
        ls_fcat-coltext  = text-f03.
*        ls_fcat-key  = gc_x.
      WHEN 'VTWEG'.
        ls_fcat-col_pos = 4.
        ls_fcat-coltext  = text-f04.
      WHEN 'ERDAT'.
        ls_fcat-col_pos = 5.
        ls_fcat-coltext  = text-f05.
      WHEN 'ERZET'.
        ls_fcat-col_pos = 6.
        ls_fcat-coltext  = text-f06.
      WHEN 'ERNAM'.
        ls_fcat-col_pos = 7.
        ls_fcat-coltext  = text-f07.
      WHEN OTHERS.
        ls_fcat-no_out   = abap_true.
    ENDCASE.
    MODIFY pt_fcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.                    " FIELDCATALOG_MODIFY
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM event_handler_register .
  IF go_event IS INITIAL.
    CREATE OBJECT go_event.
  ENDIF.
**               go_event->on_data_changed FOR go_grid,
**               go_event->on_toolbar FOR go_grid,
**               go_event->on_user_command FOR go_grid.
*
*  CALL METHOD go_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  SET HANDLER:
*  go_event->on_hotspot_click FOR go_grid,
*               go_event->on_data_changed FOR go_grid,
*               go_event->on_data_changed_finished FOR go_grid,
               go_event->on_toolbar FOR go_grid.
*               go_event->on_user_command FOR go_grid,
*               go_event->on_f4_0100 FOR go_grid.
ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  EVENT_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM event_toolbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                                pv_interactive.

ENDFORM.                    " EVENT_TOOLBAR

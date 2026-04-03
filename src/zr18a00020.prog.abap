*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZR18A00020
* Desc       : Create Sales Order by PO
* Transaction: ZR18A00020
* Creator    : REM0018
* Create day  : 2026.01.11
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.11    박규태              최초작성
*&---------------------------------------------------------------------*

REPORT ZR18A00020.

INCLUDE : yg1000,                                " 개발 공용 Include
            yg1000_cn,                           " CoNtainer Include
              yg1000_av.

DATA : go_dc2000_1 TYPE REF TO cl_gui_docking_container,    "#EC NEEDED
       go_sc2000_1 TYPE REF TO cl_gui_splitter_container,   "#EC NEEDED
       go_ic2000_1 TYPE REF TO cl_gui_container,            "#EC NEEDED
       go_av2000_1 TYPE REF TO cl_gui_alv_grid,             "#EC NEEDED
       go_ic2000_2 TYPE REF TO cl_gui_container,            "#EC NEEDED
       go_av2000_2 TYPE REF TO cl_gui_alv_grid,             "#EC NEEDED
       go_ic2000_3 TYPE REF TO cl_gui_container,            "#EC NEEDED
       go_tx2000_1 TYPE REF TO cl_gui_textedit.             "#EC NEEDED


TABLES: vbak, vbap.
DATA: gt_vbak18   TYPE TABLE OF zvbak18.
DATA: gt_vbap_t TYPE TABLE OF zvbap18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.
DATA: gt_vbap18   TYPE TABLE OF zvbap18.

* so_do Link
DATA: gt_sodo TYPE TABLE OF zlips18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel.


*&--------------------------------*
* Selection 스크린
*&--------------------------------*
SELECT-OPTIONS:
 so_vbeln FOR vbak-vbeln,
 so_erdat FOR vbak-erdat OBLIGATORY.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.


*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM 1000_onli.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM 1000_afte.


*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 2000_status OUTPUT.

  SET PF-STATUS '2000'.

  IF sy-tcode <> 'ZR18A00060'.
    SET TITLEBAR '2000'.
  ELSE.
    SET TITLEBAR '3000'.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  AV2000_X_MAKE  OUTPUT
*&---------------------------------------------------------------------*
MODULE av2000_x_make OUTPUT.


  0o_dc_make : 'GO_DC2000_1' 1 2500.

  0o_sc_make : 'GO_SC2000_1' go_dc2000_1 2 1.

  0o_ic_make : 'GO_IC2000_1' go_sc2000_1 1 1,
               'GO_IC2000_2' go_sc2000_1 2 1.

  PERFORM 0o_av_make
   TABLES gt_vbak18
    USING 'GO_AV2000_1' go_ic2000_1
          'ZVBAK18'   " 아밥 딕셔너리에 선언된 테이블, 구조, 뷰를
*                    이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_1' 'X' 'X' 'X'.

  PERFORM 0o_av_make
   TABLES gt_vbap18
    USING 'GO_AV2000_2' go_ic2000_2
          'ZVBAP18' " 프로그램 내의 내부테이블을
*                      이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_2' 'X' 'X' 'X'.


ENDMODULE.                 " AV2000_X_MAKE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  av2000_1_set_before
*&---------------------------------------------------------------------*
FORM av2000_1_set_before USING pv_av_name.                  "#EC *



ENDFORM.                    "av2000_1_set_before

*&---------------------------------------------------------------------*
*&      Form  av2000_2_set_before
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM av2000_2_set_before USING pv_av_name.                  "#EC *

  gs_zs_av_layout-no_toolbar = 'X'.

ENDFORM.                    "av2000_2_set_before


*&---------------------------------------------------------------------*
*&      Form  av2000_1_cell_click
*&---------------------------------------------------------------------*
FORM av2000_1_cell_click                                    "#EC *
  USING pv_av_name
        pc_gubun
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.

  REFRESH gt_vbap18.

  READ TABLE gt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak>) INDEX
ps_row_no-row_id.
  CHECK sy-subrc = 0.

  CASE ps_col-fieldname.
    WHEN 'VBELN'.
      READ TABLE gt_vbap_t TRANSPORTING NO FIELDS
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_vbak>-vbeln.
      IF sy-subrc = 0.
        LOOP AT gt_vbap_t ASSIGNING FIELD-SYMBOL(<ls_vbap_t>)
            FROM sy-tabix USING KEY idx01.
          IF <ls_vbap_t>-vbeln <> <ls_vbak>-vbeln.
            EXIT.
          ENDIF.
          APPEND INITIAL LINE TO gt_vbap18
          ASSIGNING FIELD-SYMBOL(<ls_vbap>).
          MOVE-CORRESPONDING <ls_vbap_t> TO <ls_vbap>.
        ENDLOOP.
      ENDIF.

      SORT gt_vbap18 BY vbeln posnr.

      0o_av_chg_set 'GO_AV2000_2' 'X'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  av2000_2_cell_click
*&---------------------------------------------------------------------*
FORM av2000_2_cell_click                                    "#EC *
  USING pv_av_name
        pc_gubun
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.

*  READ TABLE gt_eban INDEX ps_row_no-row_id.
*  CHECK sy-subrc = 0.
*
*  CASE ps_col-fieldname.
*    WHEN 'BANFN'.
*      0t_TR 'ME53N' 'X' gt_eban-banfn gt_eban-bnfpo '' '' '' '' ''.
*  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AV2000_1_CONTEXT_MENU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM av2000_1_context_menu USING pv_av_name
*                                 po_menu TYPE REF TO cl_ctmenu.
*
**- Status 로 추가 메뉴 설정할 때.
*  CALL METHOD po_menu->load_gui_status
*    EXPORTING
*      program = sy-repid
*      status  = 'AV2000_1'
*      menu    = po_menu.
*
**- 직접 명령 추가할 때.
*  CALL METHOD po_menu->add_function
*    EXPORTING
*      fcode = 'AF01'
*      text  = 'Test'.
*
** hide_functions , disable_functions 등으로 메뉴를 제어할 수 있다.
*
*ENDFORM.                    "AV2000_1_CONTEXT_MENU
*----------------------------------------------------------------------*
* 선택 삭제
*----------------------------------------------------------------------*
FORM 2000_delete.                                           "#EC CALLED

*  DATA : lt_rows LIKE lvc_s_roid OCCURS 0 WITH HEADER LINE.
*  CALL METHOD go_av2000_1->get_selected_rows
*    IMPORTING
*      et_row_no = lt_rows[].
*
*  SORT lt_rows DESCENDING BY row_id.
*
*  LOOP AT lt_rows.
*    DELETE gt_eban INDEX lt_rows-row_id.
*  ENDLOOP.
*
*  CLEAR : gs_zs_av_stbl, gt_zt_av_rows, gt_zt_av_roid.
*  CALL METHOD go_av2000_1->set_selected_rows
*    EXPORTING
*      it_index_rows            = gt_zt_av_rows
*      it_row_no                = gt_zt_av_roid
*      is_keep_other_selections = 'X'.
*
*  0o_av_chg_set 'GO_AV2000_1' abap_true.
**  LOOP AT lt_rows.
**    READ TABLE &2 INDEX lt_rows-row_id.
**    IF sy-subrc = 0.
**      MOVE-CORRESPONDING &2 TO &3.
**      APPEND &3.
**    ENDIF.
**  ENDLOOP.


ENDFORM.                    "2000_delete



*&---------------------------------------------------------------------*
*& Form 1000_onli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM 1000_onli .

*  DATA: lt_vbapv TYPE SORTED TABLE OF vbap WITH UNIQUE KEY vbeln.
  DATA: lt_vbapv TYPE TABLE OF zvbak18.
  DATA: lt_vbap  TYPE TABLE OF vbap WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.

  DATA: lt_lips18v TYPE TABLE OF zlips18.



  REFRESH: gt_vbak18, gt_vbap18, gt_sodo.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbak18
    FROM zvbak18
    WHERE vbeln IN so_vbeln AND
          erdat IN so_erdat.

***  lt_vbapv = CORRESPONDING #( gt_vbak18 DISCARDING DUPLICATES
***                              MAPPING vbeln = vbeln ).

  lt_vbapv = gt_vbak18.
  sort lt_vbapv by vbeln.
  delete ADJACENT DUPLICATES FROM lt_vbapv COMPARING vbeln.

  IF lt_vbapv IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbap_t
      FROM zvbap18
      FOR ALL ENTRIES IN lt_vbapv
      WHERE vbeln = lt_vbapv-vbeln.

* 자릿수 충돌
***    SELECT vgbel vbeln INTO CORRESPONDING FIELDS OF TABLE gt_sodo
***      FROM zlips18
***      FOR ALL ENTRIES IN lt_vbapv
***      WHERE vgbel+0(10) = lt_vbapv-vbeln.

    LOOP AT lt_vbapv ASSIGNING FIELD-SYMBOL(<ls_vbapv>).
      CHECK <ls_vbapv>-vbeln IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_lips18v ASSIGNING
      FIELD-SYMBOL(<ls_lips18v>).
      <ls_lips18v>-vgbel = <ls_vbapv>-vbeln.
    ENDLOOP.

    SORT lt_lips18v BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_lips18v COMPARING vgbel.
    IF lt_lips18v IS NOT INITIAL.
      SELECT vgbel vbeln
        INTO CORRESPONDING FIELDS OF TABLE gt_sodo
        FROM zlips18
        FOR ALL ENTRIES IN lt_lips18v
        WHERE vgbel = lt_lips18v-vgbel.
    ENDIF.

*&--------------------------------*
*** ITEM이 없는 SO건은 제외
*&--------------------------------*
    IF gt_vbap_t IS INITIAL.
      REFRESH gt_vbak18.
    ELSE.
      LOOP AT gt_vbak18 ASSIGNING FIELD-SYMBOL(<gt_vbak>).
        READ TABLE gt_vbap_t TRANSPORTING NO FIELDS
          WITH TABLE KEY idx01 COMPONENTS vbeln = <gt_vbak>-vbeln.
        IF sy-subrc <> 0.
          DELETE gt_vbak18 WHERE vbeln = <gt_vbak>-vbeln.   "30 and 40 에서 업그레이드함.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM 1000_afte .

  DATA: lv_cnt TYPE i.

  CHECK sy-batch = zle18_.

  DESCRIBE TABLE gt_vbak18 LINES lv_cnt.
  MESSAGE s000(oo) WITH lv_cnt '건 조회되었습니다'.

*  SORT gt_vbak18 by vbeln.
*  IF sy-subrc <> 0.
*    EXIT.
*  ENDIF.
*
*  SORT gt_vbap_t by vbeln.
*  IF sy-subrc <> 0.
*    EXIT.
*  ENDIF.

  " 정렬.
  IF LV_CNT > 0.

    IF LV_CNT > 1.
      SORT gt_vbak18 by vbeln.
      SORT gt_vbap_t by vbeln posnr.
    ENDIF.

    CALL SCREEN 2000.
  ENDIF.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_toolbar
  USING pv_av_name
        po_object TYPE REF TO cl_alv_event_toolbar_set
        pv_interactive.

  DATA: ls_tool TYPE stb_button.

  IF sy-tcode <> 'ZR18A00060'.
    CLEAR ls_tool.
    ls_tool-butn_type = zle18_3.
    APPEND ls_tool TO po_object->mt_toolbar.

    CLEAR ls_tool.
    ls_tool-butn_type = zle18_0.
    ls_tool-function  = zle18_CRDO.
    ls_tool-icon      = icon_led_inactive.
    ls_tool-text      = TEXT-t01.
    APPEND ls_tool TO po_object->mt_toolbar.
  ENDIF.

*  CLEAR ls_tool.
*  ls_tool-butn_type = zle18_3.
*
*  CLEAR ls_tool.
*  ls_tool-butn_type = zle18_0.
*  ls_tool-function  = zle18_refe.
*  ls_tool-icon      = icon_led_inactive.
*  ls_tool-text      = TEXT-t01.
*  APPEND ls_tool TO po_object->mT_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_CRDO USING pv_av_name.

  DATA: lt_rows TYPE TABLE OF lvc_s_roid.
  DATA: lv_error.

  CALL METHOD go_av2000_1->get_selected_rows
    IMPORTING
      et_row_no = lt_rows[].

*/-- selected check validation
  PERFORM zz_get_sel_rows TABLES lt_rows
                          USING zle18_CRDO
                          CHANGING lv_error.
  CHECK lv_error IS INITIAL.

*/-- selected check validation confrim dialog
  PERFORM zz_set_sel_rows TABLES lt_rows
                          USING zle18_CRDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_refe USING pv_av_name.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_get_sel_rows
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROWS
*&      --> zle18_CRDO
*&      <-- LV_ERROR
*&---------------------------------------------------------------------*
FORM zz_get_sel_rows  TABLES   pt_rows STRUCTURE lvc_s_roid
                      USING    pv_ucomm
                      CHANGING pv_error.

*/--공란에러
  IF pt_rows[] IS INITIAL.
  ELSE.
* 1개건만 진행
    DESCRIBE TABLE pt_rows LINES DATA(lv_cnt).
    IF lv_cnt > 1.
      MESSAGE e000(oo) WITH 'Select only 1 row'.
    ENDIF.
  ENDIF.


  LOOP AT pt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).
    READ TABLE gt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak>)
      INDEX <ls_rows>-row_id.
    IF sy-subrc = 0.
      CASE pv_ucomm.
        WHEN 'CRDO'.
          PERFORM zz_get_selrows_precheck USING <ls_vbak> CHANGING
pv_error.
      ENDCASE.

*&--------------------------------*
*** 8-2. 실행시 실행할 ITEM이 없으면
*&--------------------------------*
      READ TABLE gt_vbap_t TRANSPORTING NO FIELDS
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_vbak>-vbeln.

      IF sy-subrc <> 0.
        pv_error = zle18_x.
        MESSAGE i000(oo) WITH 'There is no item data'.
        Exit.
      ENDIF.
    ENDIF.

  ENDLOOP.

  CHECK pv_error IS INITIAL.


  CASE pv_ucomm.
    WHEN 'CRDO'.
      PERFORM zz_set_confirm_step USING pv_ucomm CHANGING pv_error.
  ENDCASE.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_set_confirm_step  USING    pv_ucomm
                          CHANGING pv_error.

  DATA: lv_textline1 TYPE spop-textline1,
        lv_textline2 TYPE spop-textline2.

  DATA: lv_answer.

  CASE pv_ucomm.
    WHEN 'CRDO'.
      lv_textline1 = TEXT-m01.
  ENDCASE.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = 'N'
      textline1      = lv_textline1
*     TEXTLINE2      = ' '
      titel          = '[Saving Confirm]'
      start_column   = 55
      start_row      = 10
      cancel_display = ''
    IMPORTING
      answer         = lv_answer.

  IF lv_answer <> zle18_j.
    pv_error = zle18_x.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROWS
*&      --> zle18_CRDO
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows  TABLES   pt_rows STRUCTURE lvc_s_roid
                      USING    pv_ucomm.


  LOOP AT pt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).
    READ TABLE gt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak>)
      INDEX <ls_rows>-row_id.
    IF sy-subrc = 0.
      CASE pv_ucomm.
        WHEN 'CRDO'.
          PERFORM zz_set_sel_rows_ucomm USING pv_ucomm
                                     CHANGING <ls_vbak>.

* Screen Refresh / Reselect
          perform 1000_onli.
          0o_av_chg_set 'GO_AV2000_1' 'X'.
          0o_av_chg_set 'GO_AV2000_2' 'X'.

      ENDCASE.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      <-- <LS_vbak>
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows_ucomm  USING    pv_ucomm
                            CHANGING ps_vbak LIKE LINE OF gt_vbak18.

  DATA: ls_return TYPE bapiret2.
  DATA: lt_vbap   TYPE zttvbap18.

  lt_vbap = gt_vbap_t.

  DELETE lt_vbap WHERE vbeln <> ps_vbak-vbeln.

  CALL METHOD zcl18_lec_auto_plan=>zz_get_do_rtn
    EXPORTING
      is_so_h   = ps_vbak
      it_so_i   = lt_vbap
    IMPORTING
      es_return = ls_return.

  CASE ls_return-type.
    WHEN 'S'.
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save S/O Document'.
  ENDCASE.


ENDFORM.




*&---------------------------------------------------------------------*
*& Form zz_get_selrows_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_precheck  USING    ps_vbak LIKE LINE OF gt_vbak18
                              CHANGING pv_error.

  DATA: lv_vgbel TYPE lips-vgbel.

  lv_vgbel = ps_vbak-vbeln.

  READ TABLE gt_sodo TRANSPORTING NO FIELDS
    WITH TABLE KEY idx01 COMPONENTS vgbel = lv_vgbel.
  IF sy-subrc = 0.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady SO-DO link exist'.
  ENDIF.

ENDFORM.

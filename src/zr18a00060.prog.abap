*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZR18A00060
* Desc       : SY Purchase Auto Processing
* Transaction: ZR18A00060
* Creator    : REM0018
* Create day  : 2026.01.18
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.18    박규태              최초작성
*&---------------------------------------------------------------------*


REPORT ZR18A00060.

INCLUDE : yg1000,                                " 개발 공용 Include
            yg1000_cn,                           " CoNtainer Include
              yg1000_av.

*----------------------------------------------------------------------*
* 전역 변수(Tables, Data) 선언.
*----------------------------------------------------------------------*
* 2000 ALV
DATA : go_cc2000_1 TYPE REF TO cl_gui_custom_container,
       go_av2000_1 TYPE REF TO cl_gui_alv_grid.

TABLES: ekko.
DATA: gt_ekko   TYPE TABLE OF zekko18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS ebeln.
DATA: gt_ekpo_t TYPE TABLE OF zekpo18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS ebeln.

DATA: gt_vbak   TYPE TABLE OF zvbak18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS bstnk.
DATA: gt_vbap_t TYPE TABLE OF zvbap18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.

DATA: gt_likp   TYPE TABLE OF zlikp18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.
DATA: gt_lips_t TYPE TABLE OF zlips18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel. " 아이템 저장용


DATA: gt_vbrk   TYPE TABLE OF zvbrk18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.
DATA: gt_vbrp_t TYPE TABLE OF zvbrp18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel. " 아이템 저장용

DATA: gt_itab TYPE TABLE OF ZS18A00060. " 이게 alv 에 보여주는 용.

DATA: gt_18acom10 TYPE TABLE OF zt18acom10    " 권한 검색용.
      WITH NON-UNIQUE SORTED KEY idx01 COMPONENTS uname.

DATA: gv_auth TYPE abap_bool.   " 권한 확인용.

" 업데이트 됬는지 확인 변수  ( db 접속 최소화 )
DATA: gv_sochg TYPE i.   " 1 이면 변경 x, inital 이면 변경
DATA: gv_dochg TYPE i.
DATA: gv_bichg TYPE i.




*----------------------------------------------------------------------*
* Selection 스크린
*----------------------------------------------------------------------*
SELECT-OPTIONS:
 s_ebeln FOR ekko-ebeln,
 s_aedat FOR ekko-aedat DEFAULT '20250101' TO '20261231'.


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
*& Form 1000_onli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM 1000_onli .

  DATA: lt_ekko type TABLE OF zekko18.  " ekpo 랑 vbak 찾기용

  DATA: lt_vbak type TABLE OF zvbak18.  " vbak 랑 vbap 찾기용

  DATA: lt_vbap type TABLE OF zvbap18.  " lips 넣기 용
  DATA: lt_lips type TABLE OF zlips18.  " likp 랑 vbrp 넣기 용
  DATA: lt_vbrp type TABLE OF zvbrp18.  " vbrk 넣기 용


*  DATA: lt_ekpov TYPE SORTED TABLE OF ekpo WITH UNIQUE KEY ebeln.
*  DATA: lt_ekpov TYPE TABLE OF zekko18.
*  DATA: lt_ekpo  TYPE TABLE OF ekpo WITH NON-UNIQUE SORTED KEY idx01
*        COMPONENTS ebeln.
*
*  DATA: lt_vbak18v TYPE TABLE OF zvbak18.


*&--------------------------------*
  " po 헤더 넣기 ekko
*&--------------------------------*

  IF gt_ekko  IS INITIAL. " ekko가 비어 있다면.
    REFRESH gt_ekko.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ekko   " 데이터 가져오기
    FROM ekko
    WHERE ebeln IN s_ebeln AND
          aedat IN s_aedat.
  ENDIF.

  lt_ekko = gt_ekko.  " 아이템 가져오기 용 테이블에 넣기.
  SORT lt_ekko BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_ekko COMPARING ebeln.  " 중복삭제

  IF lt_ekko IS NOT INITIAL.

*&--------------------------------*
    " po 아이템 넣기 ekpo
*&--------------------------------*

    IF gt_ekpo_t IS INITIAL.  " ekpo 아이템이 비어 있다면.
      REFRESH gt_ekpo_t.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ekpo_t " 아이템 넣기.
        FROM ekpo
        FOR ALL ENTRIES IN lt_ekko
        WHERE ebeln = lt_ekko-ebeln.
    ENDIF.


*&--------------------------------*
    " so 헤더 넣기 vbak
*&--------------------------------*
    IF gv_sochg IS INITIAL.   " so 를 업데이트 해야한다면.
      REFRESH gt_vbak.

      LOOP AT lt_ekko ASSIGNING FIELD-SYMBOL(<ls_ekko>).
        CHECK <ls_ekko>-ebeln IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_vbak ASSIGNING
        FIELD-SYMBOL(<ls_vbak>).
        <ls_vbak>-bstnk = <ls_ekko>-ebeln.  " vbak so 헤더 찾기용
      ENDLOOP.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbak " SO 헤더 가져오기 vbak
        FROM zvbak18
        FOR ALL ENTRIES IN lt_vbak
        WHERE bstnk = lt_vbak-bstnk.

    ENDIF.

  ENDIF.

*&--------------------------------*
  " so 아이템 넣기 vbap
*&--------------------------------*

  IF gv_sochg IS INITIAL.
    REFRESH gt_vbap_t.

    CLEAR lt_vbak.  " 아까 썻으니까 클리어

    lt_vbak = gt_vbak.
    sort lt_vbak by vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbak COMPARING vbeln.

    IF lt_vbak IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbap_t " SO 아이템 가져오기 vbap
        FROM zvbap18
        FOR ALL ENTRIES IN lt_vbak
        WHERE vbeln = lt_vbak-vbeln.
    ENDIF.

  ENDIF.

*&--------------------------------*
  " do 아이템 넣기 lips
*&--------------------------------*

  IF gv_dochg IS INITIAL.   " do 를 업데이트 해야한다면
    REFRESH gt_lips_t.

    lt_vbap = gt_vbap_t.
    sort lt_vbap by vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbap COMPARING vbeln.

    if lt_vbap IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_lips_t " do 아이템 가져오기 lips
        FROM zlips18
        FOR ALL ENTRIES IN lt_vbap
        WHERE vgbel = lt_vbap-vbeln.
    ENDIF.

  ENDIF.

*&--------------------------------*
  " do 헤더 넣기 likp
*&--------------------------------*

  lt_lips =  gt_lips_t.
  sort lt_lips by vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vbeln.

  IF gv_dochg IS INITIAL.
    REFRESH gt_likp.

    IF lt_lips IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp " do 헤더 가져오기 likp
        FROM zlikp18
        FOR ALL ENTRIES IN lt_lips
        WHERE vbeln = lt_lips-vbeln.
    ENDIF.

  ENDIF.

*&--------------------------------*
  " bi 아이템 넣기 vbrp
*&--------------------------------*
  IF gv_bichg IS INITIAL.     " bi 를 업데이트 해야한다면.
    REFRESH gt_vbrp_t.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrp_t " bi 아이템 가져오기 vbap
      FROM zvbrp18
      FOR ALL ENTRIES IN lt_lips
      WHERE vgbel = lt_lips-vbeln.


*&--------------------------------*
    " bi 헤더 넣기 vbrk
*&--------------------------------*

    lt_vbrp =  gt_vbrp_t.
    sort lt_vbrp by vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbrp COMPARING vbeln.

    if lt_vbrp IS NOT INITIAL.
      REFRESH gt_vbrk.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrk " do 헤더 가져오기 likp
        FROM zvbrk18
        FOR ALL ENTRIES IN lt_vbrp
        WHERE vbeln = lt_vbrp-vbeln.
    ENDIF.

  ENDIF.


*&--------------------------------*
  " 권한 가져오기 18acom10
*&--------------------------------*

  IF gt_18acom10 IS INITIAL.  " 권한 테이블이 비어있다면.

    SELECT uname valu2 valu3 valu4      " uname, 비활성화, 권한1, 권한2
      INTO CORRESPONDING FIELDS OF TABLE gt_18acom10
      FROM zt18acom10
      WHERE pcode = zle18_SD_CREATE_AUTO
      AND uname = sy-uname.

*&--------------------------------*
    " 권한 분석
*&--------------------------------*

    IF gt_18acom10 IS INITIAL.
      gv_auth = abap_false.
    ELSE.

      " 일부러 루프로 만듦. 70에서 중복 안되게 했지만 혹시 모르니까.
      LOOP AT gt_18acom10
        ASSIGNING FIELD-SYMBOL(<gs_18acom10>).

        " 비활성화가 확인 된다면.
        IF <gs_18acom10>-valu2 = 'X'.
          gv_auth = abap_false.
          EXIT.
        ELSE.
          IF <gs_18acom10>-valu3 = 'X' AND
            <gs_18acom10>-valu4 = 'X'.
            gv_auth = abap_true.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.


*&--------------------------------*
  " 업데이트 했다는 표시.
*&--------------------------------*
  gv_sochg = 1.
  gv_dochg = 1.
  gv_bichg = 1.


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

  DESCRIBE TABLE gt_ekko LINES lv_cnt.
  MESSAGE s000(oo) WITH lv_cnt '건 조회되었습니다'.

  "alv 용 데이터 넣기
  PERFORM zz_set_itab.

  IF LV_CNT > 0.
    CALL SCREEN 2000.
  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Module 2000_STATUS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE 2000_status OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.

ENDMODULE.



*&---------------------------------------------------------------------*
*& Module AV2000_1_MAKE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE av2000_1_make OUTPUT.

  0o_cc_make 'GO_CC2000_1' 'GV_CX2000_1'.

  PERFORM 0o_av_make
   TABLES gt_itab
    USING 'GO_AV2000_1' go_cc2000_1 'ZS18A00060' 'X'.

  0o_av_refresh 'GO_AV2000_1' '' 'X' 'X'.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form av2000_1_toolbar
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

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_3.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = zle18_crso.
  ls_tool-icon      = icon_led_inactive.
  ls_tool-text      = TEXT-t01.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = zle18_crdo.
  ls_tool-icon      = icon_led_inactive.
  ls_tool-text      = TEXT-t02.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = zle18_crgi.
  ls_tool-icon      = icon_led_inactive.
  ls_tool-text      = TEXT-t03.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = zle18_crbi.
  ls_tool-icon      = icon_led_inactive.
  ls_tool-text      = TEXT-t04.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_3.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = zle18_auto.
  ls_tool-icon      = icon_transfer.
  ls_tool-text      = TEXT-t05.

  IF gv_auth = abap_false.    " 권한에 따라 다르게.
    ls_tool-disabled = abap_true.
  ENDIF.

  APPEND ls_tool TO po_object->mt_toolbar.

ENDFORM.



*----------------------------------------------------------------------*
* Form AV2000_1_SET_BEFORE
*----------------------------------------------------------------------*
* ※ 이 서브루틴은 동적으로 호출합니다. 삭제 전 사용처를 확인하세요.
* ※ 이 서브루틴의 파라미터는 사용하는 곳이 없더라도 삭제 하지 마세요.
*----------------------------------------------------------------------*
*            ★필수작성★ Form문 기능/내용(NXX 표기하여 작성)
*----------------------------------------------------------------------*
* N01 : GO_AV2000_1 Field Catalog, Layout, Variant, Sort 등 설정.
*----------------------------------------------------------------------*
FORM AV2000_1_set_before USING pv_av_name.

* GS_ZS_AV_LAYOUT
  GS_ZS_AV_LAYOUT-ZEBRA = 'X'.
  GS_ZS_AV_LAYOUT-SEL_MODE = 'A'.

* GT_ZT_AV_FCAT
  0O_AV_FCAT_FIELD : 'S' 'EBELN' '',  " Purchasing Doc.
                     ' ' 'KEY' 'X',
                     ' ' 'EMPHASIZE' 'C110',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'HOTSPOT' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'SOSTATU' '',  " STATUS
                     ' ' 'COLTEXT' 'S/O',
                     ' ' 'EMPHASIZE' 'C300',
                     'E' 'OUTPUTLEN' '000010'.

  0O_AV_FCAT_FIELD : 'S' 'DOSTATU' '',  " STATUS
                     ' ' 'COLTEXT' 'D/O',
                     ' ' 'EMPHASIZE' 'C300',
                     'E' 'OUTPUTLEN' '000010'.

  0O_AV_FCAT_FIELD : 'S' 'GISTATU' '',  " STATUS
                     ' ' 'COLTEXT' 'G/I',
                     ' ' 'EMPHASIZE' 'C300',
                     'E' 'OUTPUTLEN' '000010'.

  0O_AV_FCAT_FIELD : 'S' 'BISTATU' '',  " STATUS
                     ' ' 'COLTEXT' 'Billing',
                     ' ' 'EMPHASIZE' 'C300',
                     'E' 'OUTPUTLEN' '000010'.

  0O_AV_FCAT_FIELD : 'S' 'SOVBELN' '',  " Sales Document
                     ' ' 'COLTEXT' 'S/O #',
                     ' ' 'EMPHASIZE' 'C500',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'HOTSPOT' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'DOVBELN' '',  " Delivery
                     ' ' 'COLTEXT' 'D/O #',
                     ' ' 'EMPHASIZE' 'C500',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'HOTSPOT' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'BIVBELN' '',  " Billing Doc.
                     ' ' 'COLTEXT' 'Billing #',
                     ' ' 'EMPHASIZE' 'C500',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'HOTSPOT' 'X'.

ENDFORM.
*----------------------------------------------------------------------*
* Form AV2000_1_CELL_CLICK
*----------------------------------------------------------------------*
* ※ 이 서브루틴은 동적으로 호출합니다. 삭제 전 사용처를 확인하세요.
* ※ 이 서브루틴의 파라미터는 사용하는 곳이 없더라도 삭제 하지 마세요.
*----------------------------------------------------------------------*
*            ★필수작성★ Form문 기능/내용(NXX 표기하여 작성)
*----------------------------------------------------------------------*
* N01 : GO_AV2000_1 BUTTON / DOUBLE / HOTSPOT _CLICK 이벤트 처리.
*----------------------------------------------------------------------*
FORM AV2000_1_CELL_CLICK
  USING pv_av_name
        pc_gubun   " 'B' 버튼 'D' 떠블클릭 'H' 핫스팟
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.


  READ TABLE GT_ITAB ASSIGNING FIELD-SYMBOL(<gs_itab>)
                         INDEX ps_row_no-row_id.

  CHECK sy-subrc EQ 0.

  CASE ps_col-fieldname.
    WHEN 'BIVBELN'. " bi 보여주기

      IF <gs_itab>-bivbeln IS NOT INITIAL.
        SUBMIT zr18a00050
        WITH so_vbeln EQ <gs_itab>-bivbeln
        WITH so_erdat IN s_aedat
        AND RETURN.
      ENDIF.

    WHEN 'DOVBELN'. "do 보여주기

      IF <gs_itab>-dovbeln IS NOT INITIAL.
        SUBMIT zr18a00030
        WITH so_vbeln = <gs_itab>-dovbeln
        WITH so_erdat IN s_aedat
        AND RETURN.
      ENDIF.

    WHEN 'EBELN'.

      IF <gs_itab>-ebeln IS NOT INITIAL.
        SET PARAMETER ID 'BES' FIELD <gs_itab>-ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.


    WHEN 'SOVBELN'.   " so 보여주기

      IF <gs_itab>-sovbeln IS NOT INITIAL.
        SUBMIT zr18a00020
        WITH so_vbeln = <gs_itab>-sovbeln
        WITH so_erdat IN s_aedat
        AND RETURN.
      ENDIF.

  ENDCASE.

ENDFORM.





*&---------------------------------------------------------------------*
*& Form zz_set_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_set_itab.

  REFRESH: gt_itab.

*&--------------------------------*
  " P/O 관련
*&--------------------------------*

  IF gt_ekko IS NOT INITIAL.
    LOOP AT gt_ekko ASSIGNING FIELD-SYMBOL(<gs_ekko>).
      APPEND INITIAL LINE TO gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>).
      <gs_itab>-ebeln = <gs_ekko>-ebeln.


*&--------------------------------*
      " S/O 관련
*&--------------------------------*
      READ TABLE gt_vbak WITH TABLE KEY idx01
      COMPONENTS bstnk = <gs_ekko>-ebeln
      ASSIGNING FIELD-SYMBOL(<gs_vbak>).

      IF sy-subrc = 0.  " 성공 했으면.
        <gs_itab>-sovbeln = <gs_vbak>-vbeln.
        <gs_itab>-sostatu = 'S'.

        READ TABLE gt_vbap_t WITH TABLE KEY idx01
        COMPONENTS vbeln = <gs_vbak>-vbeln
        ASSIGNING FIELD-SYMBOL(<gs_vbap_t>).


*&--------------------------------*
        " D/O 관련
*&--------------------------------*
        IF sy-subrc = 0.  " D/O 관련
          READ TABLE gt_lips_t WITH TABLE KEY idx01
          COMPONENTS vgbel = <gs_vbap_t>-vbeln
          ASSIGNING FIELD-SYMBOL(<gs_lips_t>).

          IF sy-subrc = 0.  " 성공 했으면.
            <gs_itab>-dovbeln = <gs_lips_t>-vbeln.
            <gs_itab>-dostatu = 'S'.

*&--------------------------------*
            " G/I 관련
*&--------------------------------*
            READ TABLE gt_likp WITH TABLE KEY idx01
            COMPONENTS vbeln = <gs_lips_t>-vbeln
            ASSIGNING FIELD-SYMBOL(<gs_likp>).

            IF <gs_likp>-wadat_ist IS NOT INITIAL.  " GI 있다면.
              <gs_itab>-gistatu = 'S'.
            ENDIF.

*&--------------------------------*
            " Billing 관련
*&--------------------------------*
            READ TABLE gt_vbrp_t WITH TABLE KEY idx01
            COMPONENTS vgbel = <gs_lips_t>-vbeln
            ASSIGNING FIELD-SYMBOL(<gs_vbrp_t>).

            IF sy-subrc = 0.  " 성공 했으면.

              <gs_itab>-bivbeln = <gs_vbrp_t>-vbeln.
              <gs_itab>-bistatu = 'S'.

            ENDIF.

          ENDIf.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form zz_set_line_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_set_line_itab USING pv_chgidx.

  IF pv_chgidx IS NOT INITIAL.  " 바뀐게 있다면.
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>)
    INDEX pv_chgidx.

*&--------------------------------*
    " P/O 관련
*&--------------------------------*
    READ TABLE gt_ekko ASSIGNING FIELD-SYMBOL(<gs_ekko>)
    WITH TABLE KEY idx01 COMPONENTS ebeln = <gs_itab>-ebeln.

    CLEAR <gs_itab>.

    <gs_itab>-ebeln = <gs_ekko>-ebeln.


*&--------------------------------*
    " S/O 관련
*&--------------------------------*
    READ TABLE gt_vbak WITH TABLE KEY idx01
    COMPONENTS bstnk = <gs_ekko>-ebeln
    ASSIGNING FIELD-SYMBOL(<gs_vbak>).

    IF sy-subrc = 0.  " 성공 했으면.
      <gs_itab>-sovbeln = <gs_vbak>-vbeln.
      <gs_itab>-sostatu = 'S'.

      READ TABLE gt_vbap_t WITH TABLE KEY idx01
      COMPONENTS vbeln = <gs_vbak>-vbeln
      ASSIGNING FIELD-SYMBOL(<gs_vbap_t>).


*&--------------------------------*
      " D/O 관련
*&--------------------------------*
      IF sy-subrc = 0.  " D/O 관련
        READ TABLE gt_lips_t WITH TABLE KEY idx01
        COMPONENTS vgbel = <gs_vbap_t>-vbeln
        ASSIGNING FIELD-SYMBOL(<gs_lips_t>).

        IF sy-subrc = 0.  " 성공 했으면.
          <gs_itab>-dovbeln = <gs_lips_t>-vbeln.
          <gs_itab>-dostatu = 'S'.

*&--------------------------------*
          " G/I 관련
*&--------------------------------*
          READ TABLE gt_likp WITH TABLE KEY idx01
          COMPONENTS vbeln = <gs_lips_t>-vbeln
          ASSIGNING FIELD-SYMBOL(<gs_likp>).

          IF <gs_likp>-wadat_ist IS NOT INITIAL.  " GI 있다면.
            <gs_itab>-gistatu = 'S'.
          ENDIF.

*&--------------------------------*
          " Billing 관련
*&--------------------------------*
          READ TABLE gt_vbrp_t WITH TABLE KEY idx01
          COMPONENTS vgbel = <gs_lips_t>-vbeln
          ASSIGNING FIELD-SYMBOL(<gs_vbrp_t>).

          IF sy-subrc = 0.  " 성공 했으면.

            <gs_itab>-bivbeln = <gs_vbrp_t>-vbeln.
            <gs_itab>-bistatu = 'S'.

          ENDIF.

        ENDIf.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form av2000_1_uc_crso
*&---------------------------------------------------------------------*
*& S/O 만들기
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_crso USING pv_av_name.

  DATA: lt_rows TYPE TABLE OF lvc_s_roid.
  DATA: lv_error.

  CALL METHOD go_av2000_1->get_selected_rows
    IMPORTING
      et_row_no = lt_rows[].

*/-- selected check validation
  PERFORM zz_get_sel_rows TABLES lt_rows
                          USING zle18_crso
                          CHANGING lv_error.
  CHECK lv_error IS INITIAL.

*/-- selected check validation confrim dialog
  PERFORM zz_set_sel_rows TABLES lt_rows
                          USING zle18_crso.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form av2000_1_uc_CRDO
*&---------------------------------------------------------------------*
*& D/O 만들기
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
*& Form av2000_1_uc_CRGI
*&---------------------------------------------------------------------*
*& Good Issue
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_CRGI USING pv_av_name.

  DATA: lt_rows TYPE TABLE OF lvc_s_roid. " 선택된 라인 넣을 테이블
  DATA: lv_error. " 애러 확인 변수

  CALL METHOD go_av2000_1->get_selected_rows
    IMPORTING
      et_row_no = lt_rows[].  " 선택한 행 가져오기

*/-- selected check validation  " 가능한지, 진행해도 되는지 체크 하는 서브루틴
  PERFORM zz_get_sel_rows TABLES lt_rows
                          USING zle18_CRGI   " GI 만드는 관점에서 확인 'CRGI'
                          CHANGING lv_error.  " 애러 확인 변수 넘기기
  CHECK lv_error IS INITIAL.  " lv_error 에 값이 있으면 나가기

*/-- selected check validation confrim dialog
  PERFORM zz_set_sel_rows TABLES lt_rows  " GI 만드는 서브루틴
                          USING zle18_CRGI.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form av2000_1_uc_CRBI
*&---------------------------------------------------------------------*
*& Billing 만들기
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_CRBI USING pv_av_name.

  DATA: lt_rows TYPE TABLE OF lvc_s_roid. " 선택된 라인 넣을 테이블
  DATA: lv_error. " 애러 확인 변수

  CALL METHOD go_av2000_1->get_selected_rows
    IMPORTING
      et_row_no = lt_rows[].  " 선택한 행 가져오기

*/-- selected check validation  " 유효한지, 진행해도 되는지 체크 하는 서브루틴
  PERFORM zz_get_sel_rows TABLES lt_rows
                          USING zle18_CRBI   " BI 만드는 관점에서 확인 'CRBI'
                          CHANGING lv_error.  " 애러 확인 변수 넘기기
  CHECK lv_error IS INITIAL.  " lv_error 에 값이 있으면 나가기

*/-- selected check validation confrim dialog
  PERFORM zz_set_sel_rows TABLES lt_rows  " BI 만드는 서브루틴
                          USING zle18_CRBI.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form av2000_1_uc_auto
*&---------------------------------------------------------------------*
*& Auto
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_auto USING pv_av_name.

  DATA: lt_rows TYPE TABLE OF lvc_s_roid. " 선택된 라인 넣을 테이블
  DATA: lv_error. " 애러 확인 변수

  CALL METHOD go_av2000_1->get_selected_rows
    IMPORTING
      et_row_no = lt_rows[].  " 선택한 행 가져오기


  IF lt_rows[] IS INITIAL.
    MESSAGE e000(oo) WITH 'Select 1 row'.
  ELSE.
* 1개건만 진행
    DESCRIBE TABLE lt_rows LINES DATA(lv_cnt).  " 몇개의 라인을 골랐는지.
    IF lv_cnt > 1.  " 1개 이상이면 애러 메세지.
      MESSAGE e000(oo) WITH 'Select only 1 row'.
    ENDIF.  " e000(oo) 라서 별도의 추가 코딩을 안해도 나가짐.
  ENDIF.

  LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).  " 선택된 row
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>)
      INDEX <ls_rows>-row_id. " 그 row의 위치에 있는 필드심볼
    IF sy-subrc = 0.
      IF <gs_itab>-ebeln is INITIAL.
        lv_error = zle18_x.
        MESSAGE e000(oo) WITH 'Check Document status!'.
      ELSE.

        " 이미 다 진행된건 지 확인
        PERFORM zz_get_selrows_auto_precheck
            USING <gs_itab> CHANGING lv_error.

        CHECK lv_error IS INITIAL.

        " 확인창 서브 루틴
        PERFORM zz_set_confirm_step
        USING zle18_auto CHANGING lv_error.
        CHECK lv_error IS INITIAL.

        IF <gs_itab>-sostatu <> 'S'. " 아직 so 가 안만들어져 있다면.
          PERFORM zz_get_selrows_so_precheck
            USING <gs_itab> CHANGING lv_error.

          CHECK lv_error IS INITIAL.

          PERFORM zz_set_sel_rows TABLES lt_rows  " so 만드는 서브루틴
            USING zle18_CRSO.
        ENDIF.

        IF <gs_itab>-dostatu <> 'S'. " 아직 do 가 안만들어져 있다면.
          PERFORM zz_get_selrows_do_precheck
            USING <gs_itab> CHANGING lv_error.

          CHECK lv_error IS INITIAL.

          PERFORM zz_set_sel_rows TABLES lt_rows  " do 만드는 서브루틴
            USING zle18_CRDO.
        ENDIF.

        IF <gs_itab>-gistatu <> 'S'. " 아직 gi 가 안만들어져 있다면.
          PERFORM zz_get_selrows_gi_precheck
            USING <gs_itab> CHANGING lv_error.

          CHECK lv_error IS INITIAL.

          PERFORM zz_set_sel_rows TABLES lt_rows  " gi 만드는 서브루틴
            USING zle18_CRGI.
        ENDIF.

        IF <gs_itab>-bistatu <> 'S'. " 아직 bi 가 안만들어져 있다면.
          PERFORM zz_get_selrows_bi_precheck
            USING <gs_itab> CHANGING lv_error.

          CHECK lv_error IS INITIAL.

          PERFORM zz_set_sel_rows TABLES lt_rows  " bi 만드는 서브루틴
            USING zle18_CRBI.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  MESSAGE s000(oo) WITH 'Auto Process Successfully completed'.

ENDFORM.








*&---------------------------------------------------------------------*
*& Form zz_get_sel_rows
*&---------------------------------------------------------------------*
*& 유효성 체크!!!
*&---------------------------------------------------------------------*
*&      --> LT_ROWS
*&      --> zle18_CRDO
*&      <-- LV_ERROR
*&---------------------------------------------------------------------*
FORM zz_get_sel_rows  TABLES   pt_rows STRUCTURE lvc_s_roid
                      USING    pv_ucomm   " 현재 하는 게 뭔지.
                      CHANGING pv_error.

*/--공란에러
  IF pt_rows[] IS INITIAL.
    MESSAGE e000(oo) WITH 'Select 1 row'.
  ELSE.
* 1개건만 진행
    DESCRIBE TABLE pt_rows LINES DATA(lv_cnt).  " 몇개의 라인을 골랐는지.
    IF lv_cnt > 1.  " 1개 이상이면 애러 메세지.
      MESSAGE e000(oo) WITH 'Select only 1 row'.
    ENDIF.  " e000(oo) 라서 별도의 추가 코딩을 안해도 나가짐.
  ENDIF.


  LOOP AT pt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).  " 선택된 row
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>)
      INDEX <ls_rows>-row_id. " 그 row의 위치에 있는 필드심볼
    IF sy-subrc = 0.
      CASE pv_ucomm.
        WHEN 'CRSO'.    " 아이템
          PERFORM zz_get_selrows_so_precheck
          USING <gs_itab> CHANGING pv_error.

        WHEN 'CRDO'.    " 아이템
          PERFORM zz_get_selrows_do_precheck
          USING <gs_itab> CHANGING pv_error.

        WHEN 'CRGI'.    " 아이템
          PERFORM zz_get_selrows_gi_precheck
          USING <gs_itab> CHANGING pv_error.

        WHEN 'CRBI'.    " 아이템
          PERFORM zz_get_selrows_bi_precheck
          USING <gs_itab> CHANGING pv_error.   " 검증
      ENDCASE.
    ENDIF.
  ENDLOOP.

  CHECK pv_error IS INITIAL.

  " 확인창 서브 루틴
  PERFORM zz_set_confirm_step USING pv_ucomm CHANGING pv_error.

ENDFORM.







*&---------------------------------------------------------------------*
*& 여기서부터는 검증 관련 ******************
*&---------------------------------------------------------------------*




*&---------------------------------------------------------------------*
*& Form zz_get_selrows_so_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_so_precheck  USING   ps_itab LIKE LINE OF gt_itab
                              CHANGING pv_error.

*&--------------------------------*
*** 실행시 앞에 문서인 po 가 없다면.    " 기본 키인데 없을리가. 없긴함.
*&--------------------------------*
  IF ps_itab-ebeln IS INITIAL. " po 문서가 비어 있다면.
    pv_error = zle18_x.
    MESSAGE e000(oo) WITH 'Check Document status!'.
  ENDIF.  " 나가기.


*&--------------------------------*
*** 실행시 이미 so 가 만들어져 있다면.
*&--------------------------------*
  IF ps_itab-sovbeln IS NOT INITIAL.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady PO-SO link exist'.
  ENDIF.  " 나가기.

*&--------------------------------*
*** 실행시 po 헤더의 실행할 ITEM이 없으면
*&--------------------------------*
  READ TABLE gt_ekpo_t TRANSPORTING NO FIELDS " 현재 조회된 모든 아이템에서
        WITH TABLE KEY idx01 COMPONENTS ebeln = ps_itab-ebeln.
  " 현재 선택된 헤더의 키값으로 검색
  IF sy-subrc <> 0.
    pv_error = zle18_x.  " 없으면 나가기
    MESSAGE e000(oo) WITH 'There is no item data'.
    Exit.
  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form zz_get_selrows_do_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_do_precheck  USING   ps_itab LIKE LINE OF gt_itab
                              CHANGING pv_error.

*&--------------------------------*
*** 실행시 앞에 문서인 so 가 없다면.
*&--------------------------------*
  IF ps_itab-sovbeln IS INITIAL. " so 문서가 비어 있다면.
    pv_error = zle18_x.
    MESSAGE e000(oo) WITH 'Check Document status!'.
  ENDIF.  " 나가기.


*&--------------------------------*
*** 실행시 이미 do 가 만들어져 있다면.
*&--------------------------------*
  IF ps_itab-dovbeln IS NOT INITIAL.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady SO-DO link exist'.
  ENDIF.  " 나가기.

*&--------------------------------*
*** 실행시 so 헤더의 실행할 ITEM이 없으면
*&--------------------------------*
  READ TABLE gt_vbap_t TRANSPORTING NO FIELDS " 현재 조회된 모든 아이템에서
        WITH TABLE KEY idx01 COMPONENTS vbeln = ps_itab-sovbeln.
  " 현재 선택된 헤더의 키값으로 검색
  IF sy-subrc <> 0.
    pv_error = zle18_x.  " 없으면 나가기
    MESSAGE e000(oo) WITH 'There is no item data'.
    Exit.
  ENDIF.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_get_selrows_gi_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_gi_precheck  USING   ps_itab LIKE LINE OF gt_itab
                              CHANGING pv_error.

*&--------------------------------*
*** 실행시 앞에 문서인 do 가 없다면.
*&--------------------------------*
  IF ps_itab-dovbeln IS INITIAL. " do 문서가 비어 있다면.
    pv_error = zle18_x.
    MESSAGE e000(oo) WITH 'Check Document status!'.
  ENDIF.  " 나가기.


*&--------------------------------*
*** 실행시 이미 gi 가 만들어져 있다면.
*&--------------------------------*
  IF ps_itab-gistatu = 'S'.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady DO-GI link exist'.
  ENDIF.  " 나가기.

ENDFORM.






*&---------------------------------------------------------------------*
*& Form zz_get_selrows_bi_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_bi_precheck  USING   ps_itab LIKE LINE OF gt_itab
                              CHANGING pv_error.

*&--------------------------------*
*** 실행시 GI 가 안되어 있다면.
*&--------------------------------*
  IF ps_itab-gistatu <> 'S'. "GI 가 안되어 있다면.
    pv_error = zle18_x.
    MESSAGE e000(oo) WITH 'Check Document status!'.
  ENDIF.  " 나가기.


*&--------------------------------*
*** 실행시 이미 bi 가 만들어져 있다면.
*&--------------------------------*
  IF ps_itab-bivbeln IS NOT INITIAL.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady DO-BI link exist'.
  ENDIF.  " 나가기.

*&--------------------------------*
*** 실행시 do 헤더의 실행할 ITEM이 없으면
*&--------------------------------*
  READ TABLE gt_lips_t TRANSPORTING NO FIELDS " 현재 조회된 모든 아이템에서
        WITH TABLE KEY idx01 COMPONENTS vgbel = ps_itab-sovbeln.
  " 현재 선택된 헤더의 키값으로 검색
  IF sy-subrc <> 0.
    pv_error = zle18_x.  " 없으면 나가기
    MESSAGE e000(oo) WITH 'There is no item data'.
    Exit.
  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form zz_get_selrows_auto_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_auto_precheck  USING   ps_itab LIKE LINE OF gt_itab
                              CHANGING pv_error.

*&--------------------------------*
*** 실행시 이미 bi 가 만들어져 있다면.
*&--------------------------------*
  IF ps_itab-bivbeln IS NOT INITIAL.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'It is already done'.
  ENDIF.  " 나가기.

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
    WHEN 'CRSO'.
      lv_textline1 = TEXT-m01.
    WHEN 'CRDO'.
      lv_textline1 = TEXT-m02.
    WHEN 'CRGI'.
      lv_textline1 = TEXT-m03.
    WHEN 'CRBI'.
      lv_textline1 = TEXT-m04.
    WHEN 'AUTO'.
      lv_textline1 = TEXT-m05.
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
*& 여기서부터는 저장관련 ******************
*&---------------------------------------------------------------------*





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
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>)
      INDEX <ls_rows>-row_id.
    IF sy-subrc = 0.
      CASE pv_ucomm.
        WHEN 'CRSO'.
          PERFORM zz_set_sel_rows_so_ucomm USING pv_ucomm
                                     CHANGING <gs_itab>.
        WHEN 'CRDO'.
          PERFORM zz_set_sel_rows_do_ucomm USING pv_ucomm
                                     CHANGING <gs_itab>.
        WHEN 'CRGI'.
          PERFORM zz_set_sel_rows_gi_ucomm USING pv_ucomm
                                     CHANGING <gs_itab>.
        WHEN 'CRBI'.
          PERFORM zz_set_sel_rows_bi_ucomm USING pv_ucomm
                                     CHANGING <gs_itab>.
      ENDCASE.
    ENDIF.

  ENDLOOP.

* Screen Refresh / Reselect   " 새로 고침 하기!!
  perform 1000_onli.

  PERFORM zz_set_line_itab USING <ls_rows>-row_id.   " 그 alv 라인 새로 고침.

  0o_av_chg_set 'GO_AV2000_1' 'X'.


ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows_so_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      <-- <LS_vbak>
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows_so_ucomm  USING    pv_ucomm
                            CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_return TYPE bapiret2.
  DATA: lt_ekpo   TYPE zttekpo18.

  lt_ekpo = gt_ekpo_t.  " 현재 있는 모든 헤더의 모든 조회된 아이템값 넣어주기

  " 아이템 가져오기
  DELETE lt_ekpo WHERE ebeln <> ps_itab-ebeln.  " 선택된 라인과 상관 없는거 삭제

  READ TABLE gt_ekko ASSIGNING FIELD-SYMBOL(<gs_ekko>)  " 헤더 가져오기
  WITH TABLE KEY idx01 COMPONENTS ebeln = ps_itab-ebeln.

  CALL METHOD zcl18_lec_auto_plan=>zz_get_so_rtn  " BI 만들기
    EXPORTING
      is_po_h   = <gs_ekko>
      it_po_i   = lt_ekpo
    IMPORTING
      es_return = ls_return.

  CASE ls_return-type.
    WHEN 'S'.
      CLEAR gv_sochg. " 이것만 다시 가져올겨
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save S/O Document'.
  ENDCASE.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows_do_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      <-- <LS_vbak>
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows_do_ucomm  USING    pv_ucomm
                            CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_return TYPE bapiret2.
  DATA: lt_vbap   TYPE zttvbap18.

  lt_vbap = gt_vbap_t.  " 현재 있는 모든 헤더의 모든 조회된 아이템값 넣어주기

  " 아이템 가져오기
  DELETE lt_vbap WHERE vbeln <> ps_itab-sovbeln.  " 선택된 라인과 상관 없는거 삭제

  READ TABLE gt_vbak ASSIGNING FIELD-SYMBOL(<gs_vbak>)  " 헤더 가져오기
  WITH TABLE KEY idx01 COMPONENTS bstnk = ps_itab-ebeln.

  CALL METHOD zcl18_lec_auto_plan=>zz_get_do_rtn  " do 만들기
    EXPORTING
      is_so_h   = <gs_vbak>
      it_so_i   = lt_vbap
    IMPORTING
      es_return = ls_return.

  CASE ls_return-type.
    WHEN 'S'.
      CLEAR gv_dochg. " 이것만 다시 가져올겨
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save D/O Document'.
  ENDCASE.


ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows_gi_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      <-- <LS_vbak>
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows_gi_ucomm  USING    pv_ucomm
                            CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_return TYPE bapiret2.

  READ TABLE gt_likp ASSIGNING FIELD-SYMBOL(<gs_likp>)  " 헤더 가져오기
  WITH TABLE KEY idx01 COMPONENTS vbeln = ps_itab-dovbeln.

  CALL METHOD zcl18_lec_auto_plan=>zz_get_gi_rtn  " BI 만들기
    IMPORTING
      es_return = ls_return
    CHANGING
      cs_do_h   = <gs_likp>.

  CASE ls_return-type.
    WHEN 'S'.
      CLEAR gv_dochg. " 이것만 다시 가져올겨
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save Good Issue'.
  ENDCASE.


ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_set_sel_rows_bi_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      <-- <LS_vbak>
*&---------------------------------------------------------------------*
FORM zz_set_sel_rows_bi_ucomm  USING    pv_ucomm
                            CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_return TYPE bapiret2.
  DATA: lt_lips   TYPE zttlips18.

  lt_lips = gt_lips_t.  " 현재 있는 모든 헤더의 모든 조회된 아이템값 넣어주기

  " 아이템 가져오기
  DELETE lt_lips WHERE vbeln <> ps_itab-dovbeln.  " 선택된 라인과 상관 없는거 삭제

  READ TABLE gt_likp ASSIGNING FIELD-SYMBOL(<gs_likp>)  " 헤더 가져오기
  WITH TABLE KEY idx01 COMPONENTS vbeln = ps_itab-dovbeln.

  CALL METHOD zcl18_lec_auto_plan=>zz_get_bi_rtn  " BI 만들기
    EXPORTING
      is_do_h   = <gs_likp>
      it_do_i   = lt_lips
    IMPORTING
      es_return = ls_return.

  CASE ls_return-type.
    WHEN 'S'.
      CLEAR gv_bichg.   " 이것만 다시 가져올겨.
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save Billing Document'.
  ENDCASE.


ENDFORM.

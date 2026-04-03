*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZR18A00070
* Desc       : SY Unit Common Condition Master
* Transaction: ZR18A00070
* Creator    : REM0018
* Create day  : 2026.01.17
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.17    홍길동              최초작성
*&---------------------------------------------------------------------*

REPORT zr18a00070.

*----------------------------------------------------------------------*
* Include.
*----------------------------------------------------------------------*
INCLUDE : yg1000,                                " 개발 공용 Include
            yg1000_cn,                           " CoNtainer Include
              yg1000_av.                         " AlV Include

*----------------------------------------------------------------------*
* 전역 변수(Tables, Data) 선언.
*----------------------------------------------------------------------*
* 2000 ALV
DATA : go_cc2000_1 TYPE REF TO cl_gui_custom_container,
       go_av2000_1 TYPE REF TO cl_gui_alv_grid.


TABLES: zt18acom10.
DATA: gv_pcode TYPE zt18acom10-pcode VALUE 'SD_CREATE_AUTO'.
DATA: gt_itab  TYPE TABLE OF zs18a00070.
DATA: gt_itab_t TYPE TABLE OF zs18a00070
      WITH NON-UNIQUE SORTED KEY idx01 COMPONENTS uname.

DATA: gv_crt_idx TYPE I.

*----------------------------------------------------------------------*
* Selection screen
*----------------------------------------------------------------------*
SELECT-OPTIONS: so_pcode FOR zt18acom10-pcode
  DEFAULT gv_pcode OBLIGATORY NO-EXTENSION NO INTERVALS.

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

  REFRESH: gt_itab, gt_itab_t.

  DATA: lt_itab TYPE TABLE OF zt18acom10.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_itab
    FROM zt18acom10
    WHERE pcode IN so_pcode.


  IF lt_itab IS NOT INITIAL.
    LOOP AT lt_itab ASSIGNING FIELD-SYMBOL(<ls_itab>).
      APPEND INITIAL LINE TO gt_itab
           ASSIGNING FIELD-SYMBOL(<gs_itab>).
      MOVE-CORRESPONDING <ls_itab> to <gs_itab>.

      <gs_itab>-value2 = <ls_itab>-valu2.
      <gs_itab>-value3 = <ls_itab>-valu3.
      <gs_itab>-value4 = <ls_itab>-valu4.

    ENDLOOP.
  ENDIF.

  IF gt_itab IS NOT INITIAL.
    gt_itab_t = gt_itab.  " 나중에 중복 검사 및 내용 변경점 확인용.
  ENDIF.



  SORT gt_itab BY pcode uname.

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

  CHECK sy-batch IS INITIAL.

  DESCRIBE TABLE gt_itab LINES lv_cnt.

  MESSAGE s000(oo) WITH lv_cnt '건 조회되었습니다'.
  CALL SCREEN 2000.



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
    USING 'GO_AV2000_1' go_cc2000_1 'ZS18A00070' 'X'.

  0o_av_refresh 'GO_AV2000_1' '' 'X' 'X'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM 2000_save .

  DATA: lv_error.

  PERFORM zz_get_sel_rows CHANGING lv_error.

  CHECK lv_error is INITIAL.

  PERFORM zz_save_rows CHANGING lv_error.

  CHECK lv_error is INITIAL.

  MESSAGE s000(oo) WITH 'Data saved'.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_get_sel_rows
*&---------------------------------------------------------------------*
*& text 저장할 데이터 있나 검증
*&---------------------------------------------------------------------*
FORM zz_get_sel_rows  CHANGING pv_error.

  IF gt_itab is INITIAL.  " 저장할 데이터 있나 검증
    MESSAGE e000(oo) WITH 'There are no data to save'.
  ENDIF.

  IF gv_crt_idx IS NOT INITIAL.  " 유저 이름 있나 확인


    LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>) FROM gv_crt_idx.
*      IF <gs_itab>-uname IS INITIAL.  " 비었나 확인 " 이거 걍 날리라고 하심.
*        MESSAGE e000(oo) WITH 'Please insert User ID'.
*      ENDIF.

      READ TABLE gt_itab_t TRANSPORTING NO FIELDS
      WITH TABLE KEY idx01 COMPONENTS uname = <gs_itab>-uname.

      IF sy-subrc = 0.
        MESSAGE e000(oo) WITH 'There are duplication User ID'.
      ENDIF.

    ENDLOOP.


    CLEAR gv_crt_idx.
  ENDIF.

  PERFORM zz_set_confirm_step CHANGING pv_error.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_set_confirm_step
*&---------------------------------------------------------------------*
*& text 데이터 저장 확인 메세지
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_set_confirm_step CHANGING pv_error.

  DATA: lv_textline1 TYPE spop-textline1.
*        lv_textline2 TYPE spop-textline2.

  DATA: lv_answer.

*  CASE pv_ucomm.
*    WHEN 'CRBI'.
  lv_textline1 = TEXT-m01.
*  ENDCASE.

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
*& Form zz_save_rows
*&---------------------------------------------------------------------*
*& text   데이터 저장
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_save_rows CHANGING pv_error.

  DATA: lt_itab TYPE TABLE OF zt18acom10. " db 가기전 형변환
  DATA: lv_idx TYPE i.

  LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>).
    lv_idx = sy-tabix.


    IF <gs_itab>-uname IS NOT INITIAL. " 이름 비어 있는건 저장 X

      READ TABLE gt_itab_t WITH TABLE KEY idx01   " 기존 데이터 가져오기.
      COMPONENTS uname = <gs_itab>-uname
      ASSIGNING FIELD-SYMBOL(<gs_itab_t>).

      IF sy-subrc = 0 AND <gs_itab>-statu <> 'C'. " 가져오는 거 성공 또한 생성된것도 아님.

        IF <gs_itab_t>-value2 <> <gs_itab>-value2 OR " 기존과 달라진거 있나 확인.
          <gs_itab_t>-value3 <> <gs_itab>-value3 OR
          <gs_itab_t>-value4 <> <gs_itab>-value4.


          " 달라진 데이터가 있다면. 업데이트 할 데이터 만들기.
          APPEND INITIAL LINE TO lt_itab
          ASSIGNING FIELD-SYMBOL(<ls_itab>).

          MOVE-CORRESPONDING <gs_itab> to <ls_itab>.


          <ls_itab>-aedat = sy-datum.    " 수정 정보 넣기 날짜 및 변경자
          <ls_itab>-aezet = sy-uzeit.
          <ls_itab>-aenam = sy-uname.

          " alv 보이기용
          <gs_itab>-aedat = <ls_itab>-aedat.    " 수정 정보 넣기 날짜 및 변경자
          <gs_itab>-aezet = <ls_itab>-aezet.
          <gs_itab>-aenam = <ls_itab>-aenam.

          <ls_itab>-valu2 = <gs_itab>-value2.
          <ls_itab>-valu3 = <gs_itab>-value3.  " 매핑 시키기
          <ls_itab>-valu4 = <gs_itab>-value4.

        ENDIF.

      ELSE. " 가져오는 거 불성공. 새로 만들어진거라는 것.
        APPEND INITIAL LINE TO lt_itab
        ASSIGNING FIELD-SYMBOL(<ls_itab2>).

        MOVE-CORRESPONDING <gs_itab> to <ls_itab2>.

        <ls_itab2>-valu2 = <gs_itab>-value2.
        <ls_itab2>-valu3 = <gs_itab>-value3.  " 매핑 시키기
        <ls_itab2>-valu4 = <gs_itab>-value4.


        <gs_itab>-statu = ''.  " 'C' 지워주기.
        PERFORM zz_set_rows_styl CHANGING <gs_itab>. " UNAME EDIT 불가능하게

      ENDIF.


    ELSE.  " 이름이 비어 있다면. 그 행 삭제.
      DELETE gt_itab INDEX lv_idx.

    ENDIF.

    CLEAR lv_idx.
  ENDLOOP.

  IF lt_itab IS NOT INITIAL.  " 비엇나 확인후
    MODIFY zt18acom10 FROM TABLE lt_itab. " 저장하기
  ENDIF.

  if sy-subrc = 0.

    SORT gt_itab BY pcode uname.  " 정렬.

    REFRESH gt_itab_t.  " 기존데이터 초기화후 넣어주기.
    gt_itab_t = gt_itab.

    0o_av_chg_set 'GO_AV2000_1' 'X'. "refresh

  ELSE.
    pv_error = zle18_x.
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

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_3.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = 'INST'.
  ls_tool-icon      = ICON_INSERT_ROW.
*  ls_tool-text      = 'Create S/O'.
  APPEND ls_tool TO po_object->mt_toolbar.

*  CLEAR ls_tool.
*  ls_tool-butn_type = zle18_0.
*  ls_tool-function  = 'DELE'.
*  ls_tool-icon      = ICON_DELETE_ROW.
**  ls_tool-text      = 'Create S/O'.
*  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_3.
  APPEND ls_tool TO po_object->mt_toolbar.

  CLEAR ls_tool.
  ls_tool-butn_type = zle18_0.
  ls_tool-function  = 'REFE'.
  ls_tool-icon      = ICON_REFRESH.
*  ls_tool-text      = 'Create S/O'.
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
FORM av2000_1_set_before USING pv_av_name.

* GS_ZS_AV_LAYOUT
  gs_zs_av_layout-zebra = 'X'.
  gs_zs_av_layout-sel_mode = 'A'.

* GT_ZT_AV_FCAT
  0o_av_fcat_field : 'S' 'STATU' '',  " STATUS
                     ' ' 'COLTEXT' 'Status',
                     ' ' 'KEY' 'X',
                     'E' 'FIX_COLUMN' 'X'.

  0o_av_fcat_field : 'S' 'PCODE' '',  " Char20
                     ' ' 'COLTEXT' 'Condition Code',
                     ' ' 'KEY' 'X',
                     ' ' 'FIX_COLUMN' 'X',
                     'E' 'OUTPUTLEN' '000020'.

  0o_av_fcat_field : 'S' 'UNAME' '',  " User Name
                     ' ' 'COLTEXT' 'User ID',
                     ' ' 'KEY' 'X',
                     ' ' 'FIX_COLUMN' 'X',
                     'E' 'OUTPUTLEN' '000015'.

  0o_av_fcat_field : 'S' 'VALUE1' '',  " Synch. key
                     'E' 'NO_OUT' 'X'.

  0o_av_fcat_field : 'S' 'VALUE3' '',  " Synch. key
                     ' ' 'COLTEXT' 'Document Auto',
                     ' ' 'CHECKBOX' 'X',
                     ' ' 'EMPHASIZE' 'C300',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'EDIT' 'X'.

  0o_av_fcat_field : 'S' 'VALUE4' '',  " Synch. key
                     ' ' 'COLTEXT' 'Financial Auto',
                     ' ' 'CHECKBOX' 'X',
                     ' ' 'EMPHASIZE' 'C300',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'EDIT' 'X'.

  0o_av_fcat_field : 'S' 'VALUE2' '',  " Synch. key
                     ' ' 'COLTEXT' 'Delete Flag',
                     ' ' 'CHECKBOX' 'X',
                     ' ' 'EMPHASIZE' 'C700',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'EDIT' 'X'.

  0o_av_fcat_field : 'S' 'PDESC' '',  "
                     ' ' 'COLTEXT' 'PCODE Desc',
                     'E' 'NO_OUT' 'X'.

  0o_av_fcat_field : 'S' 'KDESC' '',  " Char 70
                     'E' 'NO_OUT' 'X'.

  0o_av_fcat_field : 'S' 'TDESC' '',  "
                     'E' 'NO_OUT' 'X'.

  0o_av_fcat_field : 'S' 'LOEKZ' '',  " Synch. key
                     ' ' 'COLTEXT' 'Delete Flag',
                     ' ' 'CHECKBOX' 'X',
                     ' ' 'EMPHASIZE' 'C700',
                     ' ' 'OUTPUTLEN' '000015',
                     'E' 'EDIT' 'X'.

  0o_av_fcat_field : 'S' 'ERDAT' ' ',  " Created on
                     'E' 'COLTEXT' 'Created On'.

  0o_av_fcat_field : 'S' 'ERZET' ' ',  " Time
                     'E' 'COLTEXT' 'Time'.

  0o_av_fcat_field : 'S' 'ERNAM' ' ',  " Created By
                     'E' 'COLTEXT' 'Created By'.

  0o_av_fcat_field : 'S' 'AEDAT' ' ',  " Changed On
                     'E' 'COLTEXT' 'Changed On'.

  0o_av_fcat_field : 'S' 'AEZET' ' ',  " Time of change
                     'E' 'COLTEXT' 'Changed Time'.

  0o_av_fcat_field : 'S' 'AENAM' ' ',  " Changed By
                     'E' 'COLTEXT' 'Changed By'.

ENDFORM.
*----------------------------------------------------------------------*
* Form AV2000_1_DATA_CHANGED
*----------------------------------------------------------------------*
* ※ 이 서브루틴은 동적으로 호출합니다. 삭제 전 사용처를 확인하세요.
* ※ 이 서브루틴의 파라미터는 사용하는 곳이 없더라도 삭제 하지 마세요.
*----------------------------------------------------------------------*
*            ★필수작성★ Form문 기능/내용(NXX 표기하여 작성)
*----------------------------------------------------------------------*
* N01 : GO_AV2000_1 DATA_CHANGED 이벤트 처리.
*----------------------------------------------------------------------*
FORM av2000_1_data_changed
  USING pv_av_name
        po_change TYPE REF TO cl_alv_changed_data_protocol
        pv_onf4
        pv_onf4_before
        pv_onf4_after
        pv_ucomm.

  DATA(lt_cell) = po_change->mt_good_cells.

  LOOP AT lt_cell ASSIGNING FIELD-SYMBOL(<ls_cell>).
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<ls_itab>) INDEX
<ls_cell>-row_id.
    IF sy-subrc EQ 0.
      CASE <ls_cell>-fieldname.
        WHEN 'VALUE3'.

        WHEN 'VALUE4'.

      ENDCASE.
      0o_av_mg_show po_change <ls_cell> gs_zs_return.
      MODIFY gt_itab FROM <ls_itab> INDEX <ls_cell>-row_id.
    ENDIF.
  ENDLOOP.

ENDFORM.
*----------------------------------------------------------------------*
* Form AV2000_1_CHANGED_FINISHED
*----------------------------------------------------------------------*
* ※ 이 서브루틴은 동적으로 호출합니다. 삭제 전 사용처를 확인하세요.
* ※ 이 서브루틴의 파라미터는 사용하는 곳이 없더라도 삭제 하지 마세요.
*----------------------------------------------------------------------*
*            ★필수작성★ Form문 기능/내용(NXX 표기하여 작성)
*----------------------------------------------------------------------*
* N01 : GO_AV2000_1 DATA_CHANGED_FINISHED 이벤트 처리.
*----------------------------------------------------------------------*
FORM av2000_1_changed_finished
  TABLES pt_modi STRUCTURE lvc_s_modi
   USING pv_av_name pv_modified.

  CHECK pv_modified EQ abap_true.
  LOOP AT pt_modi.
    READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<ls_itab>) INDEX
pt_modi-row_id.
    IF sy-subrc EQ 0.
      CASE pt_modi-fieldname.
        WHEN 'VALUE3'.

        WHEN 'VALUE4'.

      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form zz_set_rows_styl
*&---------------------------------------------------------------------*
*& text   데이터 저장
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
Form zz_set_rows_styl CHANGING ps_itab LIKE LINE OF gt_itab.

  CASE  ps_itab-statu.
    WHEN 'C'.
      0o_av_styl_set ps_itab-styl 'UNAME' gc_zc_av_gubun_e.
    when OTHERS.
      0o_av_styl_set ps_itab-styl 'UNAME' gc_zc_av_gubun_f.
  ENDCASE.

ENDFORM.


*------------- 여긴 alv 버튼이얌!!


*&---------------------------------------------------------------------*
*& Form av2000_1_uc_INST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM av2000_1_uc_INST USING pv_av_name.

  "MESSAGE s000(oo) WITH '클릭됨'. " ㅎㅎㅎ

  APPEND INITIAL LINE TO gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>).
  <gs_itab>-pcode = 'SD_CREATE_AUTO'.   " 기본 정보
  <gs_itab>-statu = zle18_c.   " 생성 하는 표시

  " 날짜 및 생성자 설정
  <gs_itab>-erdat = sy-datum.
  <gs_itab>-erzet = sy-uzeit.
  <gs_itab>-ernam = sy-uname.

  IF gv_crt_idx IS INITIAL.  " 처음 추가한 값의 인덱스 넣어주기
    gv_crt_idx = SY-TABIX.
  ENDIF.

  " 상호작용 가능하게 바꾸기
  PERFORM zz_set_rows_styl CHANGING <gs_itab>.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form av2000_1_uc_DELE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM av2000_1_uc_DELE USING pv_av_name.
*
*  DATA: lt_rows TYPE TABLE OF lvc_s_roid. " 선택된 라인 넣을 테이블
*  DATA: lv_error. " 애러 확인 변수
*
*  CALL METHOD go_av2000_1->get_selected_rows
*    IMPORTING
*      et_row_no = lt_rows[].  " 선택한 행 가져오기
*
*  IF lt_rows[] IS INITIAL. " 선택된 행이 없다면.
*    MESSAGE e000(oo) WITH 'Select only 1 row'.
*  ENDIF.
*
*
*  LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).  " 선택된 row
*      READ TABLE gt_itab ASSIGNING FIELD-SYMBOL(<gs_itap>)
*        INDEX <ls_rows>-row_id. " 그 row의 위치에 있는 헤더 값을 읽음.
*
*      IF sy-subrc = 0.
*
*        <gs_itap>-value2 = 'X'
*
*      ENDIF.
*  ENDLOOP.
*
*  0o_av_refresh 'GO_AV2000_1' '' 'X' 'X'.
*
*
*ENDFORM.

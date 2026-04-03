*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZR18A00040
* Desc       : Create Billing by DO
* Transaction: ZR18A00040
* Creator    : REM0018
* Create day  : 2026.01.12
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.12    박규태              최초작성
*&---------------------------------------------------------------------*

REPORT ZR18A00040.

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


TABLES: LIKP, LIPS.
DATA: gt_likp18   TYPE TABLE OF zlikp18.  " 위에 alv 에 뜨는 do 헤더
DATA: gt_lips_t TYPE TABLE OF zlips18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln. " do 헤더에 따른 아이템 정보 저장용
DATA: gt_lips18   TYPE TABLE OF zlips18.  " 아래 alv 에 뜨는 do 아이템

* do_bi Link
DATA: gt_dobi TYPE TABLE OF zvbrp18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel. " do_bi 연결 확인용. 즉 이미 생성 된건 지 확인(중복 방지)



*----------------------------------------------------------------------*
* Selection 스크린
*----------------------------------------------------------------------*
SELECT-OPTIONS:
 so_vbeln FOR likp-vbeln,
 so_erdat FOR likp-erdat OBLIGATORY.


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
* text (2000_status)
*----------------------------------------------------------------------*
MODULE 2000_status OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR '2000'.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  AV2000_X_MAKE  OUTPUT
*&---------------------------------------------------------------------*
MODULE av2000_x_make OUTPUT.


  0o_dc_make : 'GO_DC2000_1' 1 2500.    " 도킹 컨테이너

  0o_sc_make : 'GO_SC2000_1' go_dc2000_1 2 1.   " Split 컨테이너  2행 1열 생성

  0o_ic_make : 'GO_IC2000_1' go_sc2000_1 1 1,   " 컨테이너 1행 1열
               'GO_IC2000_2' go_sc2000_1 2 1.   " 2행 1열

  PERFORM 0o_av_make
   TABLES gt_likp18
    USING 'GO_AV2000_1' go_ic2000_1
          'ZLIKP18'   " 아밥 딕셔너리에 선언된 테이블, 구조, 뷰를
*                    이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_1' 'X' 'X' 'X'.

  PERFORM 0o_av_make
   TABLES gt_lips18
    USING 'GO_AV2000_2' go_ic2000_2
          'ZLIPS18' " 프로그램 내의 내부테이블을
*                      이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_2' 'X' 'X' 'X'.


ENDMODULE.                 " AV2000_X_MAKE  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  av2000_1_set_before
*&---------------------------------------------------------------------*
*FORM av2000_1_set_before USING pv_av_name.                  "#EC *
*
*
*
*ENDFORM.                    "av2000_1_set_before

*&---------------------------------------------------------------------*
*&      Form  av2000_2_set_before
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM av2000_2_set_before USING pv_av_name.                  "#EC *
*
*  gs_zs_av_layout-no_toolbar = 'X'.
*
*ENDFORM.                    "av2000_2_set_before


*&---------------------------------------------------------------------*
*&      Form  av2000_1_cell_click
*&---------------------------------------------------------------------*
FORM av2000_1_cell_click                                    "#EC *
  USING pv_av_name
        pc_gubun
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.  " 선택한 행 정보

  REFRESH gt_lips18.

  READ TABLE gt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp>) INDEX
ps_row_no-row_id. " 그 행의 몇번째 줄인지. 그 행 줄을 <ls_likp>로 함.
  CHECK sy-subrc = 0.   " 성공 못하면 빠져나감.

  CASE ps_col-fieldname.  " 클릭한 열 이름인가봄.
    WHEN 'VBELN'.
      READ TABLE gt_lips_t TRANSPORTING NO FIELDS  " do 아이템에서 선택한 행에 속한 아이템이 있는 지 확인
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_likp>-vbeln.  " vbeln 을 통해 확인.
      IF sy-subrc = 0.
        LOOP AT gt_lips_t ASSIGNING FIELD-SYMBOL(<ls_lips_t>)
            FROM sy-tabix USING KEY idx01.  " 확인된 행부터 시작
          IF <ls_lips_t>-vbeln <> <ls_likp>-vbeln.
            EXIT. " 헤더의 키 값과 달라지면 나가기
          ENDIF.
          APPEND INITIAL LINE TO gt_lips18  " 위에서 말했듯이.
          ASSIGNING FIELD-SYMBOL(<ls_lips>).  " 아래 alv 에서 보여주기 위한 아이템 테이블
          MOVE-CORRESPONDING <ls_lips_t> TO <ls_lips>.  " 보여줄 데이터
        ENDLOOP.          " 즉 선택한 헤더와 관련된 아이템을 gt_lips 에 담아준다.
      ENDIF.

      SORT gt_lips18 BY vbeln posnr.  " 정렬

      0o_av_chg_set 'GO_AV2000_2' 'X'.  " 아래 아이템 용 alv 새로고침 일듯.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  av2000_2_cell_click
*&---------------------------------------------------------------------*
*FORM av2000_2_cell_click                                    "#EC *
*  USING pv_av_name
*        pc_gubun
*        ps_row    LIKE lvc_s_row
*        ps_col    LIKE lvc_s_col
*        ps_row_no LIKE lvc_s_roid.
*
**  READ TABLE gt_eban INDEX ps_row_no-row_id.
**  CHECK sy-subrc = 0.
**
**  CASE ps_col-fieldname.
**    WHEN 'BANFN'.
**      0t_TR 'ME53N' 'X' gt_eban-banfn gt_eban-bnfpo '' '' '' '' ''.
**  ENDCASE.
*
*ENDFORM.

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

  DATA: lt_lipsv TYPE TABLE OF zlikp18. " do 의 아이템을 구하기 위한 키값
*  DATA: lt_lips  TYPE TABLE OF lips WITH NON-UNIQUE SORTED KEY idx01
*        COMPONENTS vbeln. " do의 아이템 테이블  (이거 없어도 될듯)

  DATA: lt_vbrp18v TYPE TABLE OF zvbrp18. " 이미 만들어진 bi 키값.

  DATA: lt_idx TYPE i.  " 인덱스 저장용.



  REFRESH: gt_likp18, gt_lips18, gt_dobi.
*&--------------------------------*
  " 현제 bi 의 헤더 정보 가져오기 (이건 위에 alv 에서 보여줄것임)
*&--------------------------------*
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp18
    FROM zlikp18
    WHERE vbeln IN so_vbeln AND
          erdat IN so_erdat.

  lt_lipsv = gt_likp18.     " 값 넣어주고
  sort lt_lipsv by vbeln.   " 키값에 맞춰서 sort
  delete ADJACENT DUPLICATES FROM lt_lipsv COMPARING vbeln. " 키값 중복 삭제

*&--------------------------------*
" do 헤더에 속한 아이템 미리 가져와 넣어놓기 (매번 db 연결해서 select 하면 안 좋기에)
*&--------------------------------*
  IF lt_lipsv IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_lips_t
      FROM zlips18
      FOR ALL ENTRIES IN lt_lipsv   " lt_lipsv 에 있는 값들을 돌면서
      WHERE vbeln = lt_lipsv-vbeln. " vbeln 키값과 일치하는 값 확인

*&--------------------------------*
" do 아이템의 키 값이 있는 bi 아이템 테이블 만들기
*&--------------------------------*
    LOOP AT lt_lipsv ASSIGNING FIELD-SYMBOL(<ls_lipsv>).
      CHECK <ls_lipsv>-vbeln IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_vbrp18v ASSIGNING
      FIELD-SYMBOL(<ls_vbrp18v>).
      <ls_vbrp18v>-vgbel = <ls_lipsv>-vbeln.
    ENDLOOP.
    " 현재 lt_vbrp18v 에 모든 레코드는 vgbel 값밖에 없음.

*&--------------------------------*
" 이미 do를 통해 만들어진 bi 아이템을 gt_dobi에 넣기(나중에 중복 확인용)
*&--------------------------------*
    SORT lt_vbrp18v BY vgbel. " 정렬 및 중복 제거
    DELETE ADJACENT DUPLICATES FROM lt_vbrp18v COMPARING vgbel.
    IF lt_vbrp18v IS NOT INITIAL.
      SELECT vgbel vbeln
        INTO CORRESPONDING FIELDS OF TABLE gt_dobi
        FROM zvbrp18
        FOR ALL ENTRIES IN lt_vbrp18v
        WHERE vgbel = lt_vbrp18v-vgbel.
    ENDIF.

*&--------------------------------*
*** ITEM이 없는 DO건은 제외
*&--------------------------------*
    IF gt_lips_t IS INITIAL.
      REFRESH gt_likp18.    " 아이템이 아예 없으면, 헤더도 아예 없어야함.
    ELSE.
      LOOP AT gt_likp18 ASSIGNING FIELD-SYMBOL(<gt_likp>).
        lt_idx = sy-tabix.  " 현재 gt_likp의 레코드 인덱스 넣기.
        READ TABLE gt_lips_t TRANSPORTING NO FIELDS " 아이템에 헤더의 vbeln과 일치하는 항목이 있는지 확인
          WITH TABLE KEY idx01 COMPONENTS vbeln = <gt_likp>-vbeln.
        IF sy-subrc <> 0. " 검색이 안됬다면.
          DELETE gt_likp18 INDEX lt_idx. " 그 줄 삭제.
        ENDIF.
        CLEAR lt_idx.   " lt_idx 클리어 해주기
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

  DATA: lv_cnt TYPE i.  " 항목 개수 담는 변수

  CHECK sy-batch = zle18_. " 백그라운드 작업 일때는 빠져나감.

  DESCRIBE TABLE gt_likp18 LINES lv_cnt.  " 조회된 do 헤더 테이블의 레코드 개수 세기
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
      SORT gt_likp18 by vbeln.
      SORT gt_lips_t by vbeln posnr.
    ENDIF.

    CALL SCREEN 2000.
  ENDIF.

ENDFORM.


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
  ls_tool-function  = zle18_CRBI.  " bi 만들기
  ls_tool-icon      = icon_led_inactive.
  ls_tool-text      = TEXT-t01.
  APPEND ls_tool TO po_object->mt_toolbar.

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
*& Form av2000_1_uc_CRBI
*&---------------------------------------------------------------------*
*& text
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
*& Form av2000_1_uc_refe
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM av2000_1_uc_refe USING pv_av_name.
*
*
*
*
*
*ENDFORM.

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
    DESCRIBE TABLE pt_rows LINES DATA(lv_cnt).  " 몇개의 라인을 골랐는지.
    IF lv_cnt > 1.  " 1개 이상이면 애러 메세지.
      MESSAGE e000(oo) WITH 'Select only 1 row'.
    ENDIF.  " e000(oo) 라서 별도의 추가 코딩을 안해도 나가짐.
  ENDIF.


  LOOP AT pt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).  " 선택된 row
      READ TABLE gt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp>)
        INDEX <ls_rows>-row_id. " 그 row의 위치에 있는 헤더 값을 읽음.
      IF sy-subrc = 0.
        CASE pv_ucomm.
          WHEN 'CRBI'.    " 아이템
            PERFORM zz_get_selrows_precheck USING <ls_likp> CHANGING pv_error.   " 이미 bi 가 생성 됐는지 확인하는 서브 루틴.
        ENDCASE.
      ENDIF.

*&--------------------------------*
*** 8-2. 실행시 그 헤더의 실행할 ITEM이 없으면
*&--------------------------------*
      READ TABLE gt_lips_t TRANSPORTING NO FIELDS " 현재 조회된 모든 아이템에서
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_likp>-vbeln.
        " 현재 선택된 헤더의 키값으로 검색
      IF sy-subrc <> 0.
        pv_error = zle18_x.  " 없으면 나가기
        MESSAGE i000(oo) WITH 'There is no item data'.
        Exit.
      ENDIF.
  ENDLOOP.

  CHECK pv_error IS INITIAL.

  CASE pv_ucomm.
    WHEN 'CRBI'.  " 확인창 서브 루틴
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
    WHEN 'CRBI'.
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
*& Form zz_get_selrows_precheck
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_vbak>
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM zz_get_selrows_precheck  USING    ps_likp LIKE LINE OF gt_likp18
                              CHANGING pv_error.

  DATA: lv_vgbel TYPE vbrp-vgbel.

  lv_vgbel = ps_likp-vbeln.

  READ TABLE gt_dobi TRANSPORTING NO FIELDS   " 아까 만들어둔 이미 do_bi 링크가 생성된 변수 읽기.
    WITH TABLE KEY idx01 COMPONENTS vgbel = lv_vgbel.
  IF sy-subrc = 0.  " 값이 읽혀 진다면 이미 존재한다는 것.
    pv_error = zle18_x.
    MESSAGE i000(oo) WITH 'There is aleady DO-BI link exist'.
  ENDIF.  " 나가기.

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
    READ TABLE gt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp>)
      INDEX <ls_rows>-row_id.
    IF sy-subrc = 0.
      CASE pv_ucomm.
        WHEN 'CRBI'.
          PERFORM zz_set_sel_rows_ucomm USING pv_ucomm
                                     CHANGING <ls_likp>.

* Screen Refresh / Reselect   " 새로 고침 하기!!
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
                            CHANGING ps_likp LIKE LINE OF gt_likp18.

  DATA: ls_return TYPE bapiret2.
  DATA: lt_lips   TYPE zttlips18.

  lt_lips = gt_lips_t.  " 현재 있는 모든 헤더의 모든 조회된 아이템값 넣어주기

  DELETE lt_lips WHERE vbeln <> ps_likp-vbeln.  " 선택된 헤더와 다른 아이템 삭제

  CALL METHOD zcl18_lec_auto_plan=>zz_get_bi_rtn  " BI 만들기
    EXPORTING
      is_do_h   = ps_likp
      it_do_i   = lt_lips
    IMPORTING
      es_return = ls_return.

  CASE ls_return-type.
    WHEN 'S'.
      MESSAGE s000(oo) WITH 'Sucessful Saved with' ls_return-field.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Fail to Save Billing Document'.
  ENDCASE.


ENDFORM.

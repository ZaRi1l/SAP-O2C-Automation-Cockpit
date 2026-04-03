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

REPORT ZPPT18.

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
       go_av2000_3 TYPE REF TO cl_gui_alv_grid,             "#EC NEEDED
       go_ic2000_4 TYPE REF TO cl_gui_container,            "#EC NEEDED
       go_av2000_4 TYPE REF TO cl_gui_alv_grid,             "#EC NEEDED
       go_tx2000_1 TYPE REF TO cl_gui_textedit.             "#EC NEEDED


TABLES: VBAK.

TYPES: BEGIN OF ty_vbak18.
         INCLUDE TYPE zvbak18.
         TYPES: scol TYPE lvc_t_scol, " <--- 이 필드 필수
       END OF ty_vbak18.
DATA: gt_vbak18 TYPE TABLE OF ty_vbak18.
"DATA: gt_vbak18   TYPE TABLE OF zvbak18.  " SO 헤더
DATA: gt_vbak18_t type TABLE OF ty_vbak18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.


TYPES: BEGIN OF ty_vbap18.
         INCLUDE TYPE zvbap18.
         TYPES: scol TYPE lvc_t_scol, " <--- 이 필드 필수
       END OF ty_vbap18.
DATA: gt_vbap18 TYPE TABLE OF ty_vbap18.
"DATA: gt_vbap18   TYPE TABLE OF zvbap18.  " SO 아이템
DATA: gt_vbap18_t type TABLE OF zvbap18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vbeln.

TYPES: BEGIN OF ty_lips18.
         INCLUDE TYPE zlips18.
         TYPES: scol TYPE lvc_t_scol, " <--- 이 필드 필수
       END OF ty_lips18.
DATA: gt_lips18 TYPE TABLE OF ty_lips18.
"DATA: gt_lips18   TYPE TABLE OF zlips18.  " do 아이템
DATA: gt_lips18_t type TABLE OF zlips18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel. "미리 저장용

TYPES: BEGIN OF ty_vbrp18.
         INCLUDE TYPE zvbrp18.
         TYPES: scol TYPE lvc_t_scol, " <--- 이 필드 필수
       END OF ty_vbrp18.
DATA: gt_vbrp18   TYPE TABLE OF ty_vbrp18.  " BI 아이템
DATA: gt_vbrp18_t type TABLE OF zvbrp18 WITH NON-UNIQUE SORTED KEY idx01
        COMPONENTS vgbel. "미리 저장용

*----------------------------------------------------------------------*
* Selection 스크린
*----------------------------------------------------------------------*
SELECT-OPTIONS:
 so_vbeln FOR vbak-vbeln,
 so_erdat FOR vbak-erdat.


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

  0o_sc_make : 'GO_SC2000_1' go_dc2000_1 4 1.   " Split 컨테이너  3행 1열 생성

  0o_ic_make : 'GO_IC2000_1' go_sc2000_1 1 1,   " 컨테이너 1행 1열
               'GO_IC2000_2' go_sc2000_1 2 1,   " 2행 1열
               'GO_IC2000_3' go_sc2000_1 3 1,   " 3행 1열
               'GO_IC2000_4' go_sc2000_1 4 1.   " 4행 1열


  PERFORM 0o_av_make
   TABLES gt_vbak18
    USING 'GO_AV2000_1' go_ic2000_1
          'ZVBAK18'   " 아밥 딕셔너리에 선언된 테이블, 구조, 뷰를
*                    이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_1' 'X' 'X' 'X'.

  DATA: ls_layout_vbak TYPE lvc_s_layo.

  IF go_av2000_1 IS BOUND.
    go_av2000_1->get_frontend_layout( IMPORTING es_layout = ls_layout_vbak ).

    ls_layout_vbak-ctab_fname = 'SCOL'.
    ls_layout_vbak-grid_title = 'SO HEADER : VBAK'. " <--- 제목 추가

    go_av2000_1->set_frontend_layout( is_layout = ls_layout_vbak ).
    go_av2000_1->refresh_table_display( ).
  ENDIF.


  PERFORM 0o_av_make
   TABLES gt_vbap18
    USING 'GO_AV2000_2' go_ic2000_2
          'ZVBAP18' " 프로그램 내의 내부테이블을
*                      이용해서 필드카테고리를 정의할 수 있다.
          ''.

    0o_av_refresh 'GO_AV2000_2' 'X' 'X' 'X'.

  DATA: ls_layout_vbap TYPE lvc_s_layo.

  IF go_av2000_2 IS BOUND.
    go_av2000_2->get_frontend_layout( IMPORTING es_layout = ls_layout_vbap ).

    ls_layout_vbap-ctab_fname = 'SCOL'.
    ls_layout_vbap-grid_title = 'SO ITEM : VBAP'. " <--- 제목 추가

    go_av2000_2->set_frontend_layout( is_layout = ls_layout_vbap ).
    go_av2000_2->refresh_table_display( ).
  ENDIF.




  PERFORM 0o_av_make
   TABLES gt_lips18
    USING 'GO_AV2000_3' go_ic2000_3
          'ZLIPS18' " 프로그램 내의 내부테이블을
*                      이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_3' 'X' 'X' 'X'.

  DATA: ls_layout_lips TYPE lvc_s_layo.

  " 이거 강제로 가져옴 ㅋㅋㅋㅋ " 근데 이거 사실은 scol 있는 테이블일 필요한 듯함.
  IF go_av2000_3 IS BOUND.
    " 1. 현재 레이아웃 가져오기
    go_av2000_3->get_frontend_layout( IMPORTING es_layout = ls_layout_lips ).

    " 2. 색상 필드 이름 강제 지정 (SCOL)
    ls_layout_lips-ctab_fname = 'SCOL'.

    ls_layout_lips-grid_title = 'DO ITEM : LIPS'.

    " 3. 다시 적용하기
    go_av2000_3->set_frontend_layout( is_layout = ls_layout_lips ).

    " 4. 적용을 위해 테이블 다시 그리기
    go_av2000_3->refresh_table_display( ).
  ENDIF.



  PERFORM 0o_av_make
   TABLES gt_vbrp18
    USING 'GO_AV2000_4' go_ic2000_4
          'ZVBRP18' " 프로그램 내의 내부테이블을
*                      이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_4' 'X' 'X' 'X'.

  DATA: ls_layout_vbrp TYPE lvc_s_layo.

  " 이거 강제로 가져옴 ㅋㅋㅋㅋ " 근데 이거 사실은 scol 있는 테이블일 필요한 듯함.
  IF go_av2000_4 IS BOUND.
    " 1. 현재 레이아웃 가져오기
    go_av2000_4->get_frontend_layout( IMPORTING es_layout = ls_layout_vbrp ).

    " 2. 색상 필드 이름 강제 지정 (SCOL)
    ls_layout_vbrp-ctab_fname = 'SCOL'.

    ls_layout_vbrp-grid_title = 'BI ITEM : VBRP'.

    " 3. 다시 적용하기
    go_av2000_4->set_frontend_layout( is_layout = ls_layout_vbrp ).

    " 4. 적용을 위해 테이블 다시 그리기
    go_av2000_4->refresh_table_display( ).
  ENDIF.





ENDMODULE.                 " AV2000_X_MAKE  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  av2000_1_cell_click
*&---------------------------------------------------------------------*
FORM av2000_1_cell_click                                    "#EC *
  USING pv_av_name
        pc_gubun
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.  " 선택한 행 정보

  REFRESH gt_vbap18.
  REFRESH gt_lips18.
  REFRESH gt_vbrp18.


  READ TABLE gt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak>) INDEX
ps_row_no-row_id. " 그 행의 몇번째 줄인지. 그 행 줄을 <ls_likp>로 함.
  CHECK sy-subrc = 0.   " 성공 못하면 빠져나감.

  CASE ps_col-fieldname.  " 클릭한 열 이름인가봄.
    WHEN 'VBELN'.
      READ TABLE gt_vbap18_t TRANSPORTING NO FIELDS  " do 아이템에서 선택한 행에 속한 아이템이 있는 지 확인
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_vbak>-vbeln.  " vbeln 을 통해 확인.
      IF sy-subrc = 0.
        LOOP AT gt_vbap18_t ASSIGNING FIELD-SYMBOL(<ls_vbap_t>)
            FROM sy-tabix USING KEY idx01.  " 확인된 행부터 시작
          IF <ls_vbap_t>-vbeln <> <ls_vbak>-vbeln.
            EXIT. " 헤더의 키 값과 달라지면 나가기
          ENDIF.
          APPEND INITIAL LINE TO gt_vbap18  " 위에서 말했듯이.
          ASSIGNING FIELD-SYMBOL(<ls_vbap>).  " 아래 alv 에서 보여주기 위한 아이템 테이블
          MOVE-CORRESPONDING <ls_vbap_t> TO <ls_vbap>.  " 보여줄 데이터

          0o_av_scol_set <ls_vbap>-scol 'KWMENG' 'C500' ''. " 수량
        ENDLOOP.          " 즉 선택한 헤더와 관련된 아이템을 gt_lips 에 담아준다.
      ENDIF.

      SORT gt_vbap18 BY vbeln.  " 정렬

      0o_av_chg_set 'GO_AV2000_2' 'X'.  " 아래 아이템 용 alv 새로고침 일듯.
      0o_av_chg_set 'GO_AV2000_3' 'X'.
      0o_av_chg_set 'GO_AV2000_4' 'X'.

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
        ps_row_no LIKE lvc_s_roid.  " 선택한 행 정보

  REFRESH gt_lips18.
  REFRESH gt_vbrp18.

  READ TABLE gt_vbap18 ASSIGNING FIELD-SYMBOL(<ls_vbap>) INDEX
ps_row_no-row_id. " 그 행의 몇번째 줄인지. 그 행 줄을 <ls_likp>로 함.
  CHECK sy-subrc = 0.   " 성공 못하면 빠져나감.

  CASE ps_col-fieldname.  " 클릭한 열 이름인가봄.
    WHEN 'VBELN'.
      READ TABLE gt_lips18_t TRANSPORTING NO FIELDS  " do 아이템에서 선택한 행에 속한 아이템이 있는 지 확인
        WITH TABLE KEY idx01 COMPONENTS vgbel = <ls_vbap>-vbeln.  " vbeln 을 통해 확인.
      IF sy-subrc = 0.
        LOOP AT gt_lips18_t ASSIGNING FIELD-SYMBOL(<ls_lips_t>)
            FROM sy-tabix USING KEY idx01.  " 확인된 행부터 시작
          IF <ls_lips_t>-vgbel <> <ls_vbap>-vbeln.
            EXIT. " 헤더의 키 값과 달라지면 나가기
          ENDIF.
          APPEND INITIAL LINE TO gt_lips18  " 위에서 말했듯이.
          ASSIGNING FIELD-SYMBOL(<ls_lips>).  " 아래 alv 에서 보여주기 위한 아이템 테이블
          MOVE-CORRESPONDING <ls_lips_t> TO <ls_lips>.  " 보여줄 데이터
          0o_av_scol_set <ls_lips>-scol 'VGBEL' 'C600' ''.  " 색 칠하기

          0o_av_scol_set <ls_lips>-scol 'LFIMG' 'C500' ''.  " 수량

        ENDLOOP.          " 즉 선택한 헤더와 관련된 아이템을 gt_lips 에 담아준다.
      ENDIF.

      SORT gt_lips18 BY vbeln.  " 정렬

      0o_av_chg_set 'GO_AV2000_3' 'X'.  " 아래 아이템 용 alv 새로고침 일듯.
      0o_av_chg_set 'GO_AV2000_4' 'X'.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  av2000_3_cell_click
*&---------------------------------------------------------------------*
FORM av2000_3_cell_click                                    "#EC *
  USING pv_av_name
        pc_gubun
        ps_row    LIKE lvc_s_row
        ps_col    LIKE lvc_s_col
        ps_row_no LIKE lvc_s_roid.  " 선택한 행 정보

  REFRESH gt_vbrp18.

  READ TABLE gt_lips18 ASSIGNING FIELD-SYMBOL(<ls_lips>) INDEX
ps_row_no-row_id. " 그 행의 몇번째 줄인지. 그 행 줄을 <ls_likp>로 함.
  CHECK sy-subrc = 0.   " 성공 못하면 빠져나감.

  CASE ps_col-fieldname.  " 클릭한 열 이름인가봄.
    WHEN 'VBELN'.
      READ TABLE gt_vbrp18_t TRANSPORTING NO FIELDS  " do 아이템에서 선택한 행에 속한 아이템이 있는 지 확인
        WITH TABLE KEY idx01 COMPONENTS vgbel = <ls_lips>-vbeln.  " vbeln 을 통해 확인.
      IF sy-subrc = 0.
        LOOP AT gt_vbrp18_t ASSIGNING FIELD-SYMBOL(<ls_vbrp_t>)
            FROM sy-tabix USING KEY idx01.  " 확인된 행부터 시작
          IF <ls_vbrp_t>-vgbel <> <ls_lips>-vbeln.
            EXIT. " 헤더의 키 값과 달라지면 나가기
          ENDIF.
          APPEND INITIAL LINE TO gt_vbrp18  " 위에서 말했듯이.
          ASSIGNING FIELD-SYMBOL(<ls_vbrp>).  " 아래 alv 에서 보여주기 위한 아이템 테이블
          MOVE-CORRESPONDING <ls_vbrp_t> TO <ls_vbrp>.  " 보여줄 데이터
          0o_av_scol_set <ls_vbrp>-scol 'VGBEL' 'C600' ''.  " 색 칠하기

          0o_av_scol_set <ls_vbrp>-scol 'FKIMG' 'C500' ''.  " 수량
        ENDLOOP.          " 즉 선택한 헤더와 관련된 아이템을 gt_lips 에 담아준다.
      ENDIF.

      SORT gt_vbrp18 BY vbeln.  " 정렬

      0o_av_chg_set 'GO_AV2000_4' 'X'.  " 아래 아이템 용 alv 새로고침 일듯.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 1000_onli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM 1000_onli .


  REFRESH: gt_vbak18, gt_vbap18, gt_lips18, gt_vbrp18.

  DATA: lt_vbak18_t type TABLE OF ty_vbak18.
  DATA: lt_vbap18_t type TABLE OF zvbap18.
  DATA: lt_lips18_t type TABLE OF zlips18.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbak18
    FROM zvbak18
    WHERE vbeln IN so_vbeln AND
          erdat IN so_erdat.

  gt_vbak18_t = gt_vbak18.


  Loop at gt_vbak18 ASSIGNING FIELD-SYMBOL(<gt_vbak>) .
    0o_av_scol_set <gt_vbak>-scol 'BSTNK' 'C600' ''.  " PO


    0o_av_scol_set <gt_vbak>-scol 'NETWR' 'C300' ''.  " 순금액
    0o_av_scol_set <gt_vbak>-scol 'WAERK' 'C300' ''.  " 통화

    0o_av_scol_set <gt_vbak>-scol 'GBSTK' 'C700' ''.


    ENDLOOP.


  lt_vbak18_t = gt_vbak18_t.

  SORT lt_vbak18_t by vbeln.
  delete ADJACENT DUPLICATES FROM lt_vbak18_t COMPARING vbeln.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbap18_t
      FROM zvbap18
      FOR ALL ENTRIES IN lt_vbak18_t   " lt_lipsv 에 있는 값들을 돌면서
      WHERE vbeln = lt_vbak18_t-vbeln.

  lt_vbap18_t = gt_vbap18_t.

  SORT lt_vbap18_t by vbeln.
  delete ADJACENT DUPLICATES FROM lt_vbap18_t COMPARING vbeln.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_lips18_t
      FROM zlips18
      FOR ALL ENTRIES IN lt_vbap18_t   " lt_lipsv 에 있는 값들을 돌면서
      WHERE vgbel = lt_vbap18_t-vbeln.

  lt_lips18_t = gt_lips18_t.

  SORT lt_lips18_t by vbeln.
  delete ADJACENT DUPLICATES FROM lt_lips18_t COMPARING vbeln.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrp18_t
      FROM zvbrp18
      FOR ALL ENTRIES IN lt_lips18_t  " lt_lipsv 에 있는 값들을 돌면서
      WHERE vgbel = lt_lips18_t-vbeln.



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

  CHECK sy-batch = zlea_. " 백그라운드 작업 일때는 빠져나감.

  DESCRIBE TABLE gt_vbak18 LINES lv_cnt.  " 조회된 do 헤더 테이블의 레코드 개수 세기
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
  IF LV_CNT > 1.
    SORT gt_vbak18 by vbeln.
    SORT gt_vbap18_t by vbeln.
    SORT gt_lips18_t by vbeln.
    SORT gt_vbrp18_t by vbeln.
    CALL SCREEN 2000.
  ENDIF.

ENDFORM.

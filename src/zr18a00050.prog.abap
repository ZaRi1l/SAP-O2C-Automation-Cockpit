*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZR18A00050
* Desc       : Display Billing Doucments
* Transaction: ZR18A00050
* Creator    : REM0018
* Create day  : 2026.01.12
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.12    박규태              최초작성
*&---------------------------------------------------------------------*

REPORT ZR18A00050.

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

TABLES: VBRK, VBRP.

DATA: gt_vbrk18 type TABLE OF zvbrk18.
DATA: gt_vbrp_t type TABLE OF zvbrp18 WITH NON-UNIQUE SORTED KEY idx01
      COMPONENTS vbeln.
DATA: gt_vbrp18 type TABLE OF zvbrp18.


*----------------------------------------------------------------------*
* Selection 스크린
*----------------------------------------------------------------------*
SELECT-OPTIONS:
 so_vbeln FOR VBRK-vbeln,
 so_erdat FOR VBRK-erdat OBLIGATORY.


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
   TABLES gt_vbrk18
    USING 'GO_AV2000_1' go_ic2000_1
          'ZVBRK18'   " 아밥 딕셔너리에 선언된 테이블, 구조, 뷰를
*                    이용해서 필드카테고리를 정의할 수 있다.
          ''.

  0o_av_refresh 'GO_AV2000_1' 'X' 'X' 'X'.

  PERFORM 0o_av_make
   TABLES gt_vbrp18
    USING 'GO_AV2000_2' go_ic2000_2
          'ZVBRP18' " 프로그램 내의 내부테이블을
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

  REFRESH gt_VBRP18.

  READ TABLE gt_VBRK18 ASSIGNING FIELD-SYMBOL(<ls_vbrk>) INDEX
ps_row_no-row_id. " 그 행의 몇번째 줄인지. 그 행 줄을 <ls_likp>로 함.
  CHECK sy-subrc = 0.   " 성공 못하면 빠져나감.

  CASE ps_col-fieldname.  " 클릭한 열 이름인가봄.
    WHEN 'VBELN'.
      READ TABLE gt_vbrp_t TRANSPORTING NO FIELDS  " do 아이템에서 선택한 행에 속한 아이템이 있는 지 확인
        WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_vbrk>-vbeln.  " vbeln 을 통해 확인.
      IF sy-subrc = 0.
        LOOP AT gt_vbrp_t ASSIGNING FIELD-SYMBOL(<ls_vbrp_t>)
            FROM sy-tabix USING KEY idx01.  " 확인된 행부터 시작
          IF <ls_vbrp_t>-vbeln <> <ls_vbrk>-vbeln.
            EXIT. " 헤더의 키 값과 달라지면 나가기
          ENDIF.
          APPEND INITIAL LINE TO gt_vbrp18  " 위에서 말했듯이.
          ASSIGNING FIELD-SYMBOL(<ls_vbrp>).  " 아래 alv 에서 보여주기 위한 아이템 테이블
          MOVE-CORRESPONDING <ls_vbrp_t> TO <ls_vbrp>.  " 보여줄 데이터
        ENDLOOP.          " 즉 선택한 헤더와 관련된 아이템을 gt_lips 에 담아준다.
      ENDIF.

      SORT gt_vbrp18 BY vbeln posnr.  " 정렬

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

  DATA: lt_vbrkv TYPE TABLE OF zvbrk18. " do 의 아이템을 구하기 위한 키값
*  DATA: lt_lips  TYPE TABLE OF lips WITH NON-UNIQUE SORTED KEY idx01
*        COMPONENTS vbeln. " do의 아이템 테이블  (이거 없어도 될듯)

  DATA: lt_idx TYPE i.  " 인덱스 저장용.



  REFRESH: gt_vbrk18, gt_vbrp18.
*&--------------------------------*
  " 현제 bi 의 헤더 정보 가져오기 (이건 위에 alv 에서 보여줄것임)
*&--------------------------------*
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrk18
    FROM zvbrk18
    WHERE vbeln IN so_vbeln AND
          erdat IN so_erdat.

  lt_vbrkv = gt_vbrk18.     " 값 넣어주고
  sort lt_vbrkv by vbeln.   " 키값에 맞춰서 sort
  delete ADJACENT DUPLICATES FROM lt_vbrkv COMPARING vbeln. " 키값 중복 삭제

*&--------------------------------*
" do 헤더에 속한 아이템 미리 가져와 넣어놓기 (매번 db 연결해서 select 하면 안 좋기에)
*&--------------------------------*
  IF lt_vbrkv IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vbrp_t
      FROM zvbrp18
      FOR ALL ENTRIES IN lt_vbrkv   " lt_lipsv 에 있는 값들을 돌면서
      WHERE vbeln = lt_vbrkv-vbeln. " vbeln 키값과 일치하는 값 확인

*&--------------------------------*
*** ITEM이 없는 DO건은 제외
*&--------------------------------*
    IF gt_vbrp_t IS INITIAL.
      REFRESH gt_vbrk18.    " 아이템이 아예 없으면, 헤더도 아예 없어야함.
    ELSE.
      LOOP AT gt_vbrk18 ASSIGNING FIELD-SYMBOL(<gt_vbrk>).
        lt_idx = sy-tabix.  " 현재 gt_likp의 레코드 인덱스 넣기.
        READ TABLE gt_vbrp_t TRANSPORTING NO FIELDS " 아이템에 헤더의 vbeln과 일치하는 항목이 있는지 확인
          WITH TABLE KEY idx01 COMPONENTS vbeln = <gt_vbrk>-vbeln.
        IF sy-subrc <> 0. " 검색이 안됬다면.
          DELETE gt_vbrk18 INDEX lt_idx. " 그 줄 삭제.
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

  DESCRIBE TABLE gt_vbrk18 LINES lv_cnt.  " 조회된 do 헤더 테이블의 레코드 개수 세기
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
      SORT gt_vbrk18 by vbeln.
      SORT gt_vbrp_t by vbeln posnr.
    ENDIF.

    CALL SCREEN 2000.
  ENDIF.

ENDFORM.

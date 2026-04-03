*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDC
* Program ID : ZRSYA00010
* Desc       : Create Sales Order by PO
* Transaction: ZRSDX00080
* Creator    : REM0024
* Create day  : 2026.01.01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.01.01    홍길동              최초작성
*&---------------------------------------------------------------------*

REPORT ZR18A00000.

INCLUDE : yg1000,                                " 개발 공용 Include
            yg1000_cn,                           " CoNtainer Include
              yg1000_av.

* ALV
DATA : go_cc2000_1 TYPE REF TO cl_gui_custom_container,     "#EC NEEDED
       go_av2000_1 TYPE REF TO cl_gui_alv_grid.

* 선언부
TABLES: VBAP.
data: gt_itab type table of ZS18A00040.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.


*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  select *
  into CORRESPONDING FIELDS OF table gt_itab
  up to 1 ROWS
  from VBAP
  where vbeln <> zlea_.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  call SCREEN 2000.
*&---------------------------------------------------------------------*
*&      Module  2000_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 2000_status OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.

ENDMODULE.                 " 2000_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  AV2000_X_MAKE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE av2000_x_make OUTPUT.

  0o_cc_make 'GO_CC2000_1' 'GV_CX2000_1'.

  PERFORM 0o_av_make
   TABLES gt_itab
    USING 'GO_AV2000_1' go_cc2000_1
          'ZS18A00040'   " 아밥 딕셔너리에 선언된 테이블, 구조, 뷰를
*                    이용해서 필드카테고리를 정의할 수 있다.
          ''.


ENDMODULE.                 " AV2000_X_MAKE  OUTPUT




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
  GS_ZS_AV_LAYOUT-TOTALS_BEF = 'X'.
  GS_ZS_AV_LAYOUT-ZEBRA = 'X'.
  GS_ZS_AV_LAYOUT-GRID_TITLE = '이건 무지개야!'.
  GS_ZS_AV_LAYOUT-NO_TOOLBAR = 'X'.
  GS_ZS_AV_LAYOUT-SEL_MODE = 'A'.

* GT_ZT_AV_FCAT
  0O_AV_FCAT_FIELD : 'S' 'STATU' '',  " STATUS
                     ' ' 'KEY' 'X',
                     'E' 'FIX_COLUMN' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'VBELN' '',  " Sales Document
                     ' ' 'KEY' 'X',
                     ' ' 'FIX_COLUMN' 'X',
                     'E' 'HOTSPOT' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'POSNR' '',  " Item
                     ' ' 'KEY' 'X',
                     'E' 'FIX_COLUMN' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'MATNR' '',  " Material
                     ' ' 'COLTEXT' '빨',
                     'E' 'EMPHASIZE' 'C711'.

  0O_AV_FCAT_FIELD : 'S' 'MATWA' '',  " MaterialEntered
                     ' ' 'COLTEXT' '주',
                     'E' 'EMPHASIZE' 'C611'.

  0O_AV_FCAT_FIELD : 'S' 'PMATN' '',  " Pr. Ref. Matl
                     ' ' 'COLTEXT' '노',
                     'E' 'EMPHASIZE' 'C310'.

  0O_AV_FCAT_FIELD : 'S' 'CHARG' '',  " Batch
                     ' ' 'COLTEXT' '연초',
                     'E' 'EMPHASIZE' 'C500'.

  0O_AV_FCAT_FIELD : 'S' 'MATKL' '',  " Material Group
                     ' ' 'COLTEXT' '초',
                     'E' 'EMPHASIZE' 'C510'.

  0O_AV_FCAT_FIELD : 'S' 'ARKTX' '',  " Description
                     ' ' 'COLTEXT' '파',
                     'E' 'EMPHASIZE' 'C410'.

  0O_AV_FCAT_FIELD : 'S' 'PSTYV' '',  " Item category
                     ' ' 'COLTEXT' '남?',
                     'E' 'EMPHASIZE' 'C210'.

  0O_AV_FCAT_FIELD : 'S' 'POSAR' '',  " Item type
                     ' ' 'COLTEXT' '이거는 스파이얌',
                     'E' 'EDIT' 'X'.

  0O_AV_FCAT_FIELD : 'S' 'LFREL' '',  " Item rel.f.dlv.
                     ' ' 'COLTEXT' '금?',
                     'E' 'EMPHASIZE' 'C301'.

* SORT
  0O_AV_SORT_MAKE :
    'VBELN' 'X' '' ''.

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
FORM AV2000_1_DATA_CHANGED
  USING pv_av_name
        po_change TYPE REF TO cl_alv_changed_data_protocol
        pv_onf4
        pv_onf4_before
        pv_onf4_after
        pv_ucomm.

  DATA(lt_cell) = po_change->mt_good_cells.

  LOOP AT lt_cell ASSIGNING FIELD-SYMBOL(<ls_cell>).
    READ TABLE GT_ITAB
    ASSIGNING FIELD-SYMBOL(<ls_itab>) INDEX <ls_cell>-row_id.
    IF sy-subrc EQ 0.
      CASE <ls_cell>-fieldname.
        WHEN 'POSAR'.

      ENDCASE.
      0o_av_mg_show po_change <ls_cell> GS_ZS_RETURN.
      MODIFY GT_ITAB FROM <ls_itab> INDEX <ls_cell>-row_id.
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
FORM AV2000_1_CHANGED_FINISHED
  TABLES pt_modi STRUCTURE lvc_s_modi
   USING pv_av_name pv_modified.

  CHECK pv_modified EQ abap_true.
  LOOP AT pt_modi.
    READ TABLE GT_ITAB ASSIGNING FIELD-SYMBOL(<ls_itab>)
    INDEX pt_modi-row_id.
    IF sy-subrc EQ 0.
      CASE pt_modi-fieldname.
        WHEN 'POSAR'.

      ENDCASE.
    ENDIF.
  ENDLOOP.

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

  READ TABLE GT_ITAB ASSIGNING FIELD-SYMBOL(<ls_itab>)
                         INDEX ps_row_no-row_id.
  CHECK sy-subrc EQ 0.

  CASE ps_col-fieldname.
    WHEN 'VBELN'.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
* 모듈/서브모듈 : SD/SDC
* Program ID : ZITR18_3
* Desc       : Total Sum
* Transaction: ZITR18_3
* Creator    : REM0018
* Create day : 2026.01.04
*&---------------------------------------------------------------------*
*             변경 이력
*---------- ------------ ----------- -----------------------------------
* No        Changed on   Changed By  C?R Number
* New       2026.01.04   박규태       최초작성
*&---------------------------------------------------------------------*

REPORT ZITR18_3.

* Session 3
* Field-Symbol과 Internal Table 및 구조체 설명
* Field-Symbol 활용 Internal Table Loop 처리 - SALV.

* Subroutine(FORM)
* ZZ_GET_WEIGHT
* ZZ_GET_MATNR_NAME
* ZZ_GET_KUNNR

* Function
* 1) ZSY18_GET_WEIGHT
* 2) ZSY18_GET_MATNR_NAME
* 3_ ZSY18_GET_KUNNR



*  DATA : lt_itab  TYPE TABLE OF lips.
*  DATA : lt_lips  TYPE TABLE OF lips.
*  DATA : lt_vbapv TYPE SORTED TABLE OF vbap WITH UNIQUE KEY vbeln.
*  DATA : lt_vbrp  TYPE TABLE OF vbrp.
*  DATA : lt_vbap  TYPE TABLE OF vbap
*         WITH NON-UNIQUE SORTED KEY idx01 COMPONENTS vbeln
*         WITH NON-UNIQUE SORTED KEY idx02 COMPONENTS vbeln posnr.
*
*
** itab
*SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE lt_lips
*  FROM lips
*  UP TO 100 ROWS
*WHERE vgbel <> ''.
*
*lt_itab = lt_lips.
*
*
**FAE
*MOVE-CORRESPONDING lt_lips TO lt_vbapv.
*DELETE ADJACENT DUPLICATES FROM lt_vbapv COMPARING vgbel.
*
*IF lt_vbapv IS NOT INITIAL.
*  SELECT vbeln posnr
*    INTO CORRESPONDING FIELDS OF TABLE lt_vbap
*    FROM vbap
*    FOR ALL ENTRIES IN lt_vbapv
*    WHERE vbeln = lt_vbapv-vbeln.
*    FREE lt_vbapv.
*ENDIF.
*
*
** itab -> assing
*LOOP AT lt_itab ASSIGNING FIELD-SYMBOL(<ls_itab>).
*  READ TABLE lt_vbap ASSIGNING FIELD-SYMBOL(<ls_vbak>)
*    WITH TABLE KEY idx01 COMPONENTS vbeln = <ls_itab>-vbeln.
*  IF sy-subrc = 0.
*    <ls_itab>-matnr = <ls_vbak>-ernam.
*  ENDIF.
*
*
** 빌링 item도 읽기
*  READ TABLE lt_vbap TRANSPORTING NO FIELDS
*  WITH TABLE KEY idx02 COMPONENTS vbeln = <ls_itab>-vbeln
*                                  posnr = <ls_itab>-posnr.
*  if sy-subrc = 0.
*
*    loop at lt_vbap ASSIGNING FIELD-SYMBOL(<ls_vbap>)
*      FROM sy-tabix USING KEY idx02.
*      IF <ls_vbap>-vbeln <> <ls_itab>-vbeln or
*         <ls_vbap>-posnr <> <ls_itab>-posnr.
*        exit.
*  ENDIF.
*
*  ENDLOOP.
* ENDIF.
* ENDLOOP.
*** ----------------------------------------------------------------------------
***
***
*** ----------------------------------------------------------------------------
*/-- 선언부
TYPES: BEGIN OF gty_itab,
       vkorg  TYPE vbak-vkorg,
       vtweg  TYPE vbak-vtweg,
       spart  TYPE vbak-spart,
       kunnr  TYPE vbak-kunnr,
       vbeln  TYPE vbap-vbeln,
       posnr  TYPE vbap-posnr,
       matnr  TYPE vbap-matnr,
       maktx  TYPE makt-maktx,
       kwmeng TYPE vbap-kwmeng,
       vrkme  TYPE vbap-vrkme,
       addqty TYPE vbap-kwmeng,
       brgew  TYPE marm-brgew,
       addgew TYPE marm-brgew,  " 개수 * 무게 총합
       gewei  TYPE marm-gewei,
       END OF gty_itab.

DATA: gt_itab  TYPE TABLE OF gty_itab.

CONSTANTS : gc_meinh TYPE marm-meinh VALUE 'ST'.  " 상수

*/-- 쿼리
SELECT *
  UP TO 10 ROWS
  INTO CORRESPONDING FIELDS OF TABLE gt_itab
  FROM vbap
  WHERE vbeln <> zlea_.

*/-- itab에 값넣기
LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>).
  PERFORM zz_get_weight     CHANGING <gs_itab>.
  PERFORM zz_get_matnr_name CHANGING <gs_itab>.
  PERFORM zz_get_kunnr      CHANGING <gs_itab>.

*  gv_dd = <gs_itab>-matnr. " 했을때, 만약 값이 없으면 프로그램 터짐.
*
*  if <gs_itab>-matnr IS INITIAL.  " 이때, <gs_itab>이 아닌 <gs_itab>-matnr으로 해야함. 필드 하나에 대해서 검사해야함.
*    gv_dd = <gs_itab>-matnr. " 했을때, 만약 값이 없으면 프로그램 터짐.
*  ENDIF.
ENDLOOP.

*/-- display List
cl_demo_output=>display( gt_itab ).


*&---------------------------------------------------------------------*
*&      Form  ZZ_GET_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<GS_ITAB>  text
*----------------------------------------------------------------------*
FORM zz_get_weight  CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA : ls_marm TYPE marm.   " 그냥 ps_itab 넘긴 다음에. 원하는 값만 넣어주면 안되나?? corresponding으로??

  CALL FUNCTION 'ZSY18_GET_WEIGHT'
    EXPORTING
     iv_matnr  = ps_itab-matnr
     iv_meinh  = gc_meinh
   IMPORTING
     es_marm   = ls_marm.

    ps_itab-brgew = ls_marm-brgew.
    ps_itab-gewei = ls_marm-gewei.

    ps_itab-addgew = ps_itab-kwmeng * ps_itab-brgew.

ENDFORM.                    " ZZ_GET_WEIGHT
*&---------------------------------------------------------------------*
*&      Form  ZZ_GET_MATNR_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_ITAB  text
*----------------------------------------------------------------------*
FORM zz_get_matnr_name  CHANGING ps_itab LIKE LINE OF gt_itab.

  CALL FUNCTION 'ZSY18_GET_MATNR_NAME'
    EXPORTING
     iv_matnr   = ps_itab-matnr
   IMPORTING
     ev_maktx   = ps_itab-maktx.

ENDFORM.                    " ZZ_GET_QTY
*&---------------------------------------------------------------------*
*&      Form  ZZ_GET_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<GS_ITAB>  text
*----------------------------------------------------------------------*
FORM zz_get_kunnr  CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA : ls_vbak TYPE vbak.

  CALL FUNCTION 'ZSY18_GET_KUNNR'
    EXPORTING
     iv_vbeln   = ps_itab-vbeln
   IMPORTING
     es_vbak    = ls_vbak.

   ps_itab-kunnr = ls_vbak-kunnr.
   ps_itab-vkorg = ls_vbak-vkorg.
   ps_itab-vtweg = ls_vbak-vtweg.
   ps_itab-spart = ls_vbak-spart.

ENDFORM.                    " ZZ_GET_KUNNR

*&---------------------------------------------------------------------*
* 모듈/서브모듈 : SD/SDC
* Program ID : ZSYSDR18
* Desc       : Make Functions
* Transaction: ZSYSDR18
* Creator    : REM0018
* Create day : 2026.01.04
*&---------------------------------------------------------------------*
*             변경 이력
*---------- ------------ ----------- -----------------------------------
* No        Changed on   Changed By  C?R Number
* New       2026.01.04   박규태       최초작성
*&---------------------------------------------------------------------*

REPORT ZSYSDR18.

TABLES: VBAK, VBAP, LIPS, KNA1, KNVV.

TYPES: BEGIN OF GS_ITAB,
       vkorg  TYPE vbak-vkorg,"
       vtweg  TYPE vbak-vtweg,"
       spart  TYPE vbak-spart,"
       kunnr  TYPE vbak-kunnr,"
       vbeln  TYPE lips-vbeln, "
       matnr  TYPE lips-matnr, "
       matwa  TYPE lips-matwa,"
       posnr  TYPE lips-posnr,"
       werks  TYPE lips-werks,"
       lgort  TYPE lips-lgort,"
       kwmeng TYPE vbap-kwmeng,"
       vrkme  TYPE vbap-vrkme,"
       land1  TYPE kna1-land1,
       name1  TYPE kna1-name1,
       name2  TYPE kna1-name2,
       stras  TYPE kna1-stras,
       aufsd  TYPE knvv-aufsd,
       netpr  TYPE vbap-netpr,"
       sumpr  TYPE vbap-netpr,
       END OF GS_ITAB.


DATA: gt_itab TYPE TABLE OF gs_itab.



SELECT C~vkorg C~vtweg C~spart C~kunnr
  A~vbeln A~matnr A~matwa A~posnr A~werks A~lgort
  B~kwmeng B~vrkme B~netpr
  INTO CORRESPONDING FIELDS OF TABLE gt_itab
  FROM LIPS as A INNER JOIN vbap as B on A~vgbel eq B~vbeln
  INNER JOIN VBAK as C ON B~VBELN eq C~vbeln
  WHERE A~vbeln in ('0020000105', '0020000118', '0020000119', '0080003370', '0080003371').


LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<gs_itab>).
*  PERFORM SD_GET_VBAK CHANGING <gs_itab>.
  PERFORM SD_GET_KNA1 CHANGING <gs_itab>.
  PERFORM SD_GET_KNVV CHANGING <gs_itab>.

*  IF <gs_itab>-netpr is INITIAL. " 이거 먼저 해야함.
    <gs_itab>-netpr = 500.
*  ENDIF.
  <gs_itab>-sumpr = <gs_itab>-kwmeng * <gs_itab>-netpr.

ENDLOOP.



cl_demo_output=>display( gt_itab ).



" 서브루틴을 만들자!!

*FORM SD_GET_VBAK CHANGING ps_itab LIKE LINE OF gt_itab.
*
*  DATA: ls_vbak TYPE VBAK.
*
*  CALL FUNCTION 'ZSY18_GET_VBAK'
*  EXPORTING
*    iv_vbeln   = ps_itab-vbeln
*   IMPORTING
*     es_vbak    = ls_vbak.
*
*   ps_itab-vkorg = ls_vbak-vkorg.
*   ps_itab-vtweg = ls_vbak-vtweg.
*   ps_itab-spart = ls_vbak-spart.
*   ps_itab-kunnr = ls_vbak-kunnr.
*
*
*ENDFORM.


FORM SD_GET_KNA1 CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_kna1 TYPE KNA1.

  CALL FUNCTION 'ZSY18_GET_KNA1'
  EXPORTING
    iv_kunnr   = ps_itab-kunnr
   IMPORTING
     es_kna1    = ls_kna1.

  ps_itab-land1 = ls_kna1-land1.
  ps_itab-name1 = ls_kna1-name1.
  ps_itab-name2 = ls_kna1-name2.
  ps_itab-stras = ls_kna1-stras.
*   ps_itab-vkorg = ls_vbak-vkorg.
*   ps_itab-vtweg = ls_vbak-vtweg.
*   ps_itab-spart = ls_vbak-spart.
*   ps_itab-kunnr = ls_vbak-kunnr.


ENDFORM.




FORM SD_GET_KNVV CHANGING ps_itab LIKE LINE OF gt_itab.

  DATA: ls_knvv TYPE KNVV.

  CALL FUNCTION 'ZSY18_GET_KNVV'
  EXPORTING
    iv_kunnr   = ps_itab-kunnr
   IMPORTING
     es_knvv    = ls_knvv.

  ps_itab-aufsd = ls_knvv-aufsd.

*  ps_itab-land1 = ls_kna1-land1.
*  ps_itab-name1 = ls_kna1-name1.
*  ps_itab-name2 = ls_kna1-name2.
*  ps_itab-stras = ls_kna1-stras.

*cl_demo_output=>display( ps_itab ).

ENDFORM.

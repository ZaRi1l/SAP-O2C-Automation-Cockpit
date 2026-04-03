*&---------------------------------------------------------------------*
* 모듈/서브모듈 : SD/SDC
* Program ID : ZITR18_2
* Desc       : standard/sorted
* Transaction: ZITR18_2
* Creator    : REM0018
* Create day : 2026.01.04
*&---------------------------------------------------------------------*
*             변경 이력
*---------- ------------ ----------- -----------------------------------
* No        Changed on   Changed By  C?R Number
* New       2026.01.04   박규태       최초작성
*&---------------------------------------------------------------------*

REPORT ZITR18_2.

* Session 2
* Internal Table 값 할당 및 정렬 (Standard / Sorted Table)
* Read Table
* Inter Table Update 확인


* Strandard Table
*DATA : lt_vbap TYPE TABLE OF vbap.
DATA : lt_vbap TYPE STANDARD TABLE OF vbap
                WITH NON-UNIQUE SORTED KEY idx1 COMPONENTS vbeln posnr,
       ls_vbap TYPE vbap.
DATA : gr_table TYPE REF TO cl_salv_table.

CONSTANTS lc_success VALUE '0'.

  SELECT *
    FROM vbap
   INTO CORRESPONDING FIELDS OF TABLE lt_vbap
   WHERE vbap~vbeln IN ('0000004969', '0000004970', '0000004971').

  SORT : lt_vbap.

  LOOP AT lt_vbap INTO ls_vbap.
    READ TABLE lt_vbap INTO ls_vbap WITH TABLE KEY idx1 COMPONENTS vbeln = ls_vbap-vbeln
                                                                   posnr = ls_vbap-posnr.
    ls_vbap-erdat = sy-datum.
    ls_vbap-erzet = sy-uzeit.
    ls_vbap-ernam = sy-uname.
    MODIFY lt_vbap FROM ls_vbap.
  ENDLOOP.

* SALV
 TRY.
     cl_salv_table=>factory(
     IMPORTING
       r_salv_table = gr_table
     CHANGING
       t_table = lt_vbap ).
   CATCH cx_salv_msg.
 ENDTRY.
 gr_table->display( ).

* Sorted Table
*1) Sorted Table > Salv
*DATA : lt_vbap TYPE SORTED TABLE OF vbap WITH UNIQUE KEY vbeln posnr matnr,
*       ls_vbap TYPE vbap.
*DATA : gr_table TYPE REF TO cl_salv_table.
*
*CONSTANTS lc_success VALUE '0'.
*
*
*  SELECT *
*    FROM vbap
*   INTO CORRESPONDING FIELDS OF TABLE lt_vbap
*   WHERE vbap~vbeln IN ('0000004969', '0000004970', '0000004971').
*
*
*  LOOP AT lt_vbap INTO ls_vbap.
*    READ TABLE lt_vbap INTO ls_vbap WITH TABLE KEY vbeln = ls_vbap-vbeln
*                                                   posnr = ls_vbap-posnr
*                                                   matnr = ls_vbap-matnr.
*    ls_vbap-erdat = sy-datum.
*    ls_vbap-erzet = sy-uzeit.
*    ls_vbap-ernam = sy-uname.
*    MODIFY lt_vbap FROM ls_vbap.
*  ENDLOOP.
*
** SALV
* TRY.
*     cl_salv_table=>factory(
*     IMPORTING
*       r_salv_table = gr_table
*     CHANGING
*       t_table = lt_vbap ).
*   CATCH cx_salv_msg.
* ENDTRY.
* gr_table->display( ).


* 2) Standard Table > Salv
*DATA : lt_vbap  TYPE SORTED TABLE OF vbap WITH UNIQUE KEY vbeln posnr matnr,
*       ls_vbap  TYPE vbap,
*       lt_vbapv TYPE TABLE OF vbap.
*DATA : gr_table TYPE REF TO cl_salv_table.
*
*CONSTANTS lc_success VALUE '0'.
*
*  SELECT *
*    FROM vbap
*   INTO CORRESPONDING FIELDS OF TABLE lt_vbap
*   WHERE vbap~vbeln IN ('0000004969', '0000004970', '0000004971').
*
*
*  LOOP AT lt_vbap INTO ls_vbap.
*    READ TABLE lt_vbap INTO ls_vbap WITH TABLE KEY vbeln = ls_vbap-vbeln
*                                                   posnr = ls_vbap-posnr
*                                                   matnr = ls_vbap-matnr.
*    ls_vbap-erdat = sy-datum.
*    ls_vbap-erzet = sy-uzeit.
*    ls_vbap-ernam = sy-uname.
*    MODIFY lt_vbap FROM ls_vbap.
*  ENDLOOP.
*
*  MOVE-CORRESPONDING lt_vbap TO lt_vbapv.
*
** SALV
* TRY.
*     cl_salv_table=>factory(
*     IMPORTING
*       r_salv_table = gr_table
*     CHANGING
*       t_table = lt_vbapv ).
*   CATCH cx_salv_msg.
* ENDTRY.
* gr_table->display( ).

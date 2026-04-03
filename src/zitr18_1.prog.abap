*&---------------------------------------------------------------------*
* 모듈/서브모듈 : SD/SDC
* Program ID : ZITR18_1
* Desc       : Kind of Internal Table
* Transaction: ZITR18_1
* Creator    : REM0018
* Create day : 2026.01.04
*&---------------------------------------------------------------------*
*             변경 이력
*---------- ------------ ----------- -----------------------------------
* No        Changed on   Changed By  C?R Number
* New       2026.01.04   박규태       최초작성
*&---------------------------------------------------------------------*

REPORT ZITR18_1.

" Session 1
* Internal Table(ITAB)
* Work Area
* Structure
* Internal Table 종류

" Internal Table(ITAB)
*-------------------------------------------------------------------------
DATA : lt_yrmt00 TYPE TABLE OF yrmt00 WITH HEADER LINE,
       lt_vbak   TYPE TABLE OF vbak,
       ls_vbak   TYPE vbak,
       lt_vbap   TYPE SORTED TABLE OF vbap WITH UNIQUE KEY vbeln posnr,
       lt_likp   TYPE STANDARD TABLE OF likp,
       lt_lips   TYPE HASHED TABLE OF lips WITH UNIQUE KEY vbeln posnr.
DATA : gr_table TYPE REF TO cl_salv_table.

CONSTANTS lc_success VALUE '0'.

* 1) WITH Header Line 예시
  SELECT *
    FROM yrmt00
    INTO CORRESPONDING FIELDS OF TABLE lt_yrmt00.

  IF sy-subrc EQ lc_success.
    LOOP AT lt_yrmt00 FROM sy-tabix.
      lt_yrmt00-erdat = sy-datum.
      lt_yrmt00-erzet = sy-uzeit.
      lt_yrmt00-ernam = sy-uname.

      MODIFY lt_yrmt00[] FROM lt_yrmt00.
      CLEAR : lt_yrmt00.
    ENDLOOP.

    MODIFY yrmt00 FROM lt_yrmt00[].
  ENDIF.

* SALV
 TRY.
     cl_salv_table=>factory(
     IMPORTING
       r_salv_table = gr_table
     CHANGING
       t_table = lt_yrmt00[] ).
   CATCH cx_salv_msg.
 ENDTRY.
 gr_table->display( ).


* 2) ITAB, Structure 예시
*  SELECT *
*    FROM vbak
*    INTO CORRESPONDING FIELDS OF TABLE lt_vbak
*    UP TO 10 ROWS.
*
*  IF sy-subrc EQ lc_success.
*    LOOP AT lt_vbak INTO ls_vbak.
*      ls_vbak-erdat = sy-datum.
*      ls_vbak-erzet = sy-uzeit.
*      ls_vbak-ernam = sy-uname.
*
*      MODIFY lt_vbak FROM ls_vbak.
*      CLEAR : ls_vbak.
*    ENDLOOP.
*  ENDIF.
*
** SALV
* TRY.
*     cl_salv_table=>factory(
*     IMPORTING
*       r_salv_table = gr_table
*     CHANGING
*       t_table = lt_vbak ).
*   CATCH cx_salv_msg.
* ENDTRY.
* gr_table->display( ).


* 3) STANDARD TABLE 예시 - 아래 테이블 타입 모두 같은 내용
*DATA : gt_likp   TYPE STANDARD TABLE OF likp,
*       lt_vbak   TYPE TABLE OF vbak.


* 4) SORTED TABLE 예시 - 인터널 테이블에 담기는 데이터를 자동으로 정렬해준다.


* 5) HASHED TABLE 예시 - Index를 가지지 않는 테이블이다.
*-------------------------------------------------------------------------

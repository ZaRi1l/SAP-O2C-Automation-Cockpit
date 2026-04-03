class ZCL18_LEC_AUTO_PLAN definition
  public
  final
  create public .

public section.

  class-methods ZZ_GET_SO_RTN
    importing
      value(IS_PO_H) type ZEKKO18
      value(IT_PO_I) type ZTTEKPO18
    exporting
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_DO_RTN
    importing
      value(IS_SO_H) type ZVBAK18
      value(IT_SO_I) type ZTTVBAP18
    exporting
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_BI_RTN
    importing
      value(IS_DO_H) type ZLIKP18
      value(IT_DO_I) type ZTTLIPS18
    exporting
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_GI_RTN
    exporting
      value(ES_RETURN) type BAPIRET2
    changing
      value(CS_DO_H) type ZLIKP18 .
protected section.
private section.
ENDCLASS.



CLASS ZCL18_LEC_AUTO_PLAN IMPLEMENTATION.


method ZZ_GET_BI_RTN.

    DATA: lt_vbrk18 TYPE TABLE OF zvbrk18.
    DATA: lt_vbrp18 TYPE TABLE OF zvbrp18.
    DATA: lt_likp18 TYPE TABLE OF zlikp18.

    " do 참조로 billing 문서 만들기
    CHECK is_do_h IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_vbrk18 ASSIGNING FIELD-SYMBOL(<ls_vbrk18>).
    MOVE-CORRESPONDING is_do_h TO <ls_vbrk18>.

    <ls_vbrk18>-erdat = sy-datum.   " 날짜 넣기

    " Doc Number
    CALL FUNCTION 'ZF18_GET_NUMBER_NEXT'
     EXPORTING
      iv_nrnr = 'BI'
     IMPORTING
       ev_vbeln = <ls_vbrk18>-vbeln.

    es_return-field = <ls_vbrk18>-vbeln.

    LOOP AT it_do_i ASSIGNING FIELD-SYMBOL(<ls_do_i>).
      APPEND INITIAL LINE TO lt_vbrp18 ASSIGNING FIELD-SYMBOL(<ls_vbrp18>).
      MOVE-CORRESPONDING <ls_do_i> TO <ls_vbrp18>.
      <ls_vbrp18>-vbeln = <ls_vbrk18>-vbeln.

      <ls_vbrp18>-vgbel  = <ls_do_i>-vbeln.
      <ls_vbrp18>-vgpos  = <ls_do_i>-posnr.
     ENDLOOP.

     IF lt_vbrk18 IS NOT INITIAL.
       MODIFY zvbrk18 FROM TABLE lt_vbrk18.
     ENDIF.

     IF lt_vbrp18 IS NOT INITIAL.
       MODIFY zvbrp18 FROM TABLE lt_vbrp18.
     ENDIF.

     es_return-type = zle18_e.

    " bi 만드는 과정 뿐만 아니라, do 헤더에 billing 번호를 넣지 못할 경우 에러 표시하도록 함.
    IF sy-subrc = 0.

      " 성공일경우 ZLIKP18-XABLN = Billing번호를 넣고 ZLIKP18를 저장한다.
      APPEND INITIAL LINE TO lt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp18>).
      MOVE-CORRESPONDING is_do_h TO <ls_likp18>.
      <ls_likp18>-xabln = <ls_vbrk18>-vbeln.

      IF lt_likp18 IS NOT INITIAL.
        MODIFY zlikp18 FROM TABLE lt_likp18.
      ENDIF.

      IF sy-subrc = 0.
        es_return-type = zle18_s.
      ENDIF.

    ELSE.
      es_return-type = zle18_e.
    ENDIF.

  endmethod.


method ZZ_GET_DO_RTN.

    DATA: lt_likp18 TYPE TABLE OF zlikp18.
    DATA: lt_lips18 TYPE TABLE OF zlips18.
    DATA: lt_vbak18 type TABLE OF zvbak18.

    " so 참조로 do 문서 만들기
    CHECK is_so_h IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp18>).
    MOVE-CORRESPONDING is_so_h TO <ls_likp18>.

    " Doc Number
    CALL FUNCTION 'ZF18_GET_NUMBER_NEXT'
     EXPORTING
      iv_nrnr = 'DO'
     IMPORTING
       ev_vbeln = <ls_likp18>-vbeln.

    es_return-field = <ls_likp18>-vbeln.

    <ls_likp18>-erdat = sy-datum.

    LOOP AT it_so_i ASSIGNING FIELD-SYMBOL(<ls_so_i>).
      APPEND INITIAL LINE TO lt_lips18 ASSIGNING FIELD-SYMBOL(<ls_lips18>).
      MOVE-CORRESPONDING <ls_so_i> TO <ls_lips18>.
      <ls_lips18>-vbeln = <ls_likp18>-vbeln.
      <ls_lips18>-posnr = <ls_so_i>-posnr.
      <ls_lips18>-lfimg = <ls_so_i>-kwmeng.
      <ls_lips18>-vrkme = <ls_so_i>-vrkme.
      <ls_lips18>-vgbel = <ls_so_i>-vbeln.
      <ls_lips18>-vgpos = <ls_so_i>-posnr.
     ENDLOOP.

     IF lt_likp18 IS NOT INITIAL.
       MODIFY zlikp18 FROM TABLE lt_likp18.
     ENDIF.

     IF lt_lips18 IS NOT INITIAL.
       MODIFY zlips18 FROM TABLE lt_lips18.
     ENDIF.


    es_return-type = zle18_e.

    IF sy-subrc = 0.

      " 성공일경우 ZVBAK18-SUBMI = D/O번호를 넣고 ZVBAK18를 저장한다.  " UPDATE 쓰는게 더 나을려나요?
      APPEND INITIAL LINE TO lt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak18>).
      MOVE-CORRESPONDING is_so_h TO <ls_vbak18>.
      <ls_vbak18>-submi = <ls_likp18>-vbeln.

      IF lt_vbak18 IS NOT INITIAL.
        MODIFY zvbak18 FROM TABLE lt_vbak18.
      ENDIF.

      IF sy-subrc = 0.
        es_return-type = zle18_s.
      ENDIF.

    ENDIF.

  endmethod.


method ZZ_GET_GI_RTN.

    DATA: lt_likp18 TYPE TABLE OF zlikp18.

    CHECK cs_do_h IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_likp18 ASSIGNING FIELD-SYMBOL(<ls_likp18>).
    MOVE-CORRESPONDING cs_do_h TO <ls_likp18>.
    <ls_likp18>-wadat_ist = sy-datum.

    es_return-field = <ls_likp18>-vbeln.

     IF lt_likp18 IS NOT INITIAL.
       MODIFY zlikp18 FROM TABLE lt_likp18.
     ENDIF.

    IF sy-subrc = 0.
      es_return-type = zle18_s.
    ELSE.
      es_return-type = zle18_e.
    ENDIF.

  endmethod.


method ZZ_GET_SO_RTN.

    DATA: lt_vbak18 TYPE TABLE OF zvbak18.
    DATA: lt_vbap18 TYPE TABLE OF zvbap18.

    " po 참조로 so 문서 만들기
    CHECK is_po_h IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_vbak18 ASSIGNING FIELD-SYMBOL(<ls_vbak18>).
    MOVE-CORRESPONDING is_po_h TO <ls_vbak18>.
    <ls_vbak18>-bstnk = is_po_h-ebeln.
    <ls_vbak18>-auart = zle18_or.
    <ls_vbak18>-waerk = is_po_h-waers.

    <ls_vbak18>-erdat = sy-datum.
    <ls_vbak18>-erzet = sy-uzeit.
    <ls_vbak18>-ernam = sy-uname.

    " Doc Number
    CALL FUNCTION 'ZF18_GET_NUMBER_NEXT'
     EXPORTING
      iv_nrnr = 'SO'
     IMPORTING
       ev_vbeln = <ls_vbak18>-vbeln.

    es_return-field = <ls_vbak18>-vbeln.

    LOOP AT it_po_i ASSIGNING FIELD-SYMBOL(<ls_po_i>).
      APPEND INITIAL LINE TO lt_vbap18 ASSIGNING FIELD-SYMBOL(<ls_vbap18>).
      MOVE-CORRESPONDING <ls_po_i> TO <ls_vbap18>.
      <ls_vbap18>-vbeln = <ls_vbak18>-vbeln.
      <ls_vbap18>-posnr = <ls_po_i>-ebelp.
      <ls_vbap18>-kwmeng = <ls_po_i>-menge.
      <ls_vbap18>-vrkme = <ls_po_i>-meins.
      <ls_vbap18>-posex = <ls_po_i>-ebelp.

     ENDLOOP.

     IF lt_vbak18 IS NOT INITIAL.
       MODIFY zvbak18 FROM TABLE lt_vbak18.
     ENDIF.

     IF lt_vbap18 IS NOT INITIAL.
       MODIFY zvbap18 FROM TABLE lt_vbap18.
     ENDIF.

    IF sy-subrc = 0.
      es_return-type = zle18_s.
    ELSE.
      es_return-type = zle18_e.
    ENDIF.

  endmethod.
ENDCLASS.

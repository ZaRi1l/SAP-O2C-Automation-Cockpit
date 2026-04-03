class ZCL18_LEC_AUTO_PLAN_1_BACK_UP definition
  public
  final
  create public .

public section.

  class-methods ZZ_GET_SO_RTN
    importing
      value(IT_PO_H) type ZTTEKKO18
      value(IT_PO_I) type ZTTEKPO18
    exporting
      value(ET_SO_H) type ZTTVBAK18
      value(ET_SO_I) type ZTTVBAP18
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_DO_RTN
    importing
      value(IT_SO_H) type ZTTVBAK18
      value(IT_SO_I) type ZTTVBAP18
    exporting
      value(ET_DO_H) type ZTTLIKP18
      value(ET_DO_I) type ZTTLIPS18
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_BI_RTN
    importing
      value(IT_DO_H) type ZTTLIKP18
      value(IT_DO_I) type ZTTLIPS18
    exporting
      value(ET_BI_H) type ZTTVBRK18
      value(ET_BI_I) type ZTTVBRP18
      value(ES_RETURN) type BAPIRET2 .
  class-methods ZZ_GET_GI_RTN
    exporting
      value(ES_RETURN) type BAPIRET2
    changing
      value(CT_DO_H) type ZTTLIKP18
      value(CT_DO_I) type ZTTLIPS18 .
protected section.
private section.
ENDCLASS.



CLASS ZCL18_LEC_AUTO_PLAN_1_BACK_UP IMPLEMENTATION.


method ZZ_GET_BI_RTN.

    LOOP AT it_do_h ASSIGNING FIELD-SYMBOL(<ls_do_h>).
      APPEND INITIAL LINE TO et_bi_h ASSIGNING FIELD-SYMBOL(<ls_bi_h>).
      MOVE-CORRESPONDING <ls_do_h> TO <ls_bi_h>.
    ENDLOOP.

    LOOP AT it_do_I ASSIGNING FIELD-SYMBOL(<ls_do_I>).
      APPEND INITIAL LINE TO et_bi_I ASSIGNING FIELD-SYMBOL(<ls_bi_I>).
      MOVE-CORRESPONDING <ls_do_I> TO <ls_bi_I>.
    ENDLOOP.

    IF ET_bi_H IS NOT INITIAL AND
      ET_bi_I IS NOT INITIAL.
      ES_RETURN-TYPE  = ZLEA_S.
    ELSE.
      REFRESH: ET_bi_H, ET_bi_I.
      ES_RETURN-TYPE  = ZLEA_E.
    ENDIF.

  endmethod.


method ZZ_GET_DO_RTN.

    LOOP AT it_So_h ASSIGNING FIELD-SYMBOL(<ls_So_h>).
      APPEND INITIAL LINE TO et_do_h ASSIGNING FIELD-SYMBOL(<ls_do_h>).
      MOVE-CORRESPONDING <ls_So_h> TO <ls_do_h>.
    ENDLOOP.

    LOOP AT it_So_I ASSIGNING FIELD-SYMBOL(<ls_So_I>).
      APPEND INITIAL LINE TO et_do_I ASSIGNING FIELD-SYMBOL(<ls_do_I>).
      MOVE-CORRESPONDING <ls_So_I> TO <ls_do_I>.
    ENDLOOP.

    IF ET_do_H IS NOT INITIAL AND
      ET_do_I IS NOT INITIAL.
      ES_RETURN-TYPE  = ZLEA_S.
    ELSE.
      REFRESH: ET_do_H, ET_do_I.
      ES_RETURN-TYPE  = ZLEA_E.
    ENDIF.

  endmethod.


method ZZ_GET_GI_RTN.
    LOOP AT ct_do_h ASSIGNING FIELD-SYMBOL(<ls_do_h>).
      <ls_do_h>-wadat_ist = sy-datum.
    ENDLOOP.
  endmethod.


method ZZ_GET_SO_RTN.

    LOOP AT it_po_h ASSIGNING FIELD-SYMBOL(<ls_po_h>).
      APPEND INITIAL LINE TO et_so_h ASSIGNING FIELD-SYMBOL(<ls_so_h>).
      MOVE-CORRESPONDING <ls_po_h> TO <ls_so_h>.
    ENDLOOP.

    LOOP AT it_po_I ASSIGNING FIELD-SYMBOL(<ls_po_I>).
      APPEND INITIAL LINE TO et_so_I ASSIGNING FIELD-SYMBOL(<ls_so_I>).
      MOVE-CORRESPONDING <ls_po_I> TO <ls_so_I>.
    ENDLOOP.

    IF ET_SO_H IS NOT INITIAL AND
      ET_SO_I IS NOT INITIAL.
      ES_RETURN-TYPE  = ZLEA_S.
    ELSE.
      REFRESH: ET_SO_H, ET_SO_I.
      ES_RETURN-TYPE  = ZLEA_E.
    ENDIF.

  endmethod.
ENDCLASS.

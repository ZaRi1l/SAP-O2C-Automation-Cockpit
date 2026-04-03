FUNCTION ZF18_GET_NUMBER_NEXT .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_NRNR) TYPE  NRNR OPTIONAL
*"  EXPORTING
*"     VALUE(EV_VBELN) TYPE  VBELN_VA
*"----------------------------------------------------------------------


  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = iv_nrnr
      object      = 'ZSYPO18'  "이미지의 ZSYPOXX를 18로 변경
    IMPORTING
      number      = ev_vbeln.

  IF sy-subrc <> 0.
    " Implement suitable error handling here
  ENDIF.


ENDFUNCTION.

*&---------------------------------------------------------------------*
*&  Include           ZRSDX00200_C01
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING sender e_object e_interactive.

ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD on_toolbar.
    PERFORM event_toolbar USING e_object
                                e_interactive.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*&  Include           ZRSDX00200_TOP
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA : gv_err(1).
*DATA : BEGIN OF gs_data,
*        vbeln      TYPE vbak-vbeln,
*        erdat      TYPE vbak-erdat,
*        erzet      TYPE vbak-erzet,
*        ernam      TYPE vbak-ernam,
*        vbtyp      TYPE vbak-vbtyp,
*        vkorg      TYPE vbak-vkorg,
*        vtweg      TYPE vbak-vtweg,
*        linecolor  TYPE c LENGTH 4,
*        celltab    TYPE lvc_t_styl,
*       END OF gs_data,
*       gt_data LIKE TABLE OF gs_data.
DATA : gs_data TYPE vbak,
       gt_data LIKE TABLE OF gs_data.
*----------------------------------------------------------------------*
* ALV Variables
*----------------------------------------------------------------------*
DATA: go_grid          TYPE REF TO cl_gui_alv_grid,
      go_split_cont    TYPE REF TO cl_gui_splitter_container,
      go_cont_doc_0100 TYPE REF TO cl_gui_docking_container.

DATA: gs_variant       TYPE disvariant,
      gs_layout        TYPE lvc_s_layo,
      gt_fieldcat      TYPE lvc_t_fcat,
      gt_exclude       TYPE ui_functions,
      gs_fieldcat      TYPE lvc_s_fcat,
      gs_f4            TYPE lvc_s_f4,
      gt_f4            TYPE lvc_t_f4,
      gt_f4_0100       TYPE lvc_t_f4,
      gs_dral          TYPE lvc_s_dral,
      gt_dral          TYPE lvc_t_dral.

DATA: go_head TYPE REF TO cl_gui_container,
      go_docu TYPE REF TO cl_dd_document,
      go_html TYPE REF TO cl_gui_html_viewer.

DATA : gr_table      TYPE REF TO cl_salv_table,
       alv_columns   TYPE REF TO cl_salv_columns_table,
       single_column TYPE REF TO cl_salv_column,
       gr_selection  TYPE REF TO cl_salv_selections,
       err_notfound  TYPE REF TO cx_salv_not_found.

DATA : gv_ok_code TYPE sy-ucomm,
     gv_okcode TYPE sy-ucomm.


CONSTANTS : gc_fname_celltab TYPE fieldname VALUE 'CELLTAB',
            gc_x(1) VALUE 'X',
            gc_c(1) VALUE 'C'.

DATA: go_event      TYPE REF TO lcl_event_receiver.

DATA : gv_cnt TYPE i.

*&---------------------------------------------------------------------*
*&  Include           ZRSDX00200_S01
*&---------------------------------------------------------------------*
TABLES : vbak.

PARAMETER      : p_vbtyp TYPE vbak-vbtyp.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln.
SELECT-OPTIONS : s_audat FOR vbak-audat.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(10) FOR FIELD radi1.
PARAMETER : radi1 RADIOBUTTON GROUP r1 USER-COMMAND a1 DEFAULT 'X'.

SELECTION-SCREEN COMMENT 15(10) FOR FIELD radi2.
PARAMETER : radi2 RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS : p_v1 AS CHECKBOX MODIF ID m1.
SELECTION-SCREEN END OF BLOCK b1.

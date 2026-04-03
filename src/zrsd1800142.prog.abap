************************************************************************
* Modules/Sub Module : SD
************************************************************************
* CREATOR     : REM0018
* CREATE DATE : 2026.01.11
* Description : Message Class3
* Program ID  : ZRSD1800142
* T_CODE      : ZRSD1800142
************************************************************************
*                          Change History
*---------- ------------ ----------- -----------------------------------
* ChangeNo. Changed on   Changed By             Description
*---------- ------------ ----------- -----------------------------------
*    N      2026.01.11    REM0018             Initial Release
************************************************************************

REPORT zrsd1800142 MESSAGE-ID ZSYMS18.

INCLUDE ZRSD1800200_TOP.
*INCLUDE ZRSD1800200_TOP.
INCLUDE ZRSD1800200_S01.
*INCLUDE ZRSD1800200_S01.
INCLUDE ZRSD1800200_C01.
*INCLUDE ZRSD1800200_C01.
INCLUDE ZRSD1800200_O01.
*INCLUDE ZRSD1800200_O01.
INCLUDE ZRSD1800200_I01.
*INCLUDE ZRSD1800200_I01.
INCLUDE ZRSD1800200_F01.
*INCLUDE ZRSD1800200_F01.


INITIALIZATION.
  PERFORM initialization. "기본값 설정

AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output. "스크린 제어 (PBO)

AT SELECTION-SCREEN.
  PERFORM at_selection_screen. "입력값 검사 (PAI)

START-OF-SELECTION.    "데이터 처리
  perform start_of_selection.

END-OF-SELECTION.   " 데이터 처리 이후 출력(ALV)
  CHECK gv_err IS INITIAL.
  CHECK gt_data IS NOT INITIAL.
  CHECK sy-batch = ''.


  gv_cnt = LINES( gt_data ).
  MESSAGE S000(ZSYMS18) WITH gv_cnt.

  CALL SCREEN 2000.


*이벤트 블락 역할(레포트)



*모듈풀 프로그램 흐름

*CALL SCREEN 100
*PROCESS BEFORE OUTPUT (화면 표시 전)
*-> MODULE status_0100
*화면 표시 (UI 입력/버튼 클릭)
*PROCESS AFTER INPUT (입력 후)
*-> MODULE user_command_0100
*조건 처리 (OK_CODE에 따라 분기)

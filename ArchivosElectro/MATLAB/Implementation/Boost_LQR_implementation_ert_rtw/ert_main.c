/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: ert_main.c
 *
 * Code generated for Simulink model 'Boost_LQR_implementation'.
 *
 * Model version                  : 1.16
 * Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
 * C/C++ source code generated on : Wed Nov 18 10:42:43 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Atmel->AVR
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Boost_LQR_implementation.h"
#include "rtwtypes.h"
#include "ext_mode.h"                  /* External mode header file */
#include "xcp.h"
#include "MW_target_hardware_resources.h"

volatile int IsrOverrun = 0;
static boolean_T OverrunFlag = 0;
void rt_OneStep(void)
{
  extmodeSimulationTime_T extmodeTime = (extmodeSimulationTime_T)0;
  extmodeErrorCode_T extmodeError = EXTMODE_SUCCESS;

  /* Check for overrun. Protect OverrunFlag against preemption */
  if (OverrunFlag++) {
    IsrOverrun = 1;
    OverrunFlag--;
    return;
  }

#ifndef _MW_ARDUINO_LOOP_

  sei();

#endif;

  extmodeTime = (extmodeSimulationTime_T)
    (((Boost_LQR_implementation_M->Timing.clockTick0 * 1) + 0));
  Boost_LQR_implementation_step();

  /* Get model outputs here */
  extmodeError = extmodeEvent((extmodeEventId_T)(0), extmodeTime);
  if (extmodeError != EXTMODE_SUCCESS) {
    /* Code to handle external mode event errors may be added here */
  }

#ifndef _MW_ARDUINO_LOOP_

  cli();

#endif;

  OverrunFlag--;
}

extern void rtIOStreamResync();
volatile boolean_T stopRequested;
volatile boolean_T runModel;
int main(void)
{
  float modelBaseRate = 0.00025;
  float systemClock = 0;
  extmodeErrorCode_T errorCode = EXTMODE_SUCCESS;

  /* Initialize variables */
  stopRequested = false;
  runModel = false;
  init();
  MW_Arduino_Init();
  rtmSetErrorStatus(Boost_LQR_implementation_M, 0);

  /* Parse External Mode command line arguments */
  errorCode = extmodeParseArgs(0, (const char_T**)NULL);
  if (errorCode != EXTMODE_SUCCESS) {
    return errorCode;
  }

  Boost_LQR_implementation_initialize();
  cli();
  sei();

  /* External Mode initialization */
  errorCode = extmodeInit(Boost_LQR_implementation_M->extModeInfo,
    (extmodeSimulationTime_T *)rteiGetPtrTFinalTicks
    (Boost_LQR_implementation_M->extModeInfo));
  if (errorCode != EXTMODE_SUCCESS) {
    return errorCode;
  }

  if (errorCode == EXTMODE_SUCCESS) {
    /* Wait until a Start or Stop Request has been received from the Host */
    extmodeWaitForHostRequest(EXTMODE_WAIT_FOREVER);
    if (extmodeStopRequested()) {
      rtmSetStopRequested(Boost_LQR_implementation_M, true);
    }
  }

  cli();
  configureArduinoAVRTimer();
  runModel =
    !extmodeSimulationComplete() && !extmodeStopRequested()&&
    !rtmGetStopRequested(Boost_LQR_implementation_M);

#ifndef _MW_ARDUINO_LOOP_

  sei();

#endif;

  XcpStatus lastXcpState = xcpStatusGet();
  sei();
  while (runModel) {
    /* Run External Mode background activities */
    errorCode = extmodeBackgroundRun();
    if (errorCode != EXTMODE_SUCCESS && errorCode != EXTMODE_EMPTY) {
      /* Code to handle External Mode background task errors
         may be added here */
    }

    stopRequested = !(
                      !extmodeSimulationComplete() && !extmodeStopRequested()&&
                      !rtmGetStopRequested(Boost_LQR_implementation_M));
    runModel = !(stopRequested);
    if (stopRequested)
      disable_rt_OneStep();
    if (lastXcpState==XCP_CONNECTED && xcpStatusGet()==XCP_DISCONNECTED)
      rtIOStreamResync();
    lastXcpState = xcpStatusGet();
    MW_Arduino_Loop();
    MW_Modbus_Slave_Poll();
  }

  /* Terminate model */
  Boost_LQR_implementation_terminate();

  /* External Mode reset */
  extmodeReset();
  cli();
  return 0;
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

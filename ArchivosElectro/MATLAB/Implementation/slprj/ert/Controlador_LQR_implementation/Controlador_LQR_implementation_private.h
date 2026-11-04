/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Controlador_LQR_implementation_private.h
 *
 * Code generated for Simulink model 'Controlador_LQR_implementation'.
 *
 * Model version                  : 1.0
 * Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
 * C/C++ source code generated on : Wed Nov  4 10:18:13 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Atmel->AVR
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef Controlador_LQR_implementation_private_h_
#define Controlador_LQR_implementation_private_h_
#include "rtwtypes.h"
#include "Controlador_LQR_implementation.h"
#include "Controlador_LQR_implementation_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         (*((rtm)->errorStatus))
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    (*((rtm)->errorStatus) = (val))
#endif

#ifndef rtmGetErrorStatusPointer
#define rtmGetErrorStatusPointer(rtm)  (rtm)->errorStatus
#endif

#ifndef rtmSetErrorStatusPointer
#define rtmSetErrorStatusPointer(rtm, val) ((rtm)->errorStatus = (val))
#endif

extern P_Controlador_LQR_implementat_T Controlador_LQR_implementatio_P;

#endif                           /* Controlador_LQR_implementation_private_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

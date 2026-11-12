/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Boost_LQR_implementation_data.c
 *
 * Code generated for Simulink model 'Boost_LQR_implementation'.
 *
 * Model version                  : 1.11
 * Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
 * C/C++ source code generated on : Thu Nov 12 11:08:55 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Atmel->AVR
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Boost_LQR_implementation.h"

/* Model block global parameters (default storage) */
real32_T rtP_DeltaD_max = 32.0F;       /* Variable: DeltaD_max
                                        * Referenced by: '<Root>/Model'
                                        */
real32_T rtP_DeltaD_min = -5.0F;       /* Variable: DeltaD_min
                                        * Referenced by: '<Root>/Model'
                                        */
boolean_T rtP_AW_activo = true;        /* Variable: AW_activo
                                        * Referenced by: '<Root>/Model'
                                        */

/* Block parameters (default storage) */
P_Boost_LQR_implementation_T Boost_LQR_implementation_P = {
  /* Expression: 15
   * Referenced by: '<Root>/Referencia'
   */
  15.0,

  /* Expression: 0.2
   * Referenced by: '<Root>/Multiply'
   */
  0.2,

  /* Expression: 1.87543726
   * Referenced by: '<Root>/perturbacion'
   */
  1.87543726,

  /* Expression: 50
   * Referenced by: '<Root>/DutyRef'
   */
  50.0,

  /* Expression: 82
   * Referenced by: '<Root>/Saturation'
   */
  82.0,

  /* Expression: 45
   * Referenced by: '<Root>/Saturation'
   */
  45.0,

  /* Expression: 255/100
   * Referenced by: '<Root>/Gain'
   */
  2.55,

  /* Computed Parameter: Gain1_Gain
   * Referenced by: '<Root>/Gain1'
   */
  0.0048828125F
};

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

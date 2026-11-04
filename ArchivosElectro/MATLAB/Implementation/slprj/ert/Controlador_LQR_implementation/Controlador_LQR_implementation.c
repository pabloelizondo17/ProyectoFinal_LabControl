/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Controlador_LQR_implementation.c
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

#include "Controlador_LQR_implementation.h"
#include "rtwtypes.h"
#include "Controlador_LQR_implementation_private.h"
#include <string.h>

P_Controlador_LQR_implementat_T Controlador_LQR_implementatio_P = {
  /* Computed Parameter: Cero_Value
   * Referenced by: '<Root>/Cero'
   */
  0.0F,

  /* Computed Parameter: UnitDelay_InitialCondition
   * Referenced by: '<Root>/Unit Delay'
   */
  0.0F,

  /* Computed Parameter: Ku_LQR_Gain
   * Referenced by: '<Root>/Ku_LQR'
   */
  -0.474586F,

  /* Computed Parameter: DiscreteTimeIntegrator_gainval
   * Referenced by: '<Root>/Discrete-Time Integrator'
   */
  0.00025F,

  /* Computed Parameter: DiscreteTimeIntegrator_IC
   * Referenced by: '<Root>/Discrete-Time Integrator'
   */
  0.0F,

  /* Computed Parameter: Ki_LQR_Gain
   * Referenced by: '<Root>/Ki_LQR'
   */
  36505.7422F,

  /* Computed Parameter: Kx_LQR_Gain
   * Referenced by: '<Root>/Kx_LQR'
   */
  -31.80093F
};

/* System initialize for referenced model: 'Controlador_LQR_implementation' */
void Controlador_LQR_implementa_Init(DW_Controlador_LQR_implemen_f_T *localDW)
{
  /* InitializeConditions for UnitDelay: '<Root>/Unit Delay' */
  localDW->UnitDelay_DSTATE =
    Controlador_LQR_implementatio_P.UnitDelay_InitialCondition;

  /* InitializeConditions for DiscreteIntegrator: '<Root>/Discrete-Time Integrator' */
  localDW->DiscreteTimeIntegrator_DSTATE =
    Controlador_LQR_implementatio_P.DiscreteTimeIntegrator_IC;
}

/* Output and update for referenced model: 'Controlador_LQR_implementation' */
void Controlador_LQR_implementation(const real32_T *rtu_Error_VA0, const
  real32_T *rtu_Delta_VA0, real32_T *rty_Delta_Duty,
  DW_Controlador_LQR_implemen_f_T *localDW)
{
  real32_T rtb_Sum4;

  /* Sum: '<Root>/Sum4' incorporates:
   *  DiscreteIntegrator: '<Root>/Discrete-Time Integrator'
   *  Gain: '<Root>/Ki_LQR'
   *  Gain: '<Root>/Ku_LQR'
   *  Gain: '<Root>/Kx_LQR'
   *  UnitDelay: '<Root>/Unit Delay'
   */
  rtb_Sum4 = (Controlador_LQR_implementatio_P.Ku_LQR_Gain *
              localDW->UnitDelay_DSTATE +
              Controlador_LQR_implementatio_P.Ki_LQR_Gain *
              localDW->DiscreteTimeIntegrator_DSTATE) +
    Controlador_LQR_implementatio_P.Kx_LQR_Gain * *rtu_Delta_VA0;

  /* Saturate: '<Root>/Sat_DeltaD' */
  if (rtb_Sum4 > rtP_DeltaD_max) {
    *rty_Delta_Duty = rtP_DeltaD_max;
  } else if (rtb_Sum4 < rtP_DeltaD_min) {
    *rty_Delta_Duty = rtP_DeltaD_min;
  } else {
    *rty_Delta_Duty = rtb_Sum4;
  }

  /* End of Saturate: '<Root>/Sat_DeltaD' */

  /* Update for UnitDelay: '<Root>/Unit Delay' */
  localDW->UnitDelay_DSTATE = *rty_Delta_Duty;

  /* Switch: '<Root>/Sw_integrador' incorporates:
   *  Constant: '<Root>/Cero'
   *  Constant: '<Root>/Cte_AW'
   *  Constant: '<Root>/Cte_max'
   *  Constant: '<Root>/Cte_min'
   *  Logic: '<Root>/Congelar'
   *  Logic: '<Root>/Satura_abajo'
   *  Logic: '<Root>/Satura_arriba'
   *  Logic: '<Root>/Satura_empeora'
   *  RelationalOperator: '<Root>/e_negativo'
   *  RelationalOperator: '<Root>/e_positivo'
   *  RelationalOperator: '<Root>/u_mayor_max'
   *  RelationalOperator: '<Root>/u_menor_min'
   */
  if ((((rtb_Sum4 > rtP_DeltaD_max) && (*rtu_Error_VA0 >
         Controlador_LQR_implementatio_P.Cero_Value)) || ((rtb_Sum4 <
         rtP_DeltaD_min) && (*rtu_Error_VA0 <
         Controlador_LQR_implementatio_P.Cero_Value))) && rtP_AW_activo) {
    rtb_Sum4 = Controlador_LQR_implementatio_P.Cero_Value;
  } else {
    rtb_Sum4 = *rtu_Error_VA0;
  }

  /* Update for DiscreteIntegrator: '<Root>/Discrete-Time Integrator' incorporates:
   *  Switch: '<Root>/Sw_integrador'
   */
  localDW->DiscreteTimeIntegrator_DSTATE +=
    Controlador_LQR_implementatio_P.DiscreteTimeIntegrator_gainval * rtb_Sum4;
}

/* Model initialize function */
void Controlador_LQR_impl_initialize(const char_T **rt_errorStatus,
  RT_MODEL_Controlador_LQR_impl_T *const Controlador_LQR_implementati_M,
  DW_Controlador_LQR_implemen_f_T *localDW)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatusPointer(Controlador_LQR_implementati_M, rt_errorStatus);

  /* states (dwork) */
  (void) memset((void *)localDW, 0,
                sizeof(DW_Controlador_LQR_implemen_f_T));
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Controlador_LQR_implementation.h
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

#ifndef Controlador_LQR_implementation_h_
#define Controlador_LQR_implementation_h_
#ifndef Controlador_LQR_implementation_COMMON_INCLUDES_
#define Controlador_LQR_implementation_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "math.h"
#endif                     /* Controlador_LQR_implementation_COMMON_INCLUDES_ */

#include "Controlador_LQR_implementation_types.h"
#include <string.h>

/* Block states (default storage) for model 'Controlador_LQR_implementation' */
typedef struct {
  real32_T UnitDelay_DSTATE;           /* '<Root>/Unit Delay' */
  real32_T DiscreteTimeIntegrator_DSTATE;/* '<Root>/Discrete-Time Integrator' */
} DW_Controlador_LQR_implemen_f_T;

/* Parameters (default storage) */
struct P_Controlador_LQR_implementat_T_ {
  real32_T Cero_Value;                 /* Computed Parameter: Cero_Value
                                        * Referenced by: '<Root>/Cero'
                                        */
  real32_T UnitDelay_InitialCondition;
                               /* Computed Parameter: UnitDelay_InitialCondition
                                * Referenced by: '<Root>/Unit Delay'
                                */
  real32_T Ku_LQR_Gain;                /* Computed Parameter: Ku_LQR_Gain
                                        * Referenced by: '<Root>/Ku_LQR'
                                        */
  real32_T DiscreteTimeIntegrator_gainval;
                           /* Computed Parameter: DiscreteTimeIntegrator_gainval
                            * Referenced by: '<Root>/Discrete-Time Integrator'
                            */
  real32_T DiscreteTimeIntegrator_IC;
                                /* Computed Parameter: DiscreteTimeIntegrator_IC
                                 * Referenced by: '<Root>/Discrete-Time Integrator'
                                 */
  real32_T Ki_LQR_Gain;                /* Computed Parameter: Ki_LQR_Gain
                                        * Referenced by: '<Root>/Ki_LQR'
                                        */
  real32_T Kx_LQR_Gain;                /* Computed Parameter: Kx_LQR_Gain
                                        * Referenced by: '<Root>/Kx_LQR'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_Controlador_LQR_imple_T {
  const char_T **errorStatus;
};

typedef struct {
  DW_Controlador_LQR_implemen_f_T rtdw;
  RT_MODEL_Controlador_LQR_impl_T rtm;
} MdlrefDW_Controlador_LQR_impl_T;

/* Model block global parameters (default storage) */
extern real32_T rtP_DeltaD_max;        /* Variable: DeltaD_max
                                        * Referenced by:
                                        *   '<Root>/Cte_max'
                                        *   '<Root>/Sat_DeltaD'
                                        */
extern real32_T rtP_DeltaD_min;        /* Variable: DeltaD_min
                                        * Referenced by:
                                        *   '<Root>/Cte_min'
                                        *   '<Root>/Sat_DeltaD'
                                        */
extern boolean_T rtP_AW_activo;        /* Variable: AW_activo
                                        * Referenced by: '<Root>/Cte_AW'
                                        */

/* Model reference registration function */
extern void Controlador_LQR_impl_initialize(const char_T **rt_errorStatus,
  RT_MODEL_Controlador_LQR_impl_T *const Controlador_LQR_implementati_M,
  DW_Controlador_LQR_implemen_f_T *localDW);
extern void Controlador_LQR_implementa_Init(DW_Controlador_LQR_implemen_f_T
  *localDW);
extern void Controlador_LQR_implementation(const real32_T *rtu_Error_VA0, const
  real32_T *rtu_Delta_VA0, real32_T *rty_Delta_Duty,
  DW_Controlador_LQR_implemen_f_T *localDW);

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'Controlador_LQR_implementation'
 */
#endif                                 /* Controlador_LQR_implementation_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

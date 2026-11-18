/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Boost_LQR_implementation.h
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

#ifndef Boost_LQR_implementation_h_
#define Boost_LQR_implementation_h_
#ifndef Boost_LQR_implementation_COMMON_INCLUDES_
#define Boost_LQR_implementation_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "rt_nonfinite.h"
#include "math.h"
#endif                           /* Boost_LQR_implementation_COMMON_INCLUDES_ */

#include "Boost_LQR_implementation_types.h"
#include "Controlador_LQR_implementation.h"
#include "MW_target_hardware_resources.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWExtModeInfo
#define rtmGetRTWExtModeInfo(rtm)      ((rtm)->extModeInfo)
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetErrorStatusPointer
#define rtmGetErrorStatusPointer(rtm)  ((const char_T **)(&((rtm)->errorStatus)))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                (&)
#endif

/* Block signals (default storage) */
typedef struct {
  real_T DUTY_GUI;                     /* '<Root>/Saturation' */
  real_T Multiply1;                    /* '<Root>/Multiply1' */
  real_T TmpSignalConversionAtTAQSigLogg[2];
  /* '<Root>/TmpSignal ConversionAtTAQSigLogging_InsertedFor_Mux_at_outport_0Inport1' */
  real32_T VA0_GUI;                    /* '<Root>/Gain1' */
} B_Boost_LQR_implementation_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  codertarget_arduinobase_inter_T obj; /* '<Root>/Analog Input' */
  codertarget_arduinobase_int_l_T obj_b;/* '<Root>/PWM1' */
  struct {
    void *LoggedData;
  } Scope_PWORK;                       /* '<Root>/Scope' */

  MdlrefDW_Controlador_LQR_impl_T Model_InstanceData;/* '<Root>/Model' */
} DW_Boost_LQR_implementation_T;

/* Parameters (default storage) */
struct P_Boost_LQR_implementation_T_ {
  real_T Referencia_Value;             /* Expression: 10
                                        * Referenced by: '<Root>/Referencia'
                                        */
  real_T Multiply_Gain;                /* Expression: 0.2
                                        * Referenced by: '<Root>/Multiply'
                                        */
  real_T perturbacion_Value;           /* Expression: 1.87543726
                                        * Referenced by: '<Root>/perturbacion'
                                        */
  real_T DutyRef_Value;                /* Expression: 50
                                        * Referenced by: '<Root>/DutyRef'
                                        */
  real_T Saturation_UpperSat;          /* Expression: 82
                                        * Referenced by: '<Root>/Saturation'
                                        */
  real_T Saturation_LowerSat;          /* Expression: 45
                                        * Referenced by: '<Root>/Saturation'
                                        */
  real_T Multiply1_Gain;               /* Expression: 5
                                        * Referenced by: '<Root>/Multiply1'
                                        */
  real_T Gain_Gain;                    /* Expression: 255/100
                                        * Referenced by: '<Root>/Gain'
                                        */
  real32_T Gain1_Gain;                 /* Computed Parameter: Gain1_Gain
                                        * Referenced by: '<Root>/Gain1'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_Boost_LQR_implementat_T {
  const char_T *errorStatus;
  RTWExtModeInfo *extModeInfo;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    uint32_T checksums[4];
  } Sizes;

  /*
   * SpecialInfo:
   * The following substructure contains special information
   * related to other components that are dependent on RTW.
   */
  struct {
    const void *mappingInfo;
  } SpecialInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    time_T tFinal;
    boolean_T stopRequestedFlag;
  } Timing;
};

/* Block parameters (default storage) */
extern P_Boost_LQR_implementation_T Boost_LQR_implementation_P;

/* Block signals (default storage) */
extern B_Boost_LQR_implementation_T Boost_LQR_implementation_B;

/* Block states (default storage) */
extern DW_Boost_LQR_implementation_T Boost_LQR_implementation_DW;

/* Model block global parameters (default storage) */
extern real32_T rtP_DeltaD_max;        /* Variable: DeltaD_max
                                        * Referenced by: '<Root>/Model'
                                        */
extern real32_T rtP_DeltaD_min;        /* Variable: DeltaD_min
                                        * Referenced by: '<Root>/Model'
                                        */
extern boolean_T rtP_AW_activo;        /* Variable: AW_activo
                                        * Referenced by: '<Root>/Model'
                                        */

/* Model entry point functions */
extern void Boost_LQR_implementation_initialize(void);
extern void Boost_LQR_implementation_step(void);
extern void Boost_LQR_implementation_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Boost_LQR_implementa_T *const Boost_LQR_implementation_M;
extern volatile boolean_T stopRequested;
extern volatile boolean_T runModel;

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
 * '<Root>' : 'Boost_LQR_implementation'
 */
#endif                                 /* Boost_LQR_implementation_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Boost_LQR_implementation.c
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
#include "MW_AnalogIn.h"
#include "MW_PWM.h"
#include "Boost_LQR_implementation_types.h"
#include <math.h>
#include "rt_nonfinite.h"
#include "rtwtypes.h"
#include "Boost_LQR_implementation_private.h"
#include "Controlador_LQR_implementation.h"

/* Block signals (default storage) */
B_Boost_LQR_implementation_T Boost_LQR_implementation_B;

/* Block states (default storage) */
DW_Boost_LQR_implementation_T Boost_LQR_implementation_DW;

/* Real-time model */
static RT_MODEL_Boost_LQR_implementa_T Boost_LQR_implementation_M_;
RT_MODEL_Boost_LQR_implementa_T *const Boost_LQR_implementation_M =
  &Boost_LQR_implementation_M_;

/* Forward declaration for local functions */
static void Boost_LQR_im_SystemCore_release(codertarget_arduinobase_int_l_T *obj);
static void Boost_LQR_im_SystemCore_release(codertarget_arduinobase_int_l_T *obj)
{
  /* Start for MATLABSystem: '<Root>/PWM1' */
  if ((obj->isInitialized == 1L) && obj->isSetupComplete) {
    obj->PWMDriverObj.MW_PWM_HANDLE = MW_PWM_GetHandle(3UL);
    MW_PWM_SetDutyCycle(obj->PWMDriverObj.MW_PWM_HANDLE, -0.0);
    obj->PWMDriverObj.MW_PWM_HANDLE = MW_PWM_GetHandle(3UL);
    MW_PWM_Close(obj->PWMDriverObj.MW_PWM_HANDLE);
  }

  /* End of Start for MATLABSystem: '<Root>/PWM1' */
}

/* Model step function */
void Boost_LQR_implementation_step(void)
{
  /* local block i/o variables */
  real32_T rtb_Model;
  real_T tmp;
  real32_T rtb_DataTypeConversion2;
  real32_T rtb_DataTypeConversion3;
  uint16_T b_varargout_1;

  /* MATLABSystem: '<Root>/Analog Input' */
  Boost_LQR_implementation_DW.obj.AnalogInDriverObj.MW_ANALOGIN_HANDLE =
    MW_AnalogIn_GetHandle(54UL);
  MW_AnalogInSingle_ReadResult
    (Boost_LQR_implementation_DW.obj.AnalogInDriverObj.MW_ANALOGIN_HANDLE,
     &b_varargout_1, MW_ANALOGIN_UINT16);

  /* Gain: '<Root>/Gain1' incorporates:
   *  DataTypeConversion: '<Root>/Data Type Conversion'
   *  MATLABSystem: '<Root>/Analog Input'
   * */
  Boost_LQR_implementation_B.Gain1 = Boost_LQR_implementation_P.Gain1_Gain *
    (real32_T)b_varargout_1;

  /* DataTypeConversion: '<Root>/Data Type Conversion2' incorporates:
   *  Constant: '<Root>/Referencia'
   *  Gain: '<Root>/Multiply'
   *  Sum: '<Root>/Sum'
   */
  rtb_DataTypeConversion2 = (real32_T)(Boost_LQR_implementation_P.Multiply_Gain *
    Boost_LQR_implementation_P.Referencia_Value -
    Boost_LQR_implementation_B.Gain1);

  /* DataTypeConversion: '<Root>/Data Type Conversion3' incorporates:
   *  Constant: '<Root>/perturbacion'
   *  Sum: '<Root>/Sum1'
   */
  rtb_DataTypeConversion3 = (real32_T)(Boost_LQR_implementation_B.Gain1 -
    Boost_LQR_implementation_P.perturbacion_Value);

  /* ModelReference: '<Root>/Model' */
  Controlador_LQR_implementation(&rtb_DataTypeConversion2,
    &rtb_DataTypeConversion3, &rtb_Model,
    &(Boost_LQR_implementation_DW.Model_InstanceData.rtdw));

  /* Sum: '<Root>/Sum2' incorporates:
   *  Constant: '<Root>/DutyRef'
   */
  Boost_LQR_implementation_B.Saturation = rtb_Model +
    Boost_LQR_implementation_P.DutyRef_Value;

  /* Saturate: '<Root>/Saturation' */
  if (Boost_LQR_implementation_B.Saturation >
      Boost_LQR_implementation_P.Saturation_UpperSat) {
    /* Sum: '<Root>/Sum2' incorporates:
     *  Saturate: '<Root>/Saturation'
     */
    Boost_LQR_implementation_B.Saturation =
      Boost_LQR_implementation_P.Saturation_UpperSat;
  } else if (Boost_LQR_implementation_B.Saturation <
             Boost_LQR_implementation_P.Saturation_LowerSat) {
    /* Sum: '<Root>/Sum2' incorporates:
     *  Saturate: '<Root>/Saturation'
     */
    Boost_LQR_implementation_B.Saturation =
      Boost_LQR_implementation_P.Saturation_LowerSat;
  }

  /* End of Saturate: '<Root>/Saturation' */

  /* DataTypeConversion: '<Root>/Data Type Conversion1' incorporates:
   *  Gain: '<Root>/Gain'
   */
  tmp = floor(Boost_LQR_implementation_P.Gain_Gain *
              Boost_LQR_implementation_B.Saturation);
  if (rtIsNaN(tmp) || rtIsInf(tmp)) {
    tmp = 0.0;
  } else {
    tmp = fmod(tmp, 256.0);
  }

  /* MATLABSystem: '<Root>/PWM1' incorporates:
   *  DataTypeConversion: '<Root>/Data Type Conversion1'
   */
  Boost_LQR_implementation_DW.obj_b.PWMDriverObj.MW_PWM_HANDLE =
    MW_PWM_GetHandle(3UL);
  MW_PWM_SetDutyCycle
    (Boost_LQR_implementation_DW.obj_b.PWMDriverObj.MW_PWM_HANDLE, -((real_T)
      (tmp < 0.0 ? (int16_T)(uint8_T)-(int8_T)(uint8_T)-tmp : (int16_T)(uint8_T)
       tmp) * 100.0 / 255.0));

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The resolution of this integer timer is 0.00025, which is the step size
   * of the task. Size of "clockTick0" ensures timer will not overflow during the
   * application lifespan selected.
   */
  Boost_LQR_implementation_M->Timing.clockTick0++;
}

/* Model initialize function */
void Boost_LQR_implementation_initialize(void)
{
  /* Registration code */
  rtmSetTFinal(Boost_LQR_implementation_M, -1);

  /* External mode info */
  Boost_LQR_implementation_M->Sizes.checksums[0] = (3114208790U);
  Boost_LQR_implementation_M->Sizes.checksums[1] = (1107379403U);
  Boost_LQR_implementation_M->Sizes.checksums[2] = (468574362U);
  Boost_LQR_implementation_M->Sizes.checksums[3] = (3746235956U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[3];
    Boost_LQR_implementation_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = &rtAlwaysEnabled;
    systemRan[2] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(Boost_LQR_implementation_M->extModeInfo,
      &Boost_LQR_implementation_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(Boost_LQR_implementation_M->extModeInfo,
                        Boost_LQR_implementation_M->Sizes.checksums);
    rteiSetTFinalTicks(Boost_LQR_implementation_M->extModeInfo, -1);
  }

  /* Model Initialize function for ModelReference Block: '<Root>/Model' */
  Controlador_LQR_impl_initialize(rtmGetErrorStatusPointer
    (Boost_LQR_implementation_M),
    &(Boost_LQR_implementation_DW.Model_InstanceData.rtm),
    &(Boost_LQR_implementation_DW.Model_InstanceData.rtdw));

  /* SystemInitialize for ModelReference: '<Root>/Model' */
  Controlador_LQR_implementa_Init
    (&(Boost_LQR_implementation_DW.Model_InstanceData.rtdw));

  /* Start for MATLABSystem: '<Root>/Analog Input' */
  Boost_LQR_implementation_DW.obj.matlabCodegenIsDeleted = false;
  Boost_LQR_implementation_DW.obj.isInitialized = 1L;
  Boost_LQR_implementation_DW.obj.AnalogInDriverObj.MW_ANALOGIN_HANDLE =
    MW_AnalogInSingle_Open(54UL);
  Boost_LQR_implementation_DW.obj.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/PWM1' */
  Boost_LQR_implementation_DW.obj_b.matlabCodegenIsDeleted = false;
  Boost_LQR_implementation_DW.obj_b.isInitialized = 1L;
  Boost_LQR_implementation_DW.obj_b.PWMDriverObj.MW_PWM_HANDLE = MW_PWM_Open(3UL,
    1.0, 100.0);
  Boost_LQR_implementation_DW.obj_b.isSetupComplete = true;
}

/* Model terminate function */
void Boost_LQR_implementation_terminate(void)
{
  /* Terminate for MATLABSystem: '<Root>/Analog Input' */
  if (!Boost_LQR_implementation_DW.obj.matlabCodegenIsDeleted) {
    Boost_LQR_implementation_DW.obj.matlabCodegenIsDeleted = true;
    if ((Boost_LQR_implementation_DW.obj.isInitialized == 1L) &&
        Boost_LQR_implementation_DW.obj.isSetupComplete) {
      Boost_LQR_implementation_DW.obj.AnalogInDriverObj.MW_ANALOGIN_HANDLE =
        MW_AnalogIn_GetHandle(54UL);
      MW_AnalogIn_Close
        (Boost_LQR_implementation_DW.obj.AnalogInDriverObj.MW_ANALOGIN_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/Analog Input' */

  /* Terminate for MATLABSystem: '<Root>/PWM1' */
  if (!Boost_LQR_implementation_DW.obj_b.matlabCodegenIsDeleted) {
    Boost_LQR_implementation_DW.obj_b.matlabCodegenIsDeleted = true;
    Boost_LQR_im_SystemCore_release(&Boost_LQR_implementation_DW.obj_b);
  }

  /* End of Terminate for MATLABSystem: '<Root>/PWM1' */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: Boost_LQR_implementation_types.h
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

#ifndef Boost_LQR_implementation_types_h_
#define Boost_LQR_implementation_types_h_
#include "MW_SVD.h"
#include "rtwtypes.h"
#ifndef struct_tag_nAWbnnOgZuxKWuTGXwrCG
#define struct_tag_nAWbnnOgZuxKWuTGXwrCG

struct tag_nAWbnnOgZuxKWuTGXwrCG
{
  MW_Handle_Type MW_ANALOGIN_HANDLE;
};

#endif                                 /* struct_tag_nAWbnnOgZuxKWuTGXwrCG */

#ifndef typedef_e_arduinodriver_ArduinoAnalog_T
#define typedef_e_arduinodriver_ArduinoAnalog_T

typedef struct tag_nAWbnnOgZuxKWuTGXwrCG e_arduinodriver_ArduinoAnalog_T;

#endif                             /* typedef_e_arduinodriver_ArduinoAnalog_T */

#ifndef struct_tag_gXF6Q3iquGlwRgoZrA70wG
#define struct_tag_gXF6Q3iquGlwRgoZrA70wG

struct tag_gXF6Q3iquGlwRgoZrA70wG
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  e_arduinodriver_ArduinoAnalog_T AnalogInDriverObj;
};

#endif                                 /* struct_tag_gXF6Q3iquGlwRgoZrA70wG */

#ifndef typedef_codertarget_arduinobase_inter_T
#define typedef_codertarget_arduinobase_inter_T

typedef struct tag_gXF6Q3iquGlwRgoZrA70wG codertarget_arduinobase_inter_T;

#endif                             /* typedef_codertarget_arduinobase_inter_T */

#ifndef struct_tag_THwWBY9YFNkNDxiODvU89D
#define struct_tag_THwWBY9YFNkNDxiODvU89D

struct tag_THwWBY9YFNkNDxiODvU89D
{
  MW_Handle_Type MW_PWM_HANDLE;
};

#endif                                 /* struct_tag_THwWBY9YFNkNDxiODvU89D */

#ifndef typedef_e_matlabshared_ioclient_perip_T
#define typedef_e_matlabshared_ioclient_perip_T

typedef struct tag_THwWBY9YFNkNDxiODvU89D e_matlabshared_ioclient_perip_T;

#endif                             /* typedef_e_matlabshared_ioclient_perip_T */

#ifndef struct_tag_c1LrmxoqxwjoXkZhzKTz4G
#define struct_tag_c1LrmxoqxwjoXkZhzKTz4G

struct tag_c1LrmxoqxwjoXkZhzKTz4G
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  e_matlabshared_ioclient_perip_T PWMDriverObj;
};

#endif                                 /* struct_tag_c1LrmxoqxwjoXkZhzKTz4G */

#ifndef typedef_codertarget_arduinobase_int_l_T
#define typedef_codertarget_arduinobase_int_l_T

typedef struct tag_c1LrmxoqxwjoXkZhzKTz4G codertarget_arduinobase_int_l_T;

#endif                             /* typedef_codertarget_arduinobase_int_l_T */

/* Parameters (default storage) */
typedef struct P_Boost_LQR_implementation_T_ P_Boost_LQR_implementation_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_Boost_LQR_implementat_T RT_MODEL_Boost_LQR_implementa_T;

#endif                                 /* Boost_LQR_implementation_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

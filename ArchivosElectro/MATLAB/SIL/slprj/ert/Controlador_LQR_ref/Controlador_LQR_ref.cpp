//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: Controlador_LQR_ref.cpp
//
// Code generated for Simulink model 'Controlador_LQR_ref'.
//
// Model version                  : 1.6
// Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
// C/C++ source code generated on : Sun Nov  1 19:22:44 2026
//
// Target selection: ert.tlc
// Embedded hardware selection: Intel->x86-64 (Windows64)
// Code generation objectives: Unspecified
// Validation result: Not run
//
#include "Controlador_LQR_ref.h"
#include "rtwtypes.h"

// Output and update for referenced model: 'Controlador_LQR_ref'
void Controlador_LQR_ref::step(const real_T *rtu_Error_VA0, const real_T
  *rtu_Delta_VA0, real_T *rty_Delta_Duty)
{
  // Sum: '<Root>/Sum4' incorporates:
  //   DiscreteIntegrator: '<Root>/Discrete-Time Integrator'
  //   Gain: '<Root>/Gain2'
  //   Gain: '<Root>/Gain3'
  //   Gain: '<Root>/Gain4'
  //   UnitDelay: '<Root>/Unit Delay'

  *rty_Delta_Duty = (-0.4745859979885071 *
                     Controlador_LQR_ref_DW.UnitDelay_DSTATE + 36505.74399707307
                     * Controlador_LQR_ref_DW.DiscreteTimeIntegrator_DSTATE) +
    -31.80092927863709 * *rtu_Delta_VA0;

  // Update for DiscreteIntegrator: '<Root>/Discrete-Time Integrator'
  Controlador_LQR_ref_DW.DiscreteTimeIntegrator_DSTATE += 0.00025 *
    *rtu_Error_VA0;

  // Update for UnitDelay: '<Root>/Unit Delay'
  Controlador_LQR_ref_DW.UnitDelay_DSTATE = *rty_Delta_Duty;
}

const char_T* Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T::
  getErrorStatus() const
{
  return (*(errorStatus));
}

void Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T::setErrorStatus(const
  char_T* const aErrorStatus) const
{
  (*(errorStatus) = aErrorStatus);
}

const char_T** Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T::
  getErrorStatusPointer() const
{
  return errorStatus;
}

void Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T::setErrorStatusPointer(
  const char_T** aErrorStatusPointer)
{
  (errorStatus = aErrorStatusPointer);
}

// Constructor
Controlador_LQR_ref::Controlador_LQR_ref() :
  Controlador_LQR_ref_DW(),
  Controlador_LQR_ref_M()
{
  // Currently there is no constructor body generated.
}

// Destructor
// Currently there is no destructor body generated.
Controlador_LQR_ref::~Controlador_LQR_ref() = default;

// Real-Time Model get method
Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T * Controlador_LQR_ref::
  getRTM()
{
  return (&Controlador_LQR_ref_M);
}

//
// File trailer for generated code.
//
// [EOF]
//

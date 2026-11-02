//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: Controlador_LQR_ref.h
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
#ifndef CONTROLADOR_LQR_REF_H_
#define CONTROLADOR_LQR_REF_H_
#include <cmath>
#include "rtwtypes.h"
#include "Controlador_LQR_ref_types.h"
#include <cstring>

// Class declaration for model Controlador_LQR_ref
class Controlador_LQR_ref final
{
  // public data and function members
 public:
  // Block states (default storage) for model 'Controlador_LQR_ref'
  struct DW_Controlador_LQR_ref_T {
    real_T DiscreteTimeIntegrator_DSTATE;// '<Root>/Discrete-Time Integrator'
    real_T UnitDelay_DSTATE;           // '<Root>/Unit Delay'
  };

  // Real-time Model Data Structure
  struct RT_MODEL_Controlador_LQR_ref_T {
    const char_T **errorStatus;
    const char_T* getErrorStatus() const;
    void setErrorStatus(const char_T* const aErrorStatus) const;
    const char_T** getErrorStatusPointer() const;
    void setErrorStatusPointer(const char_T** aErrorStatusPointer);
  };

  // Copy Constructor
  Controlador_LQR_ref(Controlador_LQR_ref const&) = delete;

  // Assignment Operator
  Controlador_LQR_ref& operator= (Controlador_LQR_ref const&) & = delete;

  // Move Constructor
  Controlador_LQR_ref(Controlador_LQR_ref &&) = delete;

  // Move Assignment Operator
  Controlador_LQR_ref& operator= (Controlador_LQR_ref &&) = delete;

  // Real-Time Model get method
  Controlador_LQR_ref::RT_MODEL_Controlador_LQR_ref_T * getRTM();

  // model step function
  void step(const real_T *rtu_Error_VA0, const real_T *rtu_Delta_VA0, real_T
            *rty_Delta_Duty);

  // Constructor
  Controlador_LQR_ref();

  // Destructor
  ~Controlador_LQR_ref();

  // private data and function members
 private:
  // Block states
  DW_Controlador_LQR_ref_T Controlador_LQR_ref_DW;

  // Real-Time Model
  RT_MODEL_Controlador_LQR_ref_T Controlador_LQR_ref_M;
};

//-
//  The generated code includes comments that allow you to trace directly
//  back to the appropriate location in the model.  The basic format
//  is <system>/block_name, where system is the system number (uniquely
//  assigned by Simulink) and block_name is the name of the block.
//
//  Use the MATLAB hilite_system command to trace the generated code back
//  to the model.  For example,
//
//  hilite_system('<S3>')    - opens system 3
//  hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
//
//  Here is the system hierarchy for this model
//
//  '<Root>' : 'Controlador_LQR_ref'

#endif                                 // CONTROLADOR_LQR_REF_H_

//
// File trailer for generated code.
//
// [EOF]
//

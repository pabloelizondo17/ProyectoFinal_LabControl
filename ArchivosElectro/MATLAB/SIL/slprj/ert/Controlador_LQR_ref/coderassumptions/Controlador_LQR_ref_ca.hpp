/*
 * File: Controlador_LQR_ref_ca.hpp
 *
 * Abstract: Tests assumptions in the generated code.
 */

#ifndef CONTROLADOR_LQR_REF_CA_H
#define CONTROLADOR_LQR_REF_CA_H

extern "C"
{
  /* preprocessor validation checks */
#include "Controlador_LQR_ref_ca_preproc.hpp"
#include "coder_assumptions_hwimpl.h"

  /* variables holding test results */
  extern CA_ChecksTestResults CA_Controlador_LQR_ref_Res;
  extern CA_PWS_TestResults CA_Controlador_LQR_ref_PWSRes;

  /* variables holding "expected" and "actual" hardware implementation */
  extern const CA_Checks CA_Controlador_LQR_ref_Exp;
  extern CA_Checks CA_Controlador_LQR_ref_Act;
  extern const int numberOfImportedTypes;
  extern const int numberOfNonTunableEnumLiterals;

  /* entry point function to run tests */
  void Controlador_LQR_ref_caRunTests(void);
}

#endif                                 /* CONTROLADOR_LQR_REF_CA_H */

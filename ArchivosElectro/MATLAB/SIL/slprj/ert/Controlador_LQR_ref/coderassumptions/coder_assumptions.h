/*
 * File: coder_assumptions.h
 *
 * Abstract: Coder assumptions header file
 */

#ifndef CODER_ASSUMPTIONS_H
#define CODER_ASSUMPTIONS_H

/* include model specific checks */
#include "Controlador_LQR_ref_ca.hpp"

/* global results variable mapping for static code */
#define CA_Expected                    CA_Controlador_LQR_ref_Exp
#define CA_Actual                      CA_Controlador_LQR_ref_Act
#define CA_TestResults                 CA_Controlador_LQR_ref_Res
#define CA_PortableWordSizes_Results   CA_Controlador_LQR_ref_PWSRes

/* entry point function mapping for static code */
#define CA_Run_Tests                   Controlador_LQR_ref_caRunTests
#define CA_MODEL_SPECIFIC_CHECKS_ENABLED 0
#define CA_NONTUNABLE_ENUM_CHECKS_ENABLED 0
#define CA_CODER_TYPES_DEFINED         1
#endif                                 /* CODER_ASSUMPTIONS_H */

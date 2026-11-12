/* PWM de 80 kHz en el pin D9 del Arduino Mega (Timer2). */
#ifndef PWM80K_H
#define PWM80K_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void pwm80k_iniciar(void);
void pwm80k_fijar(uint8_t cuentas);   /* 0 = apagado, 1..199 = 0,5 % .. 99,5 % */

#ifdef __cplusplus
}
#endif

#endif

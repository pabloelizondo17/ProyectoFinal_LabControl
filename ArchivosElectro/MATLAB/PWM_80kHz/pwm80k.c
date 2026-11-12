/* PWM de 80 kHz en el pin D9 del Arduino Mega (Timer2, salida OC2B).
 * f = 16 MHz / 200 = 80 kHz. Cada cuenta equivale a 0,5 % de duty.
 */
#include "pwm80k.h"
#include <avr/io.h>

void pwm80k_iniciar(void)
{
    DDRH  |= _BV(PH6);                    /* D9 (PH6) como salida, en bajo */
    PORTH &= (uint8_t)~_BV(PH6);
    TCCR2A = 0;
    TCCR2B = 0;
    OCR2A  = 199;                         /* tope: cuenta de 0 a 199 */
    OCR2B  = 0;
    TCCR2A = _BV(WGM21) | _BV(WGM20);     /* fast PWM con tope en OCR2A */
    TCCR2B = _BV(WGM22) | _BV(CS20);      /* sin prescaler */
}

void pwm80k_fijar(uint8_t cuentas)
{
    if (cuentas == 0) {                   /* apagado: pin desconectado y en bajo */
        TCCR2A &= (uint8_t)~_BV(COM2B1);
        PORTH  &= (uint8_t)~_BV(PH6);
        return;
    }
    if (cuentas > 199) {
        cuentas = 199;                    /* nunca 100 % */
    }
    OCR2B   = cuentas - 1;                /* en alto durante OCR2B + 1 cuentas */
    TCCR2A |= _BV(COM2B1);                /* conecta D9 al timer */
}

# ProyectoFinal_LabControl
Desarrollo del proyecto final de Laboratorio de Control Automático.

## Parámetros de la planta

A continuación se describen los parámetros del convertidor, en base a los criterios de diseño adoptados.
Considerar que los componentes reales deben de ajustarse a estos parámetros, de acuerdo con la disponibilidad.

<img src="ArchivosElectro/PLECS/BOOST_circuit.png" alt="Esquemático del circuito" width="450">

Simulación en PLECS: [Boost_PLECS](ArchivosElectro/PLECS/BOOST_converter.plecs?raw=true)



| Parámetro                                                | Valor            | Descripción                          |
| :---                                                     | :---             | :---                                 |
| Entrada nominal V<sub>s</sub>                            | 5 V              | Puede tener perturbaciones.          |
| Salida nominal  V<sub>o</sub>                            | [10, 20] V       | Se establece en la interfaz.         |
| Ciclo de trabajo nominal D<sub>nom</sub>                 | [50.00, 75.00] % | Rango variable.                      |
| Ciclo de trabajo (V<sub>s</sub> = 3 V) D<sub>8V</sub>    | [70.00, 85.00] % | Perturbación inferior.               |
| Ciclo de trabajo (V<sub>s</sub> = 7 V) D<sub>12V</sub>   | [30.00, 65.00] % | Perturbación superior.               |
| Carga R<sub>L</sub>                                      | 100 Ω            | Basada en _trade-offs_.              |
| Potencia de salida (V<sub>o</sub> = 20 V) P<sub>o</sub>  | 4 W              | De acuerdo con la carga.             |
| Frecuencia de conmutación f<sub>sw</sub>                 | 80 kHz           | Basada en _trade-offs_.              |
| Inductancia mínima L<sub>min</sub>                       | 78.125 µH        | Inductancia para corriente continua. |
| Capacitor mínimo (ΔV<sub>o</sub> = 0.1 V) C<sub>min</sub>| 18.75 µF         | Capacitancia de acuerdo al rizado.   |

## Comportamiento de la señal PWM dada por el arduino
El Arduino UNO o Arduino Mega, tiene un reloj base de 16 MHz. Al utilizar una frecuencia de conmutación de 80 kHz
el TOP (valor máximo de cuenta) en la generación de la señal PWM es:

$TOP = \frac{16\text{ MHz}}{80\text{ kHz}} = 200$

Con lo cual se obtiene una resolución para el ciclo de trabajo (D) de:

$resolution = \frac{100}{200} = 0.5$

Entonces, los valores de ciclo de trabajo que puede entregar el Arduino bajo esta configuración son:

$D = 0.5 \cdot n$

$con~n \in [0, 200]$

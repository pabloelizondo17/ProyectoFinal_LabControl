# Boost: Arduino Mega 2560 + MATLAB R2025b

Version independiente para Mega 2560 (ATmega2560, 16 MHz). No usar en Uno, Mega
1280 u otra placa sin adaptar y verificar. No requiere Simulink; MATLAB compila
y carga la biblioteca mediante MATLAB Support Package for Arduino Hardware.

## Cambios respecto al Uno

- PWM nominal de 80 kHz conservado en **D9**, ahora mediante Timer2/OC2B (PH6).
- Medicion conservada en **A0**. Timer0 no se modifica.
- Captura predeterminada: **100 ms, 400 muestras, Ts=250 us**.
- Capacidad configurada: **800 muestras** (hasta 200 ms con Ts=250 us).
- Limite adicional de ventana: 240 ms, por formato de marcas temporales.
- Dos buffers de 800 uint16: 3200 bytes, de los 8192 bytes SRAM de la placa.
  El resto debe alojar servidor, pila y otras variables; revisar reporte al compilar.
- Quitada la asignacion a la propiedad inexistente `Pins`.
- Paquete `BoostMega/BoostDAQMega` y funciones con sufijo `_mega` para evitar
  conflictos con la biblioteca anterior.
- Descarga de muestras en bloques sin solapamiento y direccion de 16 bits.

## Conexiones

| Funcion | Pin Mega |
|---|---|
| PWM hacia la entrada del driver existente | D9 |
| Punto medio del divisor de salida | A0 |
| Referencia comun del montaje | GND |

El divisor sigue configurado como 1 Mohm arriba / 250 kohm abajo: Vo=5*VA0.
Ajustar `Vref_V` a AVcc medido. La conversion es nominal; no reutiliza automaticamente
calibraciones del Uno. El Mega no resuelve la elevada impedancia del divisor:
validar la medicion y su ancho de banda contra el osciloscopio.
Timer2, ADC y D9 son exclusivos de esta biblioteca. No usar tone(), PWM en D10,
writePWMDutyCycle ni otras bibliotecas que reconfiguren Timer2/ADC durante el ensayo.

## 1. Instalacion y prueba sin etapa de potencia

Extraer el ZIP. Abrir `boost_mega_80kHz` como Current Folder en MATLAB. Con D9
separado de la entrada del driver, cerrar conexiones previas y ejecutar:

```matlab
clear a b
[a,b] = conectar_boost_mega("COM5",true); % Puerto del Mega; puede ser distinto
prueba_pwm_boost_mega(b)
```

`true` obliga a compilar y cargar la version del Mega. La lectura A0 del Uno o
su prueba previa no validan este firmware nuevo. Verificar en D9 periodo 12.5 us
(80 kHz), y duties 50, 62.5 y 75 %. Cada nivel permanece 4 s. La prueba tiene
apagado automatico adicional a los 5 s; no verifica sobretension.
No cambiar nombres ni estructura de las carpetas que empiezan por `+`.
En conexiones posteriores, sin modificar C++, se puede usar `false`.

## 2. Captura de 100 ms

Terminada y verificada la prueba, conectar el driver y la medicion del boost.
La carga de 100 ohm debe permanecer conectada. Ejecutar:

```matlab
datos = experimento_multinivel_boost_mega(b);
```

| Duty (%) | Muestras | Duracion (ms) |
|---|---:|---:|
| 50 | 67 | 16.75 |
| 60 | 67 | 16.75 |
| 75 | 66 | 16.50 |
| 55 | 67 | 16.75 |
| 70 | 67 | 16.75 |
| 50 | 66 | 16.50 |
| Total | 400 | 100.00 |

La pequena diferencia entre duraciones permite sumar exactamente 400 muestras.
El ultimo instante nominal muestreado es 99.75 ms; el ultimo duty se mantiene
hasta el final del periodo de esa muestra. Rampa inicial y espera de 0.5 s quedan
fuera de esos 100 ms. El PWM se apaga antes de transferir los datos a MATLAB.
Se conserva el formato de `datos.tabla` usado en el archivo anterior, sin promedio.
La captura guarda lectura ADC y tiempo observado por muestra, perfil y diagnosticos.

```matlab
datos.estado        % 0: completa; 1: corte ADC; 2: atraso temporal
height(datos.tabla) % Esperado: 400, si no hubo aborto
datos.maxAtraso_us
```

Resultados en `Resultados_experimentos/multinivel_boost_mega_FECHA_HORA.mat`.
El programa tambien guarda datos parciales si hubo corte ADC o atraso.

## Personalizar

En `experimento_multinivel_boost_mega.m`, seccion CONFIGURACION, o pasando `cfg`:

```matlab
% 200 ms y 800 muestras, mismo muestreo:
cfg = struct;
cfg.nivelesDuty_pct = [50 60 75 55 70 50];
cfg.Ts_s = 250e-6;
cfg.duraciones_s = [134 134 132 134 134 132]*cfg.Ts_s;
datos = experimento_multinivel_boost_mega(b,cfg);
```

No recompilar al cambiar el perfil dentro de los limites. Se admiten 1–8 tramos,
50–75 % de duty, 250–2000 us entre muestras, maximo 800 muestras y 240 ms por
captura. El programa da error antes de aplicar el perfil si no cabe; no modifica
silenciosamente Ts. Mayor memoria permite registros mas largos, no un ADC mas rapido.

## Temporizacion y limites

Timer2 Fast PWM modo 7, OCR2A=199, prescaler=1; OCR2B=n-1 para duty n/200.
A0 usa referencia AVcc y ADC a 125 kHz. Las marcas micros() tienen resolucion de
4 us y se guardan antes de iniciar la conversion, no en el instante exacto del
sample/hold. Los cambios de duty toman efecto en el siguiente BOTTOM de Timer2.

Se mantiene el criterio de aborto por atraso > Ts/4 y el umbral propuesto de
21 V, configurable mediante Vo_max_V. Este corte depende de una medicion correcta
y no limita los picos entre muestras. PWM apagado no significa salida a 0 V en
un boost. La captura bloquea el comando mientras se ejecuta: Ctrl+C no es un
paro inmediato de la placa; el registro es acotado y termina con PWM apagado.
Mantener las protecciones del montaje ante fallos de software o desconexion.

## Verificacion de esta entrega

Prueba C++ con simulacion del entorno: inicializacion, duties, capturas de 400 y
800 muestras, lectura de todos los bloques (incluidos indices >255), rechazo de
perfiles demasiado grandes y corte ADC con D9 apagado. Pasaron estas pruebas.
No se ejecuto MATLAB ni se compilo con el servidor AVR real del paquete de soporte;
no hubo prueba fisica del Mega. La primera compilacion/carga y comprobacion del
osciloscopio siguen pendientes. Compartir cualquier error completo.

## Referencias de hardware y API

- https://docs.arduino.cc/static/edb006e0a180e80b9ea9cf8b4859dcd4/A000067-full-pinout.pdf
- https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/ATmega640-1280-1281-2560-2561-Datasheet-DS40002211A.pdf
- https://www.mathworks.com/help/matlab/supportpkg/arduino.html
- https://www.mathworks.com/help/releases/R2025b/matlab/supportpkg/matlab-add-on-class.html

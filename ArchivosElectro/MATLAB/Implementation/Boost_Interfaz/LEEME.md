# Interfaz Python para Boost LQR — MATLAB R2026a

Incluye referencia ajustable, límites configurables, indicador de conexión, última referencia aceptada, gráficas de VA0 y duty y exportación CSV del búfer visible/reciente. No sustituye al controlador: LQR y PWM siguen ejecutándose en el Mega. No abre el puerto serie.

## 1. Instalar en la misma computadora que MATLAB

Extraiga todo el ZIP en una carpeta. Use Python compatible con MATLAB R2026a (consulte la tabla oficial indicada al final). En una terminal ubicada en esa carpeta:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

En Ubuntu/Debian, si falta Tkinter o venv, instale los paquetes de su versión de Python (`python3-tk`, `python3-venv`). MATLAB debe estar instalado; MATLAB Runtime no basta. Si el instalador no encuentra MATLAB, agregue su carpeta bin al PATH antes de instalar. En la máquina del registro compartido:

```bash
export PATH="/home/pablo_elizondo17/MATLAB/R2026a/bin:$PATH"
```

requirements.txt fija matlabengine 26.1.12 para R2026a. No instale automáticamente la última versión, porque puede corresponder a R2026b.

## 2. Preparar las señales en el modelo principal

Detenga Monitor & Tune. Mantenga el controlador como Model Reference; no cambie sus ganancias ni su tiempo de muestreo. En Boost_LQR_implementation, nombre estas dos líneas (doble clic sobre el cable):

| Nombre exacto | Lugar del cable | Unidad |
|---|---|---|
| VA0_GUI | Salida de la ganancia 5/1024, antes de restar el punto de operación | Voltios de A0 |
| DUTY_GUI | Salida de Saturation, antes de la ganancia 255/100 | Porcentaje de duty |

No use Delta_Duty para la gráfica: se requiere el duty total después de sumar DutyRef y saturar. La gráfica refleja el comando y no mide físicamente el PWM. VA0 es el voltaje del divisor, no el voltaje de salida del Boost. Para el divisor 0.2, Vo estimado = VA0/0.2.

Si cambió a duty normalizado 0–1, ponga `duty_scale_to_percent: 100.0` en config.json. Con el esquema 50 + Delta_Duty y ganancia 255/100, deje 1.0. Esta opción solo afecta la gráfica; no cambia las unidades del controlador.

En MATLAB, seleccione como Current Folder la carpeta extraída (o agréguela al path) y ejecute:

```matlab
boost_prepare
```

El script localiza esas líneas solo en el nivel principal, activa Log Signals y configura los callbacks Data Access de R2026a. Estos callbacks se ejecutan en MATLAB, no en Arduino: NO introduzca los .m en bloques MATLAB Function. No active Measure task execution time ni Measure function execution times; son opciones distintas y no se necesitan.

Guarde el modelo. Inicie Monitor & Tune y espere a que se conecte al Arduino. La primera vez puede recompilar por el registro de señales. Luego, en la terminal del entorno Python:

```bash
python boost_gui.py
```

Pulse **Conectar MATLAB**. Escriba la referencia y pulse **Aplicar referencia**. Conectar no cambia la referencia; solo el botón Aplicar la envía. Se acepta coma o punto decimal.

## 3. Configuración

Edite config.json antes de iniciar la interfaz:

- `session`: nombre de la sesión MATLAB compartida. boost_prepare usa BoostGUI. Si MATLAB ya estaba compartido con otro nombre, el script lo imprime; copie ese nombre aquí.
- `model`: nombre exacto del modelo principal.
- `reference_block`: ruta exacta al Constant de referencia, en voltios de salida, ANTES de la ganancia 0.2. Seleccione ese bloque en Simulink y ejecute `gcb` para ver su ruta. El nombre del bloque puede diferir de su etiqueta.
- `vmin`, `vmax`: límites permitidos. Se entregan 10 y 20 V basados en el rango solicitado; ajuste al rango que haya validado físicamente. Se comprueban tanto en Python como en MATLAB. No constituyen protección de sobretensión.
- `poll_seconds`: 0.5 s por defecto. Afecta la actualización gráfica, no el muestreo del LQR ni los 80 kHz del PWM.
- `plot_seconds`: ventana de la gráfica, 30 s por defecto.

No se modifican DutyRef, la ganancia 0.2 ni el punto de operación al aplicar una nueva referencia. El mensaje "aceptada" significa que set_param terminó sin error; no garantiza que el voltaje físico ya haya alcanzado el objetivo.

## 4. Telemetría, carga y límites

Los datos llegan por lotes desde Monitor & Tune al callback boost_capture. Python vacía el búfer mediante MATLAB Engine. Cada señal tiene sus propios tiempos; no se inventa una sincronización entre ellas. Si pasan más de 3 s sin muestras se marca el dato como antiguo. Cada búfer conserva hasta 20 000 muestras por señal; el de MATLAB informa las muestras descartadas por desbordamiento. La gráfica reduce puntos para dibujar, y el CSV contiene las muestras que aún estén en el búfer Python (no todo el historial de una sesión ilimitada).

Si registra a varios kHz, limite/decime las señales de monitoreo desde sus propiedades de logging según lo que necesite observar. No cambie Ts del controlador para aligerar la interfaz. Estas gráficas sirven para supervisión; no son un osciloscopio de los pulsos de 80 kHz. Para analizar transitorios rápidos, conserve también las capturas de Simulink con un ajuste adecuado de registro.

Cerrar Python no detiene Monitor & Tune, no modifica la referencia y no desconecta el PWM. Detenga el sistema desde su procedimiento de operación habitual. No se incluye un botón de parada de emergencia por software.

## 5. Si no aparecen curvas

1. Verifique que VA0_GUI y DUTY_GUI se vean y actualicen en Simulation Data Inspector durante Monitor & Tune.
2. Ambas deben estar en el modelo principal, no dentro del Model Reference (Data Access no soporta señales internas de modelos referenciados).
3. Revise Diagnostic Viewer por advertencias de boost_capture y ejecute `which boost_capture` en MATLAB. La carpeta extraída debe seguir en el path.
4. Detenga Monitor & Tune, ejecute boost_prepare de nuevo, guarde y reinicie Monitor & Tune. No llame boost_prepare durante la ejecución.
5. Si SDI actualiza pero Python no recibe nada, comparta las advertencias del callback: la integración Data Access con su configuración de External Mode necesita comprobarse en el equipo. No se usa logsout al terminar ni se muestran muestras simuladas como mediciones reales.

El paquete no ha sido probado conectado a su Mega ni con su instalación MATLAB. Se ha revisado la sintaxis Python y la validación de referencias; la prueba completa requiere ejecutar estos pasos en su equipo. Conserve la configuración funcional de Monitor & Tune.

## Archivos

- boost_gui.py: interfaz Tkinter/Matplotlib y comunicación en hilo separado.
- boost_prepare.m: prepara las dos señales y comparte MATLAB.
- boost_capture.m: recibe lotes de datos en MATLAB.
- boost_read.m: entrega los lotes pendientes a Python.
- boost_set_reference.m: valida y aplica la referencia.
- config.json y requirements.txt: configuración y dependencias.

## Documentación oficial

- https://www.mathworks.com/help/matlab/matlab_external/connect-python-to-running-matlab-session.html
- https://github.com/mathworks/matlab-engine-for-python/blob/R2026a/README.md
- https://www.mathworks.com/support/requirements/python-compatibility.html
- https://www.mathworks.com/help/simulink/slref/simulink.sdi.setdataaccess.html
- https://www.mathworks.com/help/simulink/ug/create-custom-visualizations-during-simulation.html

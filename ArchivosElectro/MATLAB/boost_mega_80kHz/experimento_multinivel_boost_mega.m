function datos = experimento_multinivel_boost_mega(b,cfg)
%EXPERIMENTO_MULTINIVEL_BOOST Ensayo abierto duty -> voltaje de salida.
% Basado en la organizacion del ensayo TCLab, con temporizacion en placa.
% Cada llamada realiza UNA captura, sin promedio ni interpolacion.
% Parametros editables: ver CONFIGURACION abajo o pasar estructura cfg.
%
% [a,b] = conectar_boost_mega("COM5",true); % primera instalacion, sin potencia
% prueba_pwm_boost_mega(b);
% Tras verificar PWM y medicion: datos = experimento_multinivel_boost_mega(b);
%
% Ejemplo de personalizacion (debe caber en 800 muestras):
% cfg.nivelesDuty_pct = [50 75 50];
% cfg.duraciones_s = [8 8 8]*1e-3;
% cfg.Ts_s = 250e-6;
% datos = experimento_multinivel_boost_mega(b,cfg);

if nargin<2, cfg=struct; end
%% CONFIGURACION: valores iniciales propuestos, no identificados experimentalmente.
def.nivelesDuty_pct=[50 60 75 55 70 50];
def.duraciones_s=[67 67 66 67 67 66]*250e-6; % Suma exactamente 100 ms
def.Ts_s=250e-6;             % 4 kS/s; verificar intervalos medidos
% 400 muestras por defecto; limite de memoria configurado: 800 muestras.
def.t_asentar_s=0.5;        % Espera al duty inicial despues de rampa de arranque
def.Rsuperior_ohm=1e6;
def.Rinferior_ohm=250e3;
def.Vref_V=5.0;             % Sustituir por AVcc medido; no es referencia del PI
% Limite propuesto de ensayo: ajustar a limites comprobados del montaje.
def.Vo_max_V=21.0;
def.carpetaResultados=fullfile(pwd,'Resultados_experimentos');
nombres=fieldnames(cfg);
for j=1:numel(nombres)
    assert(isfield(def,nombres{j}),'Parametro desconocido: %s',nombres{j});
    def.(nombres{j})=cfg.(nombres{j});
end
cfg=def;
validateattributes(cfg.nivelesDuty_pct,{'numeric'},{'vector','finite','real','>=',50,'<=',75});
validateattributes(cfg.duraciones_s,{'numeric'},{'vector','finite','real','positive'});
validateattributes(cfg.Ts_s,{'numeric'},{'scalar','finite','real','positive'});
validateattributes(cfg.t_asentar_s,{'numeric'},{'scalar','finite','real','>=',0,'<=',2});
validateattributes(cfg.Rsuperior_ohm,{'numeric'},{'scalar','finite','real','positive'});
validateattributes(cfg.Rinferior_ohm,{'numeric'},{'scalar','finite','real','positive'});
validateattributes(cfg.Vref_V,{'numeric'},{'scalar','finite','real','positive'});
validateattributes(cfg.Vo_max_V,{'numeric'},{'scalar','finite','real','positive'});
assert(numel(cfg.nivelesDuty_pct)==numel(cfg.duraciones_s),'Un tiempo por nivel.');
Ts_us=round(cfg.Ts_s*1e6);
assert(abs(Ts_us*1e-6-cfg.Ts_s)<1e-12,'Ts debe ser un numero entero de microsegundos.');
ns=round(cfg.duraciones_s/cfg.Ts_s);
assert(all(ns>=1) && sum(ns)<=800,'La captura debe tener de 1 a 800 muestras.');
assert(numel(ns)<=8 && sum(ns)*Ts_us<=240000,'Maximo 8 tramos y 240 ms.');
assert(Ts_us>=250 && Ts_us<=2000,'Ts debe estar entre 250 y 2000 us.');
H=cfg.Rinferior_ohm/(cfg.Rsuperior_ohm+cfg.Rinferior_ohm);
% ADC ideal: cuenta ~ Vin/Vref * 1024. Usar floor para corte conservador.
cut=floor(cfg.Vo_max_V*H/cfg.Vref_V*1024);
assert(cut>=1 && cut<=1022,'Limite de voltaje fuera del rango medible del ADC.');
duty=round(cfg.nivelesDuty_pct*2)/2;
perfil=table(duty(:),ns(:)*cfg.Ts_s,ns(:), ...
    'VariableNames',{'Duty_pct','Duracion_s','Muestras'});
if ~isfolder(cfg.carpetaResultados), mkdir(cfg.carpetaResultados); end
marca=char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'));
ruta=fullfile(cfg.carpetaResultados,['multinivel_boost_mega_' marca '.mat']);
assert(~isfile(ruta),'Ya existe el archivo de resultados.');
proteccion=onCleanup(@() apagar(b)); %#ok<NASGU>
fprintf('Ensayo abierto: duty -> Vo. Una captura, sin promedio.\n');
fprintf('PWM nominal 80 kHz; Ts solicitado %.0f us; N=%d; ventana %.2f ms.\n', ...
    Ts_us,sum(ns),sum(ns)*cfg.Ts_s*1e3);
disp(perfil);
%% Ejecucion local: rampa, espera, captura, apagado y descarga.
r=b.capture(duty,ns,Ts_us,cut,round(1000*cfg.t_asentar_s));
b.off();
Vo=r.adc*(cfg.Vref_V/1024)/H;  % Conversion nominal; no usa calibraciones anteriores
VA0=r.adc*(cfg.Vref_V/1024);
tabla=table(r.t,r.duty_pct,r.adc,VA0,Vo, ...
    'VariableNames',{'Tiempo_s','Duty_pct','ADC','VA0_V','Vo_V'});
datos=struct('tabla',tabla,'configuracion',cfg,'perfil',perfil, ...
    'estado',r.status,'maxAtraso_us',r.maxLate_us, ...
    'tiemposEscrituraDuty_s',r.changeWrite_s,'archivo',ruta, ...
    'fecha',datetime('now'),'PWM_nominal_Hz',80000, ...
    'placa','Mega2560','biblioteca','BoostMega/BoostDAQMega','capacidad_muestras',800, ...
    'notaTiempo','Tiempo micros() antes de iniciar conversion ADC; resolucion 4 us, no instante exacto de sample/hold.', ...
    'notaEntrada','Duty ordenado; actualizacion de OCR2B en proximo BOTTOM, desfase hasta un periodo PWM.', ...
    'notaSensor','Conversion nominal. No confirma ancho de banda ni precision del divisor.');
save(ruta,'datos'); % Guardar tambien datos parciales si hubo corte o atraso.
fprintf('Guardado: %s\n',ruta);
if height(tabla)>1
    dt=diff(tabla.Tiempo_s)*1e6;
    fprintf('Intervalo observado: min %.0f, mediana %.0f, max %.0f us.\n',min(dt),median(dt),max(dt));
end
if r.status==1
    warning('Boost:Corte','Se apago D9 por umbral ADC; revisar salida antes de repetir.');
elseif r.status==2
    warning('Boost:Tiempo','Captura abortada por atraso > Ts/4; no usarla como registro uniforme.');
end
if isempty(r.t)
    warning('Boost:SinDatos','Corte durante rampa/espera: archivo guardado sin muestras.');
    return
end
figure('Name','Boost: ensayo multinivel');
tiledlayout(3,1);
nexttile; stairs(r.t*1e3,r.duty_pct,'LineWidth',1.2); grid on;
ylabel('Duty (%)'); ylim([45 80]); title('Entrada ordenada');
nexttile; plot(r.t*1e3,Vo,'.-'); grid on;
ylabel('Vo (V)'); title('Salida: muestras individuales, sin promedio');
nexttile; plot(r.t(2:end)*1e3,diff(r.t)*1e6,'.-'); grid on;
yline(Ts_us,'--'); ylabel('Intervalo (us)'); xlabel('Tiempo (ms)');
end
function apagar(b)
try, b.off(); catch ME, warning('Boost:Apagado','Apagado no confirmado: %s',ME.message); end
end

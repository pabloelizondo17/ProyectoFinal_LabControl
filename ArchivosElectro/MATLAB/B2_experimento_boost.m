function datos = B2_experimento_boost(puerto, tipo, n0, dn, Vs_real)
% B2_EXPERIMENTO_BOOST  Ensayo escalón o multinivel sobre el boost real.
%
%   datosEscalon    = B2_experimento_boost("COM8", "escalon",    100, 10);  % 50 % -> 55 %
%   datosMultinivel = B2_experimento_boost("COM8", "multinivel", 100, 10);  % 50 % +- 5 %
%
%   n0 : cuentas PWM del punto de operación (D0 = n0/200)
%   dn : amplitud del cambio en cuentas (10 cuentas = 5 % de D)
%   Vs_real : tensión de entrada medida [V] (opcional, por defecto p.Vs)
%
% Cada ensayo se repite R veces (sin enfriamiento, a diferencia de la TCLab) y se
% promedia. Se guarda un .mat nuevo en ./datos con fecha y hora. No sobrescribe.
%
% Alineación: u(k) = n(k)/200 se aplica justo DESPUÉS de leer y(k); el modelo
% continuo ve u(k) constante en [t_k, t_k+1) con t_k = (k-1)*Ts.

if nargin < 5, Vs_real = []; end
parametros_boost;
if isempty(Vs_real), Vs_real = p.Vs; end
tipo = lower(string(tipo));

%% Configuración del ensayo (puntos de partida)
Trec          = 60e-3;    % duración del registro [s]
R             = 10;       % repeticiones
frac_pre      = 0.15;     % fracción del registro antes del escalón
t_reposo      = 0.5;      % pausa entre repeticiones [s]
t_asentar     = 1.0;      % espera tras llegar a n0 [s]
Ts_aviso      = 150e-6;   % por encima de esto la resonancia (~800 Hz) queda mal muestreada
Vo_max_seguro = 21;       % [V]
Vref          = 5.0;      % [V] referencia del ADC

%% Calibración del sensor (si existe)
if isfile('calibracion_boost.mat')
    cal = load('calibracion_boost.mat');  a = cal.a;  b = cal.b;
else
    warning('No hay calibracion_boost.mat: se usa la ganancia nominal H del archivo de parámetros.');
    a = (Vref/1023)/p.H;  b = 0;
end

%% Conexión (PWM apagado)
[s, info] = boost_io('abrir', puerto);
limpiar = onCleanup(@() apagar(s));

%% Muestreo
Tpwm = 1/p.fsw;
div  = max(4, ceil(Trec/(info.Nmax*Tpwm)));
Ts   = div*Tpwm;
N    = min(info.Nmax, floor(Trec/Ts));
fprintf('Ts = %.1f us (%.1f kS/s), N = %d muestras, registro = %.1f ms\n', ...
        1e6*Ts, 1e-3/Ts, N, 1e3*N*Ts);
if Ts > Ts_aviso
    warning(['Ts = %.0f us es grande para ver la resonancia. Reduzca Trec o use un Mega ' ...
             '(más RAM).'], 1e6*Ts);
end

%% Secuencia de entrada (tramos)
switch tipo
    case "escalon"
        lv   = [0 1];
        npre = round(frac_pre*N);
        dur  = [npre, N-npre];
    case "multinivel"
        K       = min(info.Kmax, 12);
        patron  = [0 1 -1 0.5 -0.5 1 0 -1 0.5 -0.5 0 1];
        lv      = patron(1:K);
        dur     = floor(N/K)*ones(1,K);
        dur(end) = N - sum(dur(1:end-1));
    otherwise
        error('tipo debe ser "escalon" o "multinivel".');
end
nv = round(n0 + dn*lv);

%% Seguridad
if any(nv < 1) || any(nv > info.Dmax)
    error('Niveles %s fuera de [1, %d].', mat2str(nv), info.Dmax);
end
Vo_pico = Vs_real/(1 - max(nv)/p.TOP);
fprintf('Niveles (cuentas): %s  -> Vo esperado hasta %.1f V\n', mat2str(nv), Vo_pico);
if Vo_pico > Vo_max_seguro
    error('Vo esperado %.1f V supera el límite de %g V.', Vo_pico, Vo_max_seguro);
end

%% Llevar a n0 con rampa y esperar régimen permanente
adc0 = boost_io('set', s, nv(1));
pause(t_asentar);
adc1 = boost_io('set', s, nv(1));
fprintf('Régimen permanente: Vo = %.3f V (deriva entre lecturas: %.1f mV)\n', ...
        a*adc1 + b, 1e3*abs(a*(adc1 - adc0)));

%% Repeticiones
Y = zeros(N, R);
for r = 1:R
    [yr, ab] = boost_io('run', s, div, N, dur, nv);
    if ab || numel(yr) ~= N
        error('Ensayo %d abortado por sobretensión o trama incompleta.', r);
    end
    Y(:, r) = yr;
    fprintf('  repetición %d/%d  Vo(inicio) = %.3f V\n', r, R, a*mean(yr(1:max(2,dur(1)))) + b);
    pause(t_reposo);
end
boost_io('off', s);

%% Armado de resultados
ncnt = repelem(nv(:), dur(:));                 % n aplicado tras cada muestra
datos.tipo    = char(tipo);
datos.fecha   = char(datetime('now'));
datos.puerto  = char(puerto);
datos.n0      = n0;   datos.dn = dn;
datos.nv      = nv;   datos.dur = dur;   datos.npre = dur(1);
datos.div     = div;  datos.Ts = Ts;     datos.N = N;   datos.R = R;
datos.t       = (0:N-1)' * Ts;
datos.ncnt    = ncnt;
datos.d       = ncnt/p.TOP;                    % ciclo de trabajo en p.u.
datos.Y_adc   = Y;
datos.Y_vo    = a*Y + b;
datos.vo      = mean(datos.Y_vo, 2);
datos.vo_std  = std(datos.Y_vo, 0, 2);
datos.a = a;  datos.b = b;  datos.Vs_real = Vs_real;

if ~exist('datos_exp','dir'), mkdir('datos_exp'); end
marca = char(datetime('now','Format','yyyyMMdd_HHmm'));
datos.archivo = fullfile('datos_exp', sprintf('%s_boost_%s.mat', tipo, marca));
save(datos.archivo, 'datos');
fprintf('Guardado: %s\n', datos.archivo);

%% Gráfica
figure('Name', ['B2 - ' char(tipo)]);
subplot(2,1,1);
stairs(1e3*datos.t, 100*datos.d, 'LineWidth', 1.3); grid on;
ylabel('D [%]'); title(['Entrada: ' char(tipo)]);
subplot(2,1,2);
plot(1e3*datos.t, datos.Y_vo, 'Color', [0.8 0.8 0.8]); hold on;
plot(1e3*datos.t, datos.vo, 'b', 'LineWidth', 1.3); grid on;
ylabel('v_o [V]'); xlabel('t [ms]'); title(sprintf('Salida (%d repeticiones y promedio)', R));
guardar_figura(gcf, ['B2_' char(tipo)]);

end

function apagar(s)
    try, boost_io('off', s); catch, end
end

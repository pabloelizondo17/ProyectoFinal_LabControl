%B1 Verificación previa del boost real y calibración del sensor
% (equivale a la Sección 6 de la guía de la TCLab)
%
% Antes de correr este script, con el osciloscopio:
%   1) Compuerta del MOSFET: confirmar f = 80 kHz.
%   2) Con S n (se hace abajo) confirmar duty = n/200 (p. ej. n = 100 -> 50 %).
%   3) Carga RL conectada SIEMPRE. Nunca energizar sin carga.
%
% Resultado: calibracion_boost.mat con vo = a*ADC + b  (ADC en cuentas, vo en V)

clear; clc; close all;
parametros_boost;

%% Configuración (ajustar)
puerto  = "COM5";                 % Linux: "/dev/ttyACM0"
Vs_real = 5.0;                    % [V] medir con el multímetro
Vref    = 5.0;                    % [V] referencia del ADC (AVcc), medir en el pin 5V
n_lista = [0 60 100 125 150];     % cuentas PWM para calibrar (D = n/200)
Vo_max_seguro = 21;               % [V]

%% Chequeo de seguridad antes de energizar
Vo_est = Vs_real ./ (1 - n_lista/p.TOP);
fprintf('Vo ideal esperado: %s V\n', mat2str(round(Vo_est,2)));
if any(Vo_est(2:end) > Vo_max_seguro)
    error('Algun punto supera %g V con Vs = %g V. Reduzca n_lista.', Vo_max_seguro, Vs_real);
end

%% Conexión
[s, info] = boost_io('abrir', puerto);
limpiar = onCleanup(@() apagar(s));
fprintf('Arduino OK: N_MAX = %d muestras, K_MAX = %d tramos, D_MAX = %d cuentas\n', ...
        info.Nmax, info.Kmax, info.Dmax);

%% Barrido de calibración
adc = zeros(size(n_lista));  vo_meas = zeros(size(n_lista));
for i = 1:numel(n_lista)
    adc(i) = boost_io('set', s, n_lista(i));
    fprintf('n = %3d (D = %5.1f %%)  ADC medio = %7.2f\n', n_lista(i), 100*n_lista(i)/p.TOP, adc(i));
    vo_meas(i) = input('   Vo medido con el multímetro [V]: ');
end
boost_io('off', s);

%% Ajuste lineal vo = a*ADC + b
cf = polyfit(adc, vo_meas, 1);
a = cf(1);  b = cf(2);
a_nom = (Vref/1023) / p.H;
res = vo_meas - polyval(cf, adc);
H_efectivo = (Vref/1023) / a;
fprintf('\nCalibración: vo = %.5f*ADC + %.4f\n', a, b);
fprintf('  nominal:   a = %.5f V/cuenta (H = %.4f)\n', a_nom, p.H);
fprintf('  efectiva:  H = %.4f  (error vs nominal: %.2f %%)\n', H_efectivo, 100*(H_efectivo/p.H - 1));
fprintf('  residuo máximo del ajuste: %.3f V\n', max(abs(res)));
fprintf('  resolución en Vo: %.1f mV por cuenta del ADC\n', 1e3*a);

%% Comparación con el modelo ideal
Vo_ideal = Vs_real ./ (1 - n_lista/p.TOP);
figure('Name','B1 - Calibración');
subplot(1,2,1);
plot(adc, vo_meas, 'o', adc, polyval(cf, adc), '-'); grid on;
xlabel('ADC [cuentas]'); ylabel('V_o multímetro [V]'); title('Calibración del sensor');
subplot(1,2,2);
plot(100*n_lista/p.TOP, Vo_ideal, 'o-', 100*n_lista/p.TOP, vo_meas, 's-'); grid on;
xlabel('D [%]'); ylabel('V_o [V]'); legend('ideal','medido','Location','northwest');
title('Estático: ideal vs real');
guardar_figura(gcf, 'B1_calibracion');

save('calibracion_boost.mat', 'a', 'b', 'Vref', 'Vs_real', 'n_lista', 'adc', 'vo_meas');
disp('Guardado calibracion_boost.mat');

%% Lista de comprobación (llenar a mano)
%  [ ] PWM 80 kHz y duty = n/200 verificados en el osciloscopio
%  [ ] Lectura del ADC coherente con el multímetro (residuo < ~50 mV)
%  [ ] Vo estable en cada punto, sin oscilaciones persistentes ni ruido excesivo
%  [ ] Impedancia del divisor (R2||R3 = 200 kOhm) no distorsiona la lectura: si el ADC
%      "arrastra" entre canales o cambia con la tasa, agregar un seguidor (op-amp).

function apagar(s)
    try, boost_io('off', s); catch, end
end

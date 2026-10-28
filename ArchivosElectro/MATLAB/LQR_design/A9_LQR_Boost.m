%% A9_LQR_Boost.m
% =========================================================================
% Diseno de un LQR discreto con accion integral (LQI) para el boost.
%
% Planta: FOPDT validado (A5/A6), entrada Duty (%) y salida VA0 (V),
% con theta = 250 us = 1 periodo de muestreo:
%
%       x[k+1]  = a*x[k] + b*u[k-1]      x = VA0 - VA0_0  (desviacion)
%
% Estados del LQR:  z = [x ; u[k-1] ; xi]
%   x      : se mide (A0)
%   u[k-1] : duty aplicado en la muestra anterior (lo conoce el controlador)
%   xi     : integral del error, xi[k+1] = xi[k] + Ts*(r[k] - y[k])
% Todos los estados son conocidos -> no hace falta observador.
%
% Ley de control:  DeltaD[k] = -Kx*x[k] - Ku*u[k-1] - Ki*xi[k]
%                  Duty[k]   = D0 + DeltaD[k]
%
% Se valida con el mismo escenario del Modelo_MIL (escalon 10 -> 12 V en
% t = 25 ms) y se compara con el PI SIMC. Requiere Control System Toolbox.
% =========================================================================
clear; clc; close all;

%% Parametros del modelo nominal validado (iguales a A7 e init_BOOT)
K     = 0.0662;      % V/%
tau   = 9.10e-04;    % s
theta = 2.5e-04;     % s
Ts    = 250e-6;      % s
D0    = 50;          % duty del punto de operacion [%]
VA0_0 = 1.87543726;  % VA0 en D0 (Constant del Modelo_MIL) [V]
H     = 0.2;         % divisor: VA0 = H*Vo

nd = round(theta/Ts);
assert(nd == 1, "El modelo de estados supone theta = 1 periodo de muestreo.");

%% Modelo discreto en variables de estado
a = exp(-Ts/tau);
b = K*(1 - a);
Ad = [a b; 0 0];          % z1 = x, z2 = u[k-1]
Bd = [0; 1];
Cd = [1 0];

% Aumento con el integrador del error
Aa = [Ad, zeros(2,1); -Ts*Cd, 1];
Ba = [Bd; 0];

%% Pesos (regla de Bryson: 1/maximo aceptable^2)
% Ajustados para que el lazo sea estable y sin sobreimpulso tanto con la
% planta del MIL (sin retardo) como con theta = 1 muestra.
x_max  = 0.2;         % V   desviacion admisible de VA0 (1 V en Vo)
u1_max = 20;          % %   no se penaliza fuerte el estado de retardo
xi_max = 1e-4;        % V*s integral del error admisible
u_max  = 5;           % %   esfuerzo DeltaD admisible

Q = diag([1/x_max^2, 1/u1_max^2, 1/xi_max^2]);
R = 1/u_max^2;

[Klqr,~,polos] = dlqr(Aa, Ba, Q, R);
Kx = Klqr(1);  Ku = Klqr(2);  Ki = Klqr(3);

fprintf('--- LQI discreto (Ts = %.0f us) ---\n', 1e6*Ts);
fprintf('Kx = %.4f %%/V,  Ku = %.4f,  Ki = %.4f %%/(V*s)\n', Kx, Ku, Ki);
fprintf('Polos en lazo cerrado |z|: '); fprintf('%.4f  ', abs(polos)); fprintf('\n');
fprintf('Constantes de tiempo equivalentes [ms]: ');
fprintf('%.3f  ', -1e3*Ts./log(abs(polos))); fprintf('\n');

%% Ganancias del PI del MIL (para comparar)
pi_data = load(fullfile('..','PI_design','PI_SIMC_Boost.mat'), 'Kp', 'Ki');
Kp_PI = pi_data.Kp;  Ki_PI = pi_data.Ki;

%% Escenarios de simulacion
% 1) El mismo del Modelo_MIL: escalon 10 -> 12 V con D0 = 50 %.
% 2) Escalon 18 -> 20 V alrededor de D = 75 %. Ahi la ganancia local, medida
%    con los niveles estacionarios de las pruebas 1 y 2, es
%       (VA0(75 %) - VA0(70 %))/5 = (3.649 - 3.096)/5 = 0.111 V/%  (~1.7*K)
%    y se usa esa ganancia en la planta. Los controladores NO se redisenan:
%    se evalua su robustez. 20 V (D ~ 78 %) queda algo por encima del rango
%    ensayado (hasta 18.2 V con D = 75 %).
esc = struct('nombre', {'10 -> 12 V', '18 -> 20 V'}, ...
    'Vini', {10, 18}, 'Vfin', {12, 20}, 'D0', {D0, 75}, ...
    'VA0_0', {VA0_0, 3.649}, 'K', {K, 0.111});

tfin = 0.05;  tstep = 0.025;
t = (0:round(tfin/Ts)).';
t = t*Ts;
k0 = find(t >= tstep, 1);

% Casos: planta sin retardo (la del MIL) y planta con theta = 1 muestra
casos = {'Planta sin retardo', 0; 'Con retardo theta', 1};
res = struct();
for e = 1:numel(esc)
    esc(e).Vref = esc(e).Vini + (esc(e).Vfin - esc(e).Vini)*(t >= tstep);
    r = H*esc(e).Vref;                 % referencia en VA0 [V]
    b_e = esc(e).K*(1 - a);
    for c = 1:size(casos,1)
        ret = casos{c,2};
        res(e,c).nombre = casos{c,1};
        res(e,c).LQR = simular(@(err,x,uant,xi) -Kx*x - Ku*uant - Ki*xi, ...
            a, b_e, ret, r, Ts, esc(e).VA0_0, esc(e).D0, "LQR");
        res(e,c).PI  = simular([Kp_PI Ki_PI], a, b_e, ret, r, Ts, ...
            esc(e).VA0_0, esc(e).D0, "PI");
    end
end

%% Metricas del ultimo escalon (mismo criterio que A8: banda 2 %)
fprintf('\n%-11s %-20s %-5s %10s %10s %10s %12s\n', 'Escalon', 'Planta', 'Ctrl', ...
    'tr [ms]', 'ts [ms]', 'Mp [%]', 'Duty [%]');
for e = 1:numel(esc)
    Vref = esc(e).Vref;
    for c = 1:size(casos,1)
        for ctrl = ["PI","LQR"]
            s = res(e,c).(ctrl);
            Vo = s.VA0/H;
            m = metricas(t(k0:end)-tstep, Vo(k0:end), Vref(k0-1), Vref(k0));
            fprintf('%-11s %-20s %-5s %10.3f %10.3f %10.2f %5.1f-%5.1f\n', esc(e).nombre, ...
                res(e,c).nombre, ctrl, 1e3*m.tr, 1e3*m.ts, m.Mp, min(s.Duty), max(s.Duty));
        end
    end
end

%% Graficas (una figura por escenario)
colPI  = [0 0.447 0.741];
colLQR = [0.850 0.325 0.098];
nc = size(casos,1);
for e = 1:numel(esc)
    if e == 1
        figure('Name','A9 - LQR vs PI','Color','w');
    else
        figure('Name',['A9 - LQR vs PI (' esc(e).nombre ')'],'Color','w');
    end
    tiledlayout(2, nc, 'TileSpacing','compact');
    for c = 1:nc
        titulo = sprintf('%s, %s', res(e,c).nombre, esc(e).nombre);
        nexttile(c); hold on;
        stairs(1e3*t, esc(e).Vref, 'k--', 'DisplayName','Referencia');
        stairs(1e3*t, res(e,c).PI.VA0/H,  'Color',colPI,  'LineWidth',1.3, 'DisplayName','PI SIMC');
        stairs(1e3*t, res(e,c).LQR.VA0/H, 'Color',colLQR, 'LineWidth',1.3, 'DisplayName','LQR (LQI)');
        grid on; ylabel('V_o [V]'); title(titulo); legend('Location','southeast');
        nexttile(c + nc); hold on;
        stairs(1e3*t, res(e,c).PI.Duty,  'Color',colPI,  'LineWidth',1.2, 'DisplayName','PI SIMC');
        stairs(1e3*t, res(e,c).LQR.Duty, 'Color',colLQR, 'LineWidth',1.2, 'DisplayName','LQR (LQI)');
        grid on; xlabel('t [ms]'); ylabel('Duty [%]'); legend('Location','southeast');
    end
end

%% Guardar ganancias para Simulink / Arduino
save('LQR_Boost.mat', 'Kx', 'Ku', 'Ki', 'Ts', 'D0', 'VA0_0', 'Q', 'R', ...
    'K', 'tau', 'theta', 'Aa', 'Ba');
fprintf('\nGanancias guardadas en LQR_Boost.mat\n');

%% Funciones locales
function s = simular(ctrl, a, b, ret, r, Ts, VA0_0, D0, tipo)
% Simula el lazo discreto. La planta es la del Modelo_MIL:
% Discrete Transfer Fcn (ZOH) + bias VA0_0. Con ret = 1 se agrega
% el retardo de una muestra entre controlador y planta.
    N = numel(r);
    x = 0; uant = 0; xi = 0; integ = 0;
    s.VA0 = zeros(N,1); s.Duty = zeros(N,1);
    for k = 1:N
        y = x + VA0_0;
        e = r(k) - y;
        if tipo == "LQR"
            u = ctrl(e, x, uant, xi);
            xi = xi + Ts*e;
        else
            % PID de Simulink, forma paralela, Forward Euler
            u = ctrl(1)*e + integ;
            integ = integ + ctrl(2)*Ts*e;
        end
        s.VA0(k) = y;  s.Duty(k) = D0 + u;
        if ret, uplanta = uant; else, uplanta = u; end
        x = a*x + b*uplanta;
        uant = u;
    end
end

function m = metricas(tt, y, yini, yfin)
    z = (y - yini)/(yfin - yini);
    k10 = find(z >= 0.1, 1);  k90 = find(z >= 0.9, 1);
    m.tr = tt(k90) - tt(k10);
    fuera = find(abs(y - yfin) > 0.02*abs(yfin - yini), 1, 'last');
    if isempty(fuera), m.ts = 0; else, m.ts = tt(min(fuera+1, end)); end
    m.Mp = max(0, 100*(max(z) - 1));
end

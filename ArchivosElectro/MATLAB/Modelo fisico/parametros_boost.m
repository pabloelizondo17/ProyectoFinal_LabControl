%% parametros_boost.m
% -------------------------------------------------------------------------
% Parámetros del convertidor boost (planta) y de la retroalimentación.
% Este archivo lo llaman A1 y A2 para que TODOS usen exactamente los
% mismos valores. Si cambian un componente, cámbienlo solo aquí.
%
% Valores tomados de la simulación PLECS del repositorio
% (ArchivosElectro/PLECS/BOOST_converter.plecs) y del README.
% Modelo IDEAL: MOSFET con Ron = 0, diodo con Vf = 0 y Ron = 0,
% inductor sin resistencia serie y capacitor sin ESR (igual que el PLECS).
% -------------------------------------------------------------------------

% --- Fuente de entrada ---------------------------------------------------
p.Vs   = 5;          % Tensión de entrada nominal [V]

% --- Elementos almacenadores de energía ---------------------------------
p.L    = 200e-6;     % Inductancia [H]   (PLECS: 200 uH; L_min = 78,125 uH)
p.C    = 47e-6;      % Capacitancia [F]  (PLECS: 47 uF;  C_min = 18,75 uF)

% --- Carga y divisor de retroalimentación ---------------------------------
p.RL   = 100;        % Resistencia de carga [ohm]
p.R2   = 1e6;        % Resistencia superior del divisor [ohm]
p.R3   = 250e3;      % Resistencia inferior del divisor [ohm]

% El divisor está en paralelo con la carga, así que la carga que "ve" el
% capacitor es RL || (R2 + R3). El efecto es muy pequeño (0,008 %), pero
% se incluye para que el modelo sea exactamente el circuito simulado.
p.Req  = p.RL*(p.R2 + p.R3)/(p.RL + p.R2 + p.R3);   % [ohm]

% Ganancia del sensor (retroalimentación NO unitaria):
%   y = H * vo   ->  a 20 V de salida el Arduino ve 4 V (< 5 V del ADC)
p.H    = p.R3/(p.R2 + p.R3);                          % [V/V] = 0,2

% --- Conmutación (Arduino Mega, Timer a 16 MHz) ---------------------------
p.fclk = 16e6;       % Reloj del timer [Hz]
p.fsw  = 80e3;       % Frecuencia de conmutación [Hz]
p.TOP  = p.fclk/p.fsw;  % Cuentas por periodo = 200 -> resolución 0,5 %

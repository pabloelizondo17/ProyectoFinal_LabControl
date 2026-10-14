%Parámetros del convertidor boost (planta) y de la retroalimentación.
% Si cambian un componente, cambienlo solo aqui
% Valores tomados de PLECS 
% Modelo IDEAL:MOSFET con Ron=0, diodo con Vf= 0 y Ron = 0,
% inductor y capacitor sin resistencia serie

%Fuente de entrada
p.Vs= 5;% Tensión de entrada nominal [V]

%Elementos
p.L= 200e-6; % Inductor
p.C= 47e-6;  % Capacitor

%Carga y divisor de tension
p.RL= 100;% Resistencia de carga
p.R2= 1e6;% Resistencia superior del divisor
p.R3= 250e3;% Resistencia inferior del divisor

% El divisor esta en paralelo con la carga
p.Req= p.RL*(p.R2 + p.R3)/(p.RL + p.R2 + p.R3);

% Ganancia del sensor (retroalimentación NO unitaria)
p.H= p.R3/(p.R2 + p.R3);

%Conmutación
p.fclk= 16e6;% Reloj 
p.fsw= 80e3; % Frecuencia de conmutacion
p.TOP= p.fclk/p.fsw; % Cuentas por periodo = 200->resolución 0,5 %

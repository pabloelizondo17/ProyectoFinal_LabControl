%Actividad 1 
%Simula el modelo no lineal del convertidor boost ideal
%L* diL/dt =vs -(1-d) *vo (ec. de la bobina)
%C* dvo/dt =(1 - d)*iL-vo/Req (ec. del capacitor)
%y= H*vo (sensor / divisor)
%
% Estados: x=[iL; vo] (corriente en L [A], tensión en C [V])
% Entradas: d=ciclo de trabajo, vs =tensión de entrada
%
% el convertidor está en reposo con D = 0 % y se aplica D = 50 %

clear; clc; close all;

parametros_boost; % carga la estructura p con todos los parámetros

%Condiciones de la simulación 
D_pct= 50; %Ciclo de trabajo aplicado [%](n = 100 cuentas)
d = D_pct/100; %El modelo usa d en por unidad 
vs = p.Vs; % Entrada constante [V]

% Condición inicial: placa energizada pero el Arduino aún no conmuta (D = 0).
% Con el MOSFET siempre abierto la corriente pasa por L, el diodo y la carga:
%   vo = Vs   y   iL = Vs/Req   (es el equilibrio del modelo con d = 0)
x0 = [vs/p.Req; vs];

% Tiempo de simulación: la envolvente decae con tau = 2*Req*C = 9,4 ms.
% 60 ms son ~6 constantes de tiempo, suficiente para llegar al estacionario.
tfin= 60e-3;

% ode45 integra la ecuación diferencial. Se limita el paso máximo para que la oscilación (~821 Hz) se dibuje bien.
opts= odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',5e-6);
[t, x]= ode45(@(t,x) modelo_boost(x, d, vs, p), [0 tfin], x0, opts);

iL= x(:,1); 
vo = x(:,2);
y = p.H*vo;

%Equilibrio predicho por el modelo (se obtiene con dx/dt = 0):
Vo_eq = vs/(1-d);
IL_eq = Vo_eq/(p.Req*(1-d));
fprintf('Equilibrio predicho:  Vo = %.4f V,  IL = %.4f A,  y = H*Vo = %.4f V\n', ...
        Vo_eq, IL_eq, p.H*Vo_eq);
fprintf('Final de la simulación: vo = %.4f V,  iL = %.4f A\n', vo(end), iL(end));
fprintf('Pico de vo = %.2f V,  pico de iL = %.2f A (arranque ideal, sin amortiguamiento real)\n', ...
        max(vo), max(iL));
idx = find(abs(vo - Vo_eq) > 0.02*Vo_eq, 1, 'last');
fprintf('Tiempo de asentamiento (2 %%) aprox.: %.1f ms\n', 1e3*t(idx));

%% Gráficas de entrada y estados
figure('Name','A1 - Simulación no lineal');
subplot(3,1,1);
plot(1e3*[0 0 tfin], [0 D_pct D_pct], 'LineWidth',1.5); grid on;
ylabel('D [%]'); ylim([0 60]); title('Entrada: ciclo de trabajo');
subplot(3,1,2);
plot(1e3*t, vo, 'LineWidth',1.2); hold on;
yline(Vo_eq,'--','V_o equilibrio'); grid on;
ylabel('v_o [V]'); title('Tensión de salida');
subplot(3,1,3);
plot(1e3*t, iL, 'LineWidth',1.2); hold on;
yline(IL_eq,'--','I_L equilibrio'); grid on;
ylabel('i_L [A]'); xlabel('t [ms]'); title('Corriente en el inductor');
guardar_figura(gcf, 'A1_simulacion_no_lineal');


%funciones locales
function dx = modelo_boost(x, d, vs, p)
%Modelo promediado no lineal: dx/dt= f(x, d, vs)
    iL=x(1);
    vo=x(2);
    diL=(vs - (1-d)*vo)/p.L; % Ley de tensiones en la bobina
    dvo=((1-d)*iL - vo/p.Req)/p.C;% Ley de corrientes en el capacitor
    dx =[diL; dvo];
end

function guardar_figura(fig, nombre)
% Guarda la figura en la carpeta del informe (../Informe/fig)
    carpeta = fullfile('..','Informe','fig');
    if ~exist(carpeta,'dir'); mkdir(carpeta); end
    try
        exportgraphics(fig, fullfile(carpeta,[nombre '.pdf']), 'ContentType','vector');
    catch
        saveas(fig, fullfile(carpeta,[nombre '.png']));   % versiones viejas
    end
end

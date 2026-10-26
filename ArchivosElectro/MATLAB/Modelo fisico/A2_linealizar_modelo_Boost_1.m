% Linealiza el modelo promediado del boost alrededor de Vo = 15 V
% (D = 66,67 %)
% Requiere: Control System Toolbox (ss, tf, lsim, pole, zero, damp)
% -------------------------------------------------------------------------
clear; clc; close all;
parametros_boost;

%% 1) Punto de operación ---------------------------------------------------
% El punto de operacion se elige por la TENSION de salida deseada y de ahi
% se calcula el ciclo de trabajo con la relacion ideal Vo = Vs/(1-D):
%   D = 1 - Vs/Vo   ->   con Vs = 5 V y Vo = 15 V:  D = 2/3 = 66,67 %
% Nota: el Arduino solo da pasos de 0,5 %, asi que en la practica se usaria
% 66,5 % (Vo = 14,93 V) o 67 % (Vo = 15,15 V). Para la linealizacion se usa
% el valor exacto, que da Vo = 15 V justo.
Vo_obj   = 15;                       % [V] tension de salida del punto de operacion
Dbar     = 1 - p.Vs/Vo_obj;          % por unidad (0,6667)
Dbar_pct = 100*Dbar;                 % [%] (66,67 %)
Dp       = 1 - Dbar;         % D' = 1 - D (fracción de tiempo con MOSFET abierto)
Vsbar    = p.Vs;             % [V]

% Haciendo dx/dt = 0:
%   f1 = 0  ->  Vs = (1-D)*Vo        ->  Vo = Vs/(1-D)
%   f2 = 0  ->  (1-D)*IL = Vo/Req    ->  IL = Vo/(Req*(1-D))
% A diferencia de la TCLab (que necesitaba fzero por el término T^4),
% aquí el equilibrio tiene solución ANALÍTICA, así que no hace falta fzero.
Vobar = Vsbar/Dp;
ILbar = Vobar/(p.Req*Dp);
xbar  = [ILbar; Vobar];
ubar  = [Dbar; Vsbar];

f = @(x,u) [ (u(2) - (1-u(1))*x(2))/p.L ;
             ((1-u(1))*x(1) - x(2)/p.Req)/p.C ];

fprintf('--- Punto de operación ---\n');
fprintf('D = %.2f %%,  Vs = %.2f V\n', Dbar_pct, Vsbar);
fprintf('Vo = %.4f V,  IL = %.4f A,  y = H*Vo = %.4f V\n', Vobar, ILbar, p.H*Vobar);
fprintf('Comprobación f(xbar,ubar) = [%.2e  %.2e]  (debe ser ~0)\n', f(xbar,ubar));

%% 2) Linealización (Taylor de primer orden) ------------------------------
% Derivadas parciales evaluadas en el punto de operación:
A = [ 0          , -Dp/p.L          ;     % df1/diL , df1/dvo
      Dp/p.C     , -1/(p.Req*p.C)   ];    % df2/diL , df2/dvo
Bd = [ Vobar/p.L ;                        % df1/dd
      -ILbar/p.C ];                       % df2/dd
Bv = [ 1/p.L ;                            % df1/dvs
       0     ];                           % df2/dvs

% Comprobación con diferencias finitas (debe coincidir con lo analítico)
h = 1e-6;  Anum = zeros(2);  Bnum = zeros(2);
for k = 1:2
    e = zeros(2,1); e(k) = h;
    Anum(:,k) = (f(xbar+e,ubar) - f(xbar-e,ubar))/(2*h);
    Bnum(:,k) = (f(xbar,ubar+e) - f(xbar,ubar-e))/(2*h);
end
fprintf('\n--- Jacobianos ---\n');
disp('A analítica ='); disp(A);
fprintf('Error relativo máx. A: %.2e,  B: %.2e\n', ...
    max(abs(A(:)-Anum(:)))/max(abs(A(:))), max(abs([Bd Bv]-Bnum),[],'all')/max(abs([Bd Bv]),[],'all'));

%% 3) Modelo de estado y funciones de transferencia ----------------------
% Entrada del ciclo de trabajo en PORCENTAJE (como Q en la TCLab):
% d[p.u.] = D[%]/100  ->  la columna de B se divide entre 100.
B   = [Bd/100, Bv];                 % u_hat = [D_hat (%); vs_hat (V)]
Cm  = [0 1; 0 p.H];                 % salidas: vo_hat y y_hat = H*vo_hat
sys = ss(A, B, Cm, 0);
sys.InputName  = {'D (%)','vs (V)'};
sys.OutputName = {'vo (V)','y (V)'};

Gvd = tf(sys(1,1));                 % vo_hat(s)/D_hat(s)   [V/%]
Gvg = tf(sys(1,2));                 % vo_hat(s)/vs_hat(s)  [V/V]
Gyd = tf(sys(2,1));                 % y_hat(s)/D_hat(s)    [V/%] (lo que ve el Arduino)

% Forma estándar:  G(s) = K * (1 - s/wz) / (s^2/w0^2 + 2*zeta*s/w0 + 1)
K_vd = Vsbar/Dp^2/100;              % ganancia DC [V/%]
K_vg = 1/Dp;                        % ganancia DC [V/V]
wz   = p.Req*Dp^2/p.L;              % cero en semiplano DERECHO [rad/s]
w0   = Dp/sqrt(p.L*p.C);            % frecuencia natural [rad/s]
zeta = (1/(2*p.Req*Dp))*sqrt(p.L/p.C);  % amortiguamiento [-]

fprintf('\n--- Funciones de transferencia ---\n');
disp('Gvd(s) = vo/D [V/%]:'); Gvd
disp('Gvg(s) = vo/vs [V/V]:'); Gvg
disp('Gyd(s) = y/D  [V/%] (con H):'); Gyd
fprintf('K_vd = %.4f V/%%   K_yd = %.4f V/%%   K_vg = %.4f V/V\n', K_vd, p.H*K_vd, K_vg);
fprintf('w0 = %.1f rad/s (f0 = %.1f Hz),  zeta = %.4f\n', w0, w0/(2*pi), zeta);
fprintf('Cero SPD: wz = %.4g rad/s (fz = %.2f kHz)\n', wz, wz/(2*pi)/1e3);
fprintf('Polos: '); disp(pole(Gvd).');
fprintf('Ceros: '); disp(zero(Gvd).');
fprintf('Comprobación DC: dcgain(Gvd) = %.4f V/%%, dcgain(Gvg) = %.4f\n', dcgain(Gvd), dcgain(Gvg));



%% ======================= FUNCIÓN LOCAL ==================================
function guardar_figura(fig, nombre)
    carpeta = fullfile('..','Informe','fig');
    if ~exist(carpeta,'dir'); mkdir(carpeta); end
    try
        exportgraphics(fig, fullfile(carpeta,[nombre '.pdf']), 'ContentType','vector');
    catch
        saveas(fig, fullfile(carpeta,[nombre '.png']));
    end
end

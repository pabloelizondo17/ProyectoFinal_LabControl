function modelo = B3_identificar_boost(archivo, Vs_real)
% B3_IDENTIFICAR_BOOST  Identifica el boost real a partir de un ensayo de B2.
%
%   modeloEsc = B3_identificar_boost("datos_exp/escalon_boost_20261020_1530.mat");
%
% Dos modelos (variables de desviación alrededor del punto de operación):
%   - Caja negra: 2º orden subamortiguado con retardo (procest 'P2UD'),
%                 requiere System Identification Toolbox. Entrada Δd [p.u.], salida Δvo [V].
%   - Caja gris : modelo promediado no lineal de A1 + pérdidas [r, Vf, kL, kC],
%                 ajustado con fminsearch (MATLAB base). De él se linealiza
%                 sys_gris con entradas {d, vs} y salida vo.
%
% El cero en el semiplano derecho no se identifica (queda por encima de la banda
% medible con este muestreo); sys_gris lo incluye porque sale del modelo físico.

parametros_boost;
S = load(archivo);  dat = S.datos;
if nargin < 2 || isempty(Vs_real), Vs_real = dat.Vs_real; end

Ts = dat.Ts;  N = dat.N;  npre = dat.npre;
D0  = dat.nv(1)/p.TOP;
vo0 = mean(dat.vo(1:npre));
dy  = dat.vo - vo0;                 % desviación medida [V]
du  = dat.d  - D0;                  % desviación de la entrada [p.u.]

% Valores teóricos de referencia (modelo ideal)
K_th  = Vs_real/(1-D0)^2;
wn_th = (1-D0)/sqrt(p.L*p.C);
fprintf('\n== %s ==\n', archivo);
fprintf('D0 = %.3f, Vo0 medido = %.3f V (ideal %.3f V)\n', D0, vo0, Vs_real/(1-D0));
fprintf('Ideal: K = %.1f V/p.u., fn = %.0f Hz\n', K_th, wn_th/2/pi);

%% Caja negra
sys_bb = [];  fit_bb = NaN;  y_bb = nan(N,1);
if exist('procest','file') == 2 && exist('iddata','file') == 2
    data = iddata(dy, du, Ts);
    try
        init = idproc('P2UD','Kp',K_th,'Tw',1/wn_th,'Zeta',0.1,'Td',Ts);
        init.Structure.Zeta.Minimum = 0;  init.Structure.Zeta.Maximum = 1.5;
        init.Structure.Td.Minimum   = 0;  init.Structure.Td.Maximum   = 5*Ts;
        sys_bb = procest(data, init, procestOptions('Display','off'));
    catch
        sys_bb = procest(data, 'P2UD', procestOptions('Display','off'));
    end
    [~, fit_bb] = compare(data, sys_bb);
    yb = sim(sys_bb, iddata([], du, Ts));
    y_bb = yb.y;
    fprintf('Caja negra P2UD: K = %.1f V/p.u., fn = %.0f Hz, zeta = %.3f, Td = %.0f us, ajuste = %.1f %%\n', ...
            sys_bb.Kp, 1/(2*pi*sys_bb.Tw), sys_bb.Zeta, 1e6*sys_bb.Td, fit_bb);
else
    warning('Sin System Identification Toolbox: se omite la caja negra.');
end

%% Caja gris
theta0 = [log(0.3); 0.3; 0; 0];                    % [log r, Vf, log kL, log kC]
fun = @(th) costo_gris(th, p, Vs_real, dat, vo0, dy);
opt = optimset('Display','off','MaxFunEvals',800,'MaxIter',600,'TolX',1e-4,'TolFun',1e-8);
[th, ~] = fminsearch(fun, theta0, opt);
[th, J] = fminsearch(fun, th, opt);                 % reinicia el simplex
par_gris = desempaquetar(th);
[vo_g, vo0m, iL0v] = boost_simular(par_gris, p, Vs_real, dat.nv, dat.dur, Ts);
y_gris = vo_g - vo0m;
fit_gris = 100*(1 - norm(dy - y_gris)/norm(dy - mean(dy)));

sys_gris = linealizar_gris(par_gris, p, D0, vo0m, iL0v(1));
[wn_g, z_g] = damp(sys_gris(1,1));
fprintf('Caja gris: r = %.3f ohm, Vf = %.3f V, kL = %.3f, kC = %.3f, ajuste = %.1f %%\n', ...
        par_gris(1), par_gris(2), par_gris(3), par_gris(4), fit_gris);
fprintf('  Vo0 del modelo = %.3f V (medido %.3f V); fn = %.0f Hz, zeta = %.3f\n', ...
        vo0m, vo0, wn_g(1)/2/pi, z_g(1));
z_rhp = (1-D0)^2*p.Req/(par_gris(3)*p.L);
fprintf('  Cero RHP del modelo gris: %.1f kHz\n', z_rhp/2/pi/1e3);

%% Gráficas
figure('Name','B3 - Identificación');
subplot(2,1,1);
plot(1e3*dat.t, dy, 'k', 'LineWidth', 1.2); hold on;
plot(1e3*dat.t, y_gris, 'r', 'LineWidth', 1.1);
if ~isempty(sys_bb), plot(1e3*dat.t, y_bb, 'b--', 'LineWidth', 1.1); end
grid on; ylabel('\Delta v_o [V]');
leyenda = {'medido', sprintf('caja gris (%.1f%%)', fit_gris)};
if ~isempty(sys_bb), leyenda{end+1} = sprintf('caja negra (%.1f%%)', fit_bb); end
legend(leyenda, 'Location', 'best'); title(strrep(dat.tipo, '_', ' '));
subplot(2,1,2);
plot(1e3*dat.t, dy - y_gris, 'r'); hold on;
if ~isempty(sys_bb), plot(1e3*dat.t, dy - y_bb, 'b--'); end
grid on; ylabel('residuo [V]'); xlabel('t [ms]');
[~, nombre] = fileparts(archivo);
guardar_figura(gcf, ['B3_' nombre]);

%% Salida
modelo.archivo  = archivo;   modelo.tipo = dat.tipo;
modelo.D0 = D0;  modelo.vo0 = vo0;  modelo.Vs = Vs_real;  modelo.Ts = Ts;
modelo.par_gris = par_gris;  modelo.sys_gris = sys_gris;  modelo.fit_gris = fit_gris;
modelo.sys_bb   = sys_bb;    modelo.fit_bb = fit_bb;      modelo.costo = J;

archivo = char(string(archivo));
[~, nombre, ~] = fileparts(archivo);
nombre = char(nombre);
nombre = strtrim(nombre(:).');

guardar_figura(gcf, ['B3_' nombre]);

if ~exist('modelos', 'dir')
    mkdir('modelos');
end

ruta_modelo = fullfile('modelos', ['modelo_' nombre '.mat']);
save(ruta_modelo, 'modelo');

fprintf('Modelo guardado en: %s\n', ruta_modelo);

end

%% Funciones locales
function J = costo_gris(th, p, vs, dat, vo0, dy)
    par = desempaquetar(th);
    Vf_c = min(max(par(2), 0), 1.5);
    kL_c = min(max(par(3), 0.5), 1.5);
    kC_c = min(max(par(4), 0.5), 1.5);
    pen  = 1e3*((par(2)-Vf_c)^2 + (par(3)-kL_c)^2 + (par(4)-kC_c)^2) + 1e3*max(0, par(1)-20)^2;
    [vo, vo0m] = boost_simular([par(1) Vf_c kL_c kC_c], p, vs, dat.nv, dat.dur, dat.Ts);
    e = (vo - vo0m) - dy;
    % Término absoluto: el nivel de Vo en D0 informa sobre r y Vf
    J = sum(e.^2) + (numel(dy)/4)*(vo0m - vo0)^2 + pen;
    if ~isfinite(J), J = 1e12; end
end

function par = desempaquetar(th)
    par = [exp(th(1)), th(2), exp(th(3)), exp(th(4))];
end

function sys = linealizar_gris(par, p, d0, vo0, iL0)
    r = par(1); Vf = par(2); L = par(3)*p.L; C = par(4)*p.C; Req = p.Req;
    A = [-r/L,        -(1-d0)/L;
          (1-d0)/C,   -1/(Req*C)];
    B = [(vo0+Vf)/L,   1/L;
         -iL0/C,       0];
    sys = ss(A, B, [0 1], [0 0], 'InputName', {'d','vs'}, 'OutputName', 'vo');
end

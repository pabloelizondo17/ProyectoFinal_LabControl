%B4 Validación cruzada del modelo del boost (equivale a la Sección 9 de la guía)
%
% Cruce 1: modelo identificado con el escalón  -> predice el ensayo multinivel
% Cruce 2: modelo identificado con el multinivel -> predice el ensayo escalón
% Métricas desde el primer cambio de la entrada (respuesta dinámica) y con registro completo.

clear; clc; close all;
parametros_boost;

%% Archivos (ajustar a los nombres generados por B2)
archivoEsc = "datos_exp/escalon_boost_20261014_0941.mat";
archivoMul = "datos_exp/multinivel_boost_20261014_0942.mat";

mEsc = B3_identificar_boost(archivoEsc);
mMul = B3_identificar_boost(archivoMul);
S = load(archivoEsc);  dEsc = S.datos;
S = load(archivoMul);  dMul = S.datos;

if dEsc.n0 ~= dMul.n0
    warning('Los ensayos tienen distinto punto de operación (n0 = %d vs %d): el cruce no es válido.', ...
            dEsc.n0, dMul.n0);
end

%% Predicciones cruzadas
cruces = {mEsc, dMul, 'escalón → multinivel';
          mMul, dEsc, 'multinivel → escalón'};
filas = [];  etiquetas = strings(0,1);
for c = 1:size(cruces,1)
    m = cruces{c,1};  d = cruces{c,2};  nombre = cruces{c,3};
    [ymed, ygris, ybb] = predecir(m, d, p);
    i_din = (d.npre+1):d.N;  i_tot = 1:d.N;

    figure('Name', ['B4 - ' nombre]);
    subplot(2,1,1);
    plot(1e3*d.t, ymed, 'k', 'LineWidth', 1.2); hold on;
    plot(1e3*d.t, ygris, 'r', 'LineWidth', 1.1);
    if ~all(isnan(ybb)), plot(1e3*d.t, ybb, 'b--', 'LineWidth', 1.1); end
    grid on; ylabel('\Delta v_o [V]'); title(['Validación cruzada: ' nombre]);
    legend({'medido','caja gris','caja negra'}, 'Location', 'best');
    subplot(2,1,2);
    plot(1e3*d.t, ymed - ygris, 'r'); hold on;
    if ~all(isnan(ybb)), plot(1e3*d.t, ymed - ybb, 'b--'); end
    grid on; ylabel('residuo [V]'); xlabel('t [ms]');
    guardar_figura(gcf, ['B4_' strrep(strrep(nombre,' → ','_a_'),'ó','o')]);

    for modo = ["gris", "negra"]
        if modo == "gris", yh = ygris; else, yh = ybb; end
        if all(isnan(yh)), continue; end
        filas(end+1,:) = [metricas(ymed, yh, i_din), metricas(ymed, yh, i_tot)]; %#ok<SAGROW>
        etiquetas(end+1,1) = sprintf("%s | caja %s", nombre, modo); %#ok<SAGROW>
    end
end

%% Tabla de indicadores
nom = {'RMSE','MAE','Sesgo','SSE','R2','Ajuste'};
vn = [strcat(nom, '_din'), strcat(nom, '_tot')];
T = array2table(filas, 'VariableNames', vn, 'RowNames', cellstr(etiquetas));
disp(T);
fprintf('\n(_din: desde el primer cambio de la entrada; _tot: registro completo)\n');
fprintf('Sesgo > 0 -> el modelo subestima (e = y - yhat).\n');

save('resultados_validacion_cruzada_boost.mat', 'T', 'mEsc', 'mMul');

%% Funciones locales
function [ymed, ygris, ybb] = predecir(m, d, p)
    ymed = d.vo - mean(d.vo(1:d.npre));
    [vo, vo0m] = boost_simular(m.par_gris, p, d.Vs_real, d.nv, d.dur, d.Ts);
    ygris = vo - vo0m;
    ybb = nan(d.N, 1);
    if ~isempty(m.sys_bb)
        du = d.d - d.nv(1)/p.TOP;
        yb = sim(m.sys_bb, iddata([], du, d.Ts));
        ybb = yb.y;
    end
end

function v = metricas(y, yh, idx)
    y = y(idx);  yh = yh(idx);
    e = y - yh;
    rmse = sqrt(mean(e.^2));
    mae  = mean(abs(e));
    sesgo = mean(e);
    sse  = sum(e.^2);
    r2   = 1 - sse/sum((y - mean(y)).^2);
    ajuste = 100*(1 - norm(e)/norm(y - mean(y)));
    v = [rmse mae sesgo sse r2 ajuste];
end

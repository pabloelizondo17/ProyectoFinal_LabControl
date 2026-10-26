%% Metricas MIL del boost: PI y, posteriormente, LQR
% Ejecutar DESPUES de simular. No modifica ni ejecuta el modelo.
% To Workspace, formato Timeseries, Decimation=1, sin limite de puntos:
%   Vref_log    : referencia absoluta en V, ANTES de Gain 0.2.
%   Vo_log      : salida absoluta en V, DESPUES de Bias y Gain 5.
%   Duty_PI_log : duty ABSOLUTO en %, D0 + DeltaD (no solo DeltaD).
% Para el modelo actual D0=50; el sumador +50 es solo para registrar duty,
% NO se coloca antes de la planta identificada en variables incrementales.
%
% Acepta datos dentro de out (Single simulation output) o en workspace.
% Analiza el ULTIMO escalon registrado; excluye el arranque inicial.
% Debe haber muestras antes del escalon y tiempo suficiente despues.
% No valida por si mismo la identificacion, el hardware ni cambios de carga.

%% Configuracion
% "out": leer exclusivamente del objeto out. Si no existe, usa workspace.
% "": forzar lectura de variables sueltas del workspace.
nombreSalidaSimulacion = "out";
nombreReferencia = "Vref_log";

% Cada fila: etiqueta, nombre de salida en V, nombre de duty absoluto en %.
% Si no deseas registrar duty, sustituye su nombre por "".
casos = ["PI ideal", "Vo_log", "Duty_PI_log"];
% Cuando tengas el LQR, agrega esta fila y registra sus dos senales:
% casos(end+1,:) = ["LQR", "Vo_LQR_log", "Duty_LQR_log"];
% Ambos casos deben usar la misma referencia y duracion para compararlos.
% Si el PI tiene saturacion, cambia la etiqueta a "PI con saturacion".

bandaRelativa = 0.02;       % +/-2% de la AMPLITUD del escalon
fraccionFinal = 0.10;      % Promedio del ultimo 10% del tramo analizado
limitesDuty_pct = [50 75]; % Rango del ensayo; NO impone limites al modelo
toleranciaReferencia_V = 1e-8;

%% Lectura: no mezcla resultados de out con variables de otra simulacion
fuente = [];
if strlength(nombreSalidaSimulacion) > 0 && ...
        evalin('base', sprintf('exist(''%s'',''var'')', nombreSalidaSimulacion))
    fuente = evalin('base', char(nombreSalidaSimulacion));
    assert(isa(fuente, 'Simulink.SimulationOutput') || isstruct(fuente), ...
        'La salida de simulacion debe ser SimulationOutput o struct.');
end
ref = leerRegistro(fuente, nombreReferencia);
[tr, vr] = extraerTimeseries(ref, nombreReferencia);
saltos = find(abs(diff(vr)) > toleranciaReferencia_V) + 1;
assert(~isempty(saltos), ...
    ['No se encontro un escalon en Vref_log. Configure Step time > 0 ', ...
     'y registre muestras antes y despues del cambio.']);
kr = saltos(end);
instanteEscalon_s = tr(kr);
referenciaInicial_V = vr(kr-1);
referenciaFinal_V = vr(kr);
amplitud_V = referenciaFinal_V - referenciaInicial_V;
anchoBanda_V = bandaRelativa * abs(amplitud_V);

nCasos = size(casos,1);
valores = nan(4,nCasos);
extras = nan(nCasos,4);
tramos = cell(nCasos,1);
registrosDuty = cell(nCasos,1);

%% Calculo por caso
for c = 1:nCasos
    [t, y] = extraerTimeseries(leerRegistro(fuente, casos(c,2)), casos(c,2));
    assert(t(1) < instanteEscalon_s && t(end) > instanteEscalon_s, ...
        'La salida debe cubrir tiempos anteriores y posteriores al escalon.');
    assert(t(end) <= tr(end) + 1e-10, ...
        'La referencia debe cubrir toda la duracion de la salida.');
    k = find(t >= instanteEscalon_s, 1);
    if abs(y(k-1) - referenciaInicial_V) > anchoBanda_V
        warning('%s: salida previa alejada de referencia; deje asentar antes del escalon.', casos(c,1));
    end
    tt = t(k:end) - instanteEscalon_s;
    yy = y(k:end);
    assert(numel(tt) >= 5, 'Se requieren al menos cinco muestras despues del escalon.');
    % Normalizacion: 0=referencia anterior, 1=referencia final.
    % Tambien sirve para escalones descendentes.
    z = (yy - referenciaInicial_V) / amplitud_V;
    t10 = primerCruce(tt, z, 0.1);
    t90 = primerCruce(tt, z, 0.9);
    tiempoSubida_s = t90 - t10;
    % Si el primer punto ya supera un umbral, no inventar el cruce.
    if isnan(tiempoSubida_s)
        warning('%s: no se resolvieron ambos cruces 10-90%%; revise muestreo o duracion.', casos(c,1));
    end
    sobreimpulso_pct = max(0, 100*(max(z)-1));
    fuera = find(abs(yy-referenciaFinal_V) > anchoBanda_V, 1, 'last');
    if isempty(fuera)
        tiempoEstablecimiento_s = tt(1);
    elseif fuera == numel(tt)
        tiempoEstablecimiento_s = NaN;
    else
        tiempoEstablecimiento_s = tt(fuera+1);
    end
    % Valor estimado a partir del final de la captura, no de 60 s termicos.
    finales = tt >= tt(end)*(1-fraccionFinal);
    errorEstacionario_V = referenciaFinal_V - mean(yy(finales));
    if isnan(tiempoEstablecimiento_s) || ...
            tiempoEstablecimiento_s > tt(find(finales,1))
        warning(['%s: no hay una ventana final completamente asentada al 2%%. ', ...
            'El error final aun no confirma error estacionario; prolongue la simulacion.'], casos(c,1));
    end
    valores(:,c) = [tiempoSubida_s; tiempoEstablecimiento_s; ...
        sobreimpulso_pct; errorEstacionario_V];
    % Limites y maximos se evaluan sobre TODO el registro, incluido arranque.
    extras(c,1) = max(y);
    if strlength(casos(c,3)) > 0
        [td, d] = extraerTimeseries(leerRegistro(fuente, casos(c,3)), casos(c,3));
        extras(c,2:3) = [min(d), max(d)];
        fueraDuty = d < limitesDuty_pct(1)-1e-9 | d > limitesDuty_pct(2)+1e-9;
        extras(c,4) = sum(diff(td).*double(fueraDuty(1:end-1)));
        registrosDuty{c} = [td,d];
    end
    tramos{c} = [tt,yy];
end

%% Tablas para el informe (s y V; sin redondear tiempos a cero)
Metrica = ["Tiempo de subida (s)"; "Tiempo de establecimiento (s)"; ...
    "Sobreimpulso (%)"; "Error estacionario (V)"];
nombres = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(cellstr(casos(:,1))));
tablaMIL = [table(Metrica), array2table(valores, 'VariableNames', nombres)];
resultados_Boost = table(casos(:,1), valores(1,:).', valores(2,:).', ...
    valores(3,:).', valores(4,:).', extras(:,1), extras(:,2), extras(:,3), extras(:,4), ...
    'VariableNames', {'Caso','TiempoSubida_s','TiempoEstablecimiento_s', ...
    'Sobreimpulso_pct','ErrorEstacionario_V','VoltajeMaximo_V', ...
    'DutyMinimo_pct','DutyMaximo_pct','TiempoDutyFueraRango_s'});
fprintf('\nEscalon analizado: %.6g -> %.6g V, en t = %.6g s\n', ...
    referenciaInicial_V, referenciaFinal_V, instanteEscalon_s);
fprintf('Banda de establecimiento: %.6g +/- %.6g V\n', referenciaFinal_V, anchoBanda_V);
disp(tablaMIL);
for c = 1:nCasos
    fprintf('%s: tr = %.6g ms; ts = %.6g ms; Mp = %.6g %%; ess = %.6g V\n', ...
        casos(c,1), 1e3*valores(1,c), 1e3*valores(2,c), valores(3,c), valores(4,c));
end
disp(resultados_Boost);
fprintf(['ess = referencia - promedio final (con signo). NaN indica dato no disponible.\n', ...
    'Establecimiento verificado solo hasta el fin del registro.\n']);

%% Graficas: tramo analizado y duty absoluto de toda la simulacion
figure('Name','Boost: metricas MIL','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile; hold on;
for c = 1:nCasos
    datos = tramos{c};
    plot(1e3*datos(:,1), datos(:,2), 'LineWidth',1.4,'DisplayName',casos(c,1));
end
yline(referenciaFinal_V,'--k','Referencia','HandleVisibility','off');
yline(referenciaFinal_V+anchoBanda_V,':k','HandleVisibility','off');
yline(referenciaFinal_V-anchoBanda_V,':k','HandleVisibility','off');
grid on; xlabel('Tiempo desde el ultimo escalon [ms]'); ylabel('Vo [V]');
title('Respuesta al ultimo escalon'); legend('Location','best');
nexttile; hold on;
for c = 1:nCasos
    datos = registrosDuty{c};
    if ~isempty(datos)
        stairs(1e3*datos(:,1),datos(:,2),'LineWidth',1.2,'DisplayName',casos(c,1));
    end
end
yline(limitesDuty_pct(1),':r','HandleVisibility','off');
yline(limitesDuty_pct(2),':r','HandleVisibility','off');
grid on; xlabel('Tiempo de simulacion [ms]'); ylabel('Duty absoluto [%]');
title('Duty registrado y rango de referencia del ensayo');
if any(~cellfun(@isempty, registrosDuty)), legend('Location','best'); end

%% Funciones locales
function senal = leerRegistro(fuente, nombre)
    if isempty(fuente)
        assert(evalin('base', sprintf('exist(''%s'',''var'')', nombre)) == 1, ...
            'Falta %s. Revise el nombre del bloque To Workspace.', nombre);
        senal = evalin('base', char(nombre));
    elseif isstruct(fuente)
        assert(isfield(fuente, char(nombre)), 'Falta %s en la salida de simulacion.', nombre);
        senal = fuente.(char(nombre));
    else
        senal = get(fuente, char(nombre));
    end
end

function [t,y] = extraerTimeseries(senal, nombre)
    assert(isa(senal,'timeseries'), '%s debe tener formato Timeseries.', nombre);
    t = double(senal.Time(:));
    y = double(squeeze(senal.Data));
    assert(isvector(y) && numel(y)==numel(t), '%s debe ser una senal escalar.', nombre);
    y = y(:);
    assert(numel(t)>=2 && isreal(y) && all(isfinite(t)) && all(isfinite(y)), ...
        '%s contiene datos no validos.', nombre);
    assert(all(diff(t)>=0), 'El tiempo de %s debe ser creciente.', nombre);
    % En discontinuidades puede haber dos valores al mismo tiempo.
    [t, indices] = unique(t, 'last');
    y = y(indices);
    assert(numel(t)>=2, '%s necesita al menos dos tiempos distintos.', nombre);
end

function tc = primerCruce(t,z,nivel)
    % Primer cruce ascendente con interpolacion lineal entre muestras.
    tc = NaN;
    k = find(z>=nivel, 1);
    if isempty(k), return; end
    if k==1
        if z(1)==nivel, tc=t(1); end
        return;
    end
    tc = t(k-1)+(nivel-z(k-1))*(t(k)-t(k-1))/(z(k)-z(k-1));
end

function validacion = A6_validar_FOPDT_Boost(modelo,archivoMAT)
% Valida un modelo FOPDT con otro experimento del boost.

% El modelo se mantiene fijo durante toda la validacion:
%
%                  K exp(-theta s)
%       G(s) =  = ----------------
%                   tau s + 1
%
% Esta funcion NO optimiza ni modifica K, tau o theta. Acepta como primer
% argumento el resultado producido por A5_identificar_FOPDT
%
%   

arguments
    modelo
    archivoMAT (1,1) string = ""
end

%% Parametros fijos del modelo

[K,tau,theta,archivoIdentificacion] = extraerParametrosModelo(modelo);

if ~isfinite(K) || K < 0
    error("Boost:GananciaInvalida", ...
        "K debe ser finita y no negativa.")
end

if ~isfinite(tau) || tau <= 0
    error("Boost:ConstanteTiempoInvalida", ...
        "tau debe ser finita y positiva.")
end

if ~isfinite(theta) || theta < 0
    error("Boost:RetardoInvalido", ...
        "theta debe ser finito y no negativo.")
end

%% Seleccion y carga del experimento de validacion

if strlength(archivoMAT) == 0
    carpetaInicial = fullfile(pwd,"Resultados_experimentos");

    if ~isfolder(carpetaInicial)
        carpetaInicial = pwd;
    end

    [nombreArchivo,carpetaArchivo] = uigetfile( ...
        fullfile(carpetaInicial,"*.mat"), ...
        "Seleccione el experimento de validacion");

    if isequal(nombreArchivo,0)
        error("Boost:SeleccionCancelada", ...
            "No se selecciono ningun archivo.")
    end

    archivoMAT = string(fullfile(carpetaArchivo,nombreArchivo));
end

if ~isfile(archivoMAT)
    error("Boost:ArchivoNoEncontrado", ...
        "No se encontro el archivo: %s",archivoMAT)
end

contenido = load(archivoMAT);
datos     = extraerTablaExperimental(contenido);

%% Extraccion y validacion de las senales SISO

nombresRequeridos  = ["Tiempo_s","Duty_pct","VA0_V"];  % [Adaptacion boost]
nombresDisponibles = string(datos.Properties.VariableNames);

if ~all(ismember(nombresRequeridos,nombresDisponibles))
    faltantes = nombresRequeridos(~ismember( ...
        nombresRequeridos,nombresDisponibles));
    error("Boost:VariablesFaltantes", ...
        "Faltan las variables requeridas: %s",join(faltantes,", "))
end

t = double(datos.Tiempo_s(:));
u = double(datos.Duty_pct(:));   % [Adaptacion boost] entrada: ciclo de trabajo (%)
y = double(datos.VA0_V(:));      % [Adaptacion boost] salida: tension en A0 (V)

filasValidas = isfinite(t) & isfinite(u) & isfinite(y);

if ~all(filasValidas)
    warning("Boost:FilasInvalidas", ...
        "Se eliminaron %d filas con datos no finitos.",sum(~filasValidas))
    t = t(filasValidas);
    u = u(filasValidas);
    y = y(filasValidas);
end

if numel(t) < 20
    error("Boost:DatosInsuficientes", ...
        "Se requieren al menos 20 muestras validas para validar el modelo.")
end

t = t-t(1);

if any(diff(t) <= 0)
    error("Boost:TiempoInvalido", ...
        "Tiempo_s debe ser estrictamente creciente.")
end

toleranciaEntrada = max(1e-9,1e-6*max(1,max(abs(u))));
indiceCambio = find(abs(diff(u)) > toleranciaEntrada,1,"first")+1;

if isempty(indiceCambio)
    error("Boost:EntradaConstante", ...
        "Duty_pct no contiene ningun cambio de nivel.")
end

indicesIniciales = 1:indiceCambio-1;

if numel(indicesIniciales) < 5
    error("Boost:PeriodoInicialInsuficiente", ...
        "Se requieren al menos cinco muestras antes del primer cambio de Duty_pct.")
end

u0 = median(u(indicesIniciales));
y0 = mean(y(indicesIniciales));

%% Simulacion sin reidentificacion

z       = simularRespuestaUnitaria(t,u,u0,tau,theta);
yModelo = y0+K*z;
residuo = y-yModelo;

indicesRespuesta = indiceCambio:numel(t);
metricasCompletas = calcularMetricas(y,yModelo);
metricasRespuesta = calcularMetricas( ...
    y(indicesRespuesta),yModelo(indicesRespuesta));

if exist("tf","file") == 2
    G = tf(K,[tau 1],"InputDelay",theta);
else
    G = [];
    warning("Boost:ControlSystemToolboxNoDisponible", ...
        ["No se pudo construir el objeto tf. La validacion numerica " ...
         "si fue realizada."])
end

%% Organizacion de los resultados

tramo = ["Datos completos";"Desde el primer cambio"];

validacion = struct;
validacion.ArchivoValidacion     = archivoMAT;
validacion.ArchivoIdentificacion = archivoIdentificacion;
validacion.Modelo                = "FOPDT fijo, sin reoptimizacion";
validacion.G                     = G;
validacion.Parametros = table(K,tau,theta, ...
    VariableNames=["K_V_por_pct","Tau_s","Theta_s"]);
validacion.CondicionInicial = table(u0,y0,t(indiceCambio), ...
    VariableNames=["Duty_inicial_pct","VA0_inicial_V","PrimerCambio_s"]);
validacion.Metricas = table( ...
    tramo, ...
    [metricasCompletas.RMSE_C;metricasRespuesta.RMSE_C], ...
    [metricasCompletas.MAE_C;metricasRespuesta.MAE_C], ...
    [metricasCompletas.R2;metricasRespuesta.R2], ...
    [metricasCompletas.Ajuste_pct;metricasRespuesta.Ajuste_pct], ...
    [metricasCompletas.SESGO_C;metricasRespuesta.SESGO_C], ...
    [metricasCompletas.SSE;metricasRespuesta.SSE], ...
    VariableNames=[ ...
        "Tramo","RMSE_V","MAE_V","R2", ...
        "Ajuste_pct","Sesgo_V","SSE"]);
validacion.Datos = table(t,u,y,yModelo,residuo, ...
    VariableNames=[ ...
        "Tiempo_s","Duty_pct","VA0_experimental_V", ...
        "VA0_modelo_V","Residuo_V"]);

%% Presentacion de resultados

[~,nombreValidacion,extensionValidacion] = fileparts(archivoMAT);
nombreArchivoValidacion = nombreValidacion+extensionValidacion;

nombreArchivoIdentificacion = "";
if strlength(archivoIdentificacion) > 0
    [~,nombreIdentificacion,extensionIdentificacion] = ...
        fileparts(archivoIdentificacion);
    nombreArchivoIdentificacion = ...
        nombreIdentificacion+extensionIdentificacion;
end

fprintf("\nValidacion cruzada del modelo FOPDT\n")
fprintf("Archivo de validacion: %s\n",nombreArchivoValidacion)

if strlength(nombreArchivoIdentificacion) > 0
    fprintf("Modelo identificado con: %s\n",nombreArchivoIdentificacion)
end

fprintf("\n")
fprintf("K      = %.6f V/%% (fijo)\n",K)
fprintf("tau    = %.4f ms (fijo)\n",1e3*tau)
fprintf("theta  = %.4f ms (fijo)\n",1e3*theta)

fprintf("\nMetricas desde el primer cambio de Duty\n")
fprintf("RMSE   = %.4f V\n",metricasRespuesta.RMSE_C)
fprintf("MAE    = %.4f V\n",metricasRespuesta.MAE_C)
fprintf("R^2    = %.5f\n",metricasRespuesta.R2)
fprintf("Ajuste = %.2f %%\n",metricasRespuesta.Ajuste_pct)
fprintf("Sesgo  = %.4f V\n",metricasRespuesta.SESGO_C)
fprintf("SSE    = %.4f (V)^2\n",metricasRespuesta.SSE)
fprintf("\nNo se reoptimizo ningun parametro.\n\n")

nombreSinRuta = nombreValidacion;
nombreMostrado = nombreArchivoValidacion;

figura = figure( ...
    Name="Validacion FOPDT - "+nombreSinRuta, ...
    Color="w");

distribucion = tiledlayout(figura,3,1, ...
    TileSpacing="compact",Padding="compact");

nexttile(distribucion)
plot(t,y,"Color",[0.15 0.15 0.15],LineWidth=1.0)
hold on
plot(t,yModelo,"--",Color=[0.85 0.20 0.15],LineWidth=1.8)
xline(t(indiceCambio),":",Color=[0.35 0.35 0.35])
grid on
ylabel("V_{A0} (V)")
legend("Experimental","FOPDT fijo","Primer cambio",Location="best")
title("Validacion FOPDT: "+nombreMostrado,Interpreter="none")

nexttile(distribucion)
stairs(t,u,Color=[0.00 0.35 0.65],LineWidth=1.4)
xline(t(indiceCambio),":",Color=[0.35 0.35 0.35])
grid on
ylabel("Duty (%)")

nexttile(distribucion)
plot(t,residuo,Color=[0.35 0.35 0.35],LineWidth=1.0)
yline(0,"k:")
xline(t(indiceCambio),":",Color=[0.35 0.35 0.35])
grid on
xlabel("Tiempo (s)")
ylabel("Residuo (V)")

end


function [K,tau,theta,archivoIdentificacion] = ...
        extraerParametrosModelo(modelo)
%EXTRAERPARAMETROSMODELO Lee el resultado del identificador o [K tau theta].

archivoIdentificacion = "";

if isstruct(modelo) && isfield(modelo,"Parametros")
    parametros = modelo.Parametros;

    if ~istable(parametros)
        error("Boost:ModeloInvalido", ...
            "El campo Parametros del modelo debe ser una tabla.")
    end

    nombres = string(parametros.Properties.VariableNames);
    requeridos = ["K_V_por_pct","Tau_s","Theta_s"];  

    if ~all(ismember(requeridos,nombres)) || height(parametros) ~= 1
        error("Boost:ModeloInvalido", ...
            ["La tabla Parametros debe contener una fila con " ...
             "K_V_por_pct, Tau_s y Theta_s."])
    end

    K     = double(parametros.K_V_por_pct);
    tau   = double(parametros.Tau_s);
    theta = double(parametros.Theta_s);

    if isfield(modelo,"Archivo")
        archivoIdentificacion = string(modelo.Archivo);
    end

elseif isnumeric(modelo) && isvector(modelo) && numel(modelo) == 3
    parametros = double(modelo(:));
    K     = parametros(1);
    tau   = parametros(2);
    theta = parametros(3);

else
    error("Boost:ModeloInvalido", ...
        ["modelo debe ser el resultado de A5_identificar_FOPDT_Boost " ...
         "o el vector numerico [K tau theta]."])
end

end


function datos = extraerTablaExperimental(contenido)
%EXTRAERTABLAEXPERIMENTAL Localiza la tabla que contiene las senales SISO.
%
%Los archivos del boost guardan la tabla dentro de
% datos.tabla (datos es un struct, no una tabla). Se busca primero ahi.

if isfield(contenido,"datos") && isstruct(contenido.datos) && ...
        isfield(contenido.datos,"tabla") && istable(contenido.datos.tabla)
    datos = contenido.datos.tabla;
    return
end

if isfield(contenido,"datos") && istable(contenido.datos)
    datos = contenido.datos;
    return
end

campos = fieldnames(contenido);
requeridas = ["Tiempo_s","Duty_pct","VA0_V"];
indicesCandidatos = false(size(campos));

for k = 1:numel(campos)
    valor = contenido.(campos{k});

    if istable(valor)
        nombres = string(valor.Properties.VariableNames);
        indicesCandidatos(k) = all(ismember(requeridas,nombres));
    end
end

candidatos = campos(indicesCandidatos);

if isempty(candidatos)
    error("Boost:TablaNoEncontrada", ...
        ["El archivo MAT no contiene una tabla con Tiempo_s, " ...
         "Duty_pct y VA0_V."])
end

if numel(candidatos) > 1
    error("Boost:TablaAmbigua", ...
        "El archivo contiene mas de una tabla experimental compatible.")
end

datos = contenido.(candidatos{1});

end


function z = simularRespuestaUnitaria(t,u,u0,tau,theta)
%SIMULARRESPUESTAUNITARIA Respuesta FOPDT para una ganancia K unitaria.
%
% La entrada retardada se reconstruye con retencion de orden cero. En cada
% intervalo se usa la solucion exacta del sistema de primer orden.

numeroMuestras = numel(t);
z = zeros(numeroMuestras,1);

tiemposConsulta = t(1:end-1)-theta;
uRetardada = u0*ones(size(tiemposConsulta));
indicesDentro = tiemposConsulta >= t(1);

if any(indicesDentro)
    uRetardada(indicesDentro) = interp1( ...
        t,u,tiemposConsulta(indicesDentro),"previous");
end

for k = 2:numeroMuestras
    dt = t(k)-t(k-1);
    a  = exp(-dt/tau);
    z(k) = a*z(k-1)+(1-a)*(uRetardada(k-1)-u0);
end

end


function metricas = calcularMetricas(y,yModelo)
%CALCULARMETRICAS Calcula indicadores sin modificar el modelo.

residuo = y-yModelo;
SSE = sum(residuo.^2);
SST = sum((y-mean(y)).^2);
denominadorAjuste = norm(y-mean(y));

metricas = struct;
metricas.RMSE_C  = sqrt(mean(residuo.^2));
metricas.MAE_C   = mean(abs(residuo));
metricas.SESGO_C = mean(residuo);
metricas.SSE      = SSE;

if SST > 0
    metricas.R2 = 1-SSE/SST;
else
    metricas.R2 = NaN;
end

if denominadorAjuste > 0
    metricas.Ajuste_pct = ...
        100*(1-norm(residuo)/denominadorAjuste);
else
    metricas.Ajuste_pct = NaN;
end

end

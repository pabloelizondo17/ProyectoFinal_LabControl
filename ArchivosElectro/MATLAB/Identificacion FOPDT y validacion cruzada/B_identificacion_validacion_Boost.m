%% B_identificacion_validacion_Boost.m
% -------------------------------------------------------------------------
% Identificacion FOPDT y validacion cruzada
% del convertidor boost con los dos ensayos multinivel.
%
%Prueba 1: Duty 50 -> 60 -> 75 -> 55 -> 70 -> 50 %
%Prueba 2: Duty 50 -> 70 -> 55 -> 75 -> 60 -> 50 %
%
% Esquema de validacion cruzada:
%modeloPrueba1  (identificado con la prueba 1) -> se valida con la prueba 2
%modeloPrueba2  (identificado con la prueba 2) -> se valida con la prueba 1
%
% Entrada del modelo: Duty_pct (%).  Salida: VA0_V (V), la tension que
% mide el Arduino en A0. Para pasar a la salida del boost: Vo = 5*VA0.
%
% Requiere en la misma carpeta: A5_identificar_FOPDT_Boost.m y
% A6_validar_FOPDT_Boost.m
% -------------------------------------------------------------------------
clear; clc; close all;

%% Archivos (ajustar la carpeta si es necesario)
carpeta = fullfile("..","boost_mega_80kHz","Resultados_experimentos");
archivoPrueba1 = fullfile(carpeta, ...
    "multinivel_boost_mega1erprueba_20261015_154309_858.mat");
archivoPrueba2 = fullfile(carpeta, ...
    "multinivel_boost_mega_2daprueba20261015_154606_986.mat");

%%identificacion
% Se usan variables distintas para no sobrescribir un modelo con el otro.
modeloPrueba1 = A5_identificar_FOPDT_Boost(archivoPrueba1);
guardarFigura(gcf,"ident_FOPDT_prueba1");

modeloPrueba2 = A5_identificar_FOPDT_Boost(archivoPrueba2);
guardarFigura(gcf,"ident_FOPDT_prueba2");

save("modelos_FOPDT_Boost_20261015.mat","modeloPrueba1","modeloPrueba2");

% Tabla de parametros (equivalente a la Tabla 6 de la guia)
tablaParametros = table( ...
    ["Prueba 1";"Prueba 2"], ...
    [modeloPrueba1.Parametros.K_V_por_pct; modeloPrueba2.Parametros.K_V_por_pct], ...
    1e3*[modeloPrueba1.Parametros.Tau_s;   modeloPrueba2.Parametros.Tau_s], ...
    1e3*[modeloPrueba1.Parametros.Theta_s; modeloPrueba2.Parametros.Theta_s], ...
    [modeloPrueba1.Metricas.Ajuste_pct;    modeloPrueba2.Metricas.Ajuste_pct], ...
    VariableNames=["Datos","K_V_por_pct","Tau_ms","Theta_ms","Ajuste_pct"]);
disp(tablaParametros)

%%validacion cruzada (modelos FIJOS, no se reoptimizan)
validacionP1enP2 = A6_validar_FOPDT_Boost(modeloPrueba1,archivoPrueba2);
guardarFigura(gcf,"valcruz_modeloP1_en_P2");

validacionP2enP1 = A6_validar_FOPDT_Boost(modeloPrueba2,archivoPrueba1);
guardarFigura(gcf,"valcruz_modeloP2_en_P1");

disp("Modelo prueba 1 -> datos prueba 2"); disp(validacionP1enP2.Metricas)
disp("Modelo prueba 2 -> datos prueba 1"); disp(validacionP2enP1.Metricas)

save("validaciones_FOPDT_Boost_20261015.mat", ...
    "modeloPrueba1","modeloPrueba2","validacionP1enP2","validacionP2enP1");



function guardarFigura(fig,nombre)
% Guarda la figura en la carpeta del informe (crear la carpeta si no existe)
    carpetaFig = fullfile("..","Fig","Ident_FOPDT");
    if ~isfolder(carpetaFig); mkdir(carpetaFig); end
    try
        exportgraphics(fig,fullfile(carpetaFig,nombre+".pdf"),ContentType="vector");
    catch
        saveas(fig,fullfile(carpetaFig,nombre+".png"));
    end
end

%% graficar_PIL_limites.m
% Genera las figuras del PIL con limites a partir de Resultado_PIL_limites.mat
% y del banco de pruebas. No necesita el Arduino.
function graficar_PIL_limites
    cd(fileparts(mfilename('fullpath')));
    datos = load('Resultado_PIL_limites.mat', 'resultados');
    r = datos.resultados.saturacion;
    t = 1e3*r.t;

    f1 = figure('Name', 'Normal vs PIL con saturacion', 'Color', 'w');
    subplot(2,1,1);
    plot(t, r.Vo_Normal, 'b', t, r.Vo_PIL, 'r--');
    grid on; ylabel('V_o (V)'); legend('Normal', 'PIL', 'Location', 'best');
    title('Comparacion Normal-PIL con saturacion');
    subplot(2,1,2);
    plot(t, r.Duty_Normal, 'b', t, r.Duty_PIL, 'r--');
    grid on; xlabel('Tiempo (ms)'); ylabel('Duty (%)'); legend('Normal', 'PIL', 'Location', 'best');
    exportgraphics(f1, 'Normal_vs_PIL_saturacion.pdf');

    f2 = figure('Name', 'Diferencias con saturacion', 'Color', 'w');
    subplot(2,1,1);
    plot(t, r.Vo_PIL - r.Vo_Normal, 'k');
    grid on; ylabel('\DeltaV_o (V)'); title('Diferencias PIL - Normal con saturacion');
    subplot(2,1,2);
    plot(t, r.Duty_PIL - r.Duty_Normal, 'k');
    grid on; xlabel('Tiempo (ms)'); ylabel('\DeltaDuty (%)');
    exportgraphics(f2, 'Diferencias_PIL_saturacion.pdf');

    banco = 'Boost_LQR_lim';
    load_system(banco);
    print(['-s' banco], '-dpdf', '-painters', 'Banco_Normal_PIL_limites.pdf');
    close_system(banco, 0);
    fprintf('Figuras generadas.\n');
end

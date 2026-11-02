%% verificar_limites_MIL.m
% Evaluacion MIL del controlador con limites, con ambas ramas en modo Normal.
%  1) Regresion: sin saturar debe coincidir exactamente con el controlador
%     sin limites, cuyos resultados estan en Resultado_PIL_LQR.mat.
%  2) Saturacion: compara el caso con anti-windup y sin anti-windup.
function verificar_limites_MIL
    cd(fileparts(mfilename('fullpath')));
    banco = 'Boost_LQR_lim';
    load_system(banco);
    limpiar = onCleanup(@() bdclose(banco));
    enNormal = {[banco '/Controller_PIL'], 'SimulationMode', 'Normal'};

    %% 1) Regresion
    in = escenario_limites("nominal").setBlockParameter(enNormal{:});
    out = sim(in);
    ref = load('Resultado_PIL_LQR.mat', 'Vo_Normal', 'Duty_Normal');
    igualV = isequal(double(out.Vo_Normal.Data(:)), double(ref.Vo_Normal.Data(:)));
    igualD = isequal(double(out.Duty_Normal.Data(:)), double(ref.Duty_Normal.Data(:)));
    fprintf('\n--- Regresion frente al controlador sin limites (10 -> 12 V) ---\n');
    fprintf('Max. |dVo| = %.6g V,  Max. |dDuty| = %.6g %%,  Igualdad exacta: %d\n', ...
        max(abs(double(out.Vo_Normal.Data(:)) - double(ref.Vo_Normal.Data(:)))), ...
        max(abs(double(out.Duty_Normal.Data(:)) - double(ref.Duty_Normal.Data(:)))), ...
        igualV && igualD);

    %% 2) Saturacion con y sin anti-windup
    in = escenario_limites("saturacion").setBlockParameter(enNormal{:});
    conAW = sim(in);
    sinAW = sim(in.setVariable('AW_activo', 0));
    t = conAW.Vo_Normal.Time;

    fprintf('\n--- Saturacion: 10 -> 22 -> 6 -> 12 V ---\n');
    fprintf('Duty aplicado con AW: %.2f a %.2f %%,  sin AW: %.2f a %.2f %%\n', ...
        min(conAW.Duty_Normal.Data), max(conAW.Duty_Normal.Data), ...
        min(sinAW.Duty_Normal.Data), max(sinAW.Duty_Normal.Data));
    fprintf('%-20s %16s %16s\n', 'Recuperacion', 'Con AW [ms]', 'Sin AW [ms]');
    fprintf('%-20s %16.2f %16.2f\n', 'Tras bajar a 6 V', ...
        1e3*salidaDelLimite(t, conAW, 0.075, 82), 1e3*salidaDelLimite(t, sinAW, 0.075, 82));
    fprintf('%-20s %16.2f %16.2f\n', 'Tras subir a 12 V', ...
        1e3*salidaDelLimite(t, conAW, 0.125, 45), 1e3*salidaDelLimite(t, sinAW, 0.125, 45));
    fprintf('(tiempo que el duty sigue en el limite despues de cambiar la referencia)\n');
    k = t >= 0.125;
    fprintf('Vo maximo tras regresar a 12 V: con AW %.3f V, sin AW %.3f V\n', ...
        max(conAW.Vo_Normal.Data(k)), max(sinAW.Vo_Normal.Data(k)));
    fprintf('Vo final: con AW %.4f V, sin AW %.4f V\n', ...
        conAW.Vo_Normal.Data(end), sinAW.Vo_Normal.Data(end));

    %% Grafica y resultados
    Vref = 10 + 12*(t >= 0.025) - 16*(t >= 0.075) + 6*(t >= 0.125);
    f = figure('Name', 'Limites y anti-windup', 'Color', 'w');
    subplot(2,1,1);
    plot(1e3*t, Vref, 'k:', 1e3*t, conAW.Vo_Normal.Data, 'b', 1e3*t, sinAW.Vo_Normal.Data, 'r--');
    grid on; ylabel('V_o (V)'); title('Saturacion con y sin anti-windup');
    legend('Referencia', 'Con anti-windup', 'Sin anti-windup', 'Location', 'best');
    subplot(2,1,2);
    plot(1e3*t, conAW.Duty_Normal.Data, 'b', 1e3*t, sinAW.Duty_Normal.Data, 'r--');
    grid on; xlabel('Tiempo (ms)'); ylabel('Duty (%)');
    legend('Con anti-windup', 'Sin anti-windup', 'Location', 'best');
    exportgraphics(f, 'Limites_antiwindup_MIL.pdf');

    Vo_conAW = conAW.Vo_Normal;  Duty_conAW = conAW.Duty_Normal;
    Vo_sinAW = sinAW.Vo_Normal;  Duty_sinAW = sinAW.Duty_Normal;
    save('Resultado_MIL_limites.mat', 'Vo_conAW', 'Duty_conAW', 'Vo_sinAW', 'Duty_sinAW', ...
        'igualV', 'igualD');
    fprintf('\nResultados guardados en Resultado_MIL_limites.mat\n');
end

% Tiempo que el duty permanece en el limite despues de t0
function dt = salidaDelLimite(t, out, t0, limite)
    d = out.Duty_Normal.Data(:);
    k0 = find(t >= t0, 1);
    kSale = find(abs(d(k0:end) - limite) > 1e-3, 1);
    if isempty(kSale)
        dt = t(end) - t0;
    else
        dt = t(k0 + kSale - 1) - t0;
    end
end

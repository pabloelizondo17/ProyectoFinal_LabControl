%% prueba_independencia_limites.m
% Prueba diagnostica de la seccion 22.6 de la guia, con Controlador_LQR_lim.
% Comprueba que las ramas Normal y PIL son realmente independientes.
%
% Se suma +0.01 V a Delta_VA0 solo en la rama PIL, sin guardar el modelo, en
% los escenarios nominal y de saturacion:
%  1) PIL perturbado frente a Normal nominal: deben aparecer diferencias.
%  2) PIL perturbado frente al modelo con la misma perturbacion: deben
%     coincidir, porque el codigo debe responder igual que el modelo.
% Al final repite la corrida sin perturbacion con ejecutar_PIL_limites, que
% es el resultado final de la etapa.
%
% Con Vs apagada y D9 y A0 desconectados del Mega.
%
% Uso:  prueba_independencia_limites           % puerto COM automatico
%       prueba_independencia_limites("COM7")   % usa ese puerto
function prueba_independencia_limites(puertoCOM)
    arguments
        puertoCOM (1,1) string = ""
    end
    cd(fileparts(mfilename('fullpath')));
    banco = 'Boost_LQR_lim';
    pert = 0.01;   % V, sobre Delta_VA0
    bdclose(banco);

    % Primero una corrida sin perturbar: deja configurado el puerto COM
    ejecutar_PIL_limites(puertoCOM);
    bdclose(banco);

    %% Corridas con perturbacion, sin guardar el modelo
    load_system(banco);
    limpiar = onCleanup(@() bdclose(banco));   % descarta la perturbacion
    insertarPerturbacion(banco, pert);

    fprintf('\n--- Prueba de independencia (+%.3g V en Delta_VA0, rama PIL) ---\n', pert);
    resultados = struct();
    for esc = ["nominal" "saturacion"]
        r1 = sim(escenario_limites(esc));      % PIL perturbado
        r2 = sim(escenario_limites(esc).setBlockParameter( ...
            [banco '/Controller_PIL'], 'SimulationMode', 'Normal'));   % modelo perturbado

        t = r1.Vo_PIL.Time;
        d1V = dbl(r1.Vo_PIL) - dbl(r1.Vo_Normal);
        d1D = dbl(r1.Duty_PIL) - dbl(r1.Duty_Normal);
        d2V = dbl(r1.Vo_PIL) - dbl(r2.Vo_PIL);
        d2D = dbl(r1.Duty_PIL) - dbl(r2.Duty_PIL);

        fprintf('\nEscenario %s (%d muestras)\n', esc, numel(t));
        fprintf('PIL perturbado - Normal:           max|dVo| = %.6g V,  max|dDuty| = %.6g %%\n', ...
            max(abs(d1V)), max(abs(d1D)));
        fprintf('PIL perturbado - Modelo perturbado: max|dVo| = %.6g V,  max|dDuty| = %.6g %%\n', ...
            max(abs(d2V)), max(abs(d2D)));
        fprintf('Ramas independientes: %d\n', max(abs(d1D)) > 0 && max(abs(d1V)) > 0);
        fprintf('Misma respuesta que el modelo (igualdad exacta): %d\n', ...
            isequal(d2V, zeros(size(d2V))) && isequal(d2D, zeros(size(d2D))));

        resultados.(esc) = struct('t', t, 'd1V', d1V, 'd1D', d1D, 'd2V', d2V, 'd2D', d2D);
        graficar(t, d1V, d1D, d2V, d2D, pert, esc);
    end
    bdclose(banco);
    clear limpiar

    save('Prueba_independencia_limites.mat', 'pert', 'resultados');

    %% Corrida final sin perturbacion, con el modelo tal como esta guardado
    load_system(banco);
    assert(getSimulinkBlockHandle([banco '/Perturb_PIL']) == -1, ...
        'El modelo guardado no debe contener la perturbacion.');
    bdclose(banco);
    fprintf('\n--- Corrida final sin perturbacion ---\n');
    ejecutar_PIL_limites(puertoCOM);
end

function x = dbl(ts)
    x = double(ts.Data(:));
end

function graficar(t, d1V, d1D, d2V, d2D, pert, esc)
    f = figure('Name', "Independencia " + esc, 'Color', 'w');
    subplot(2,1,1);
    plot(1e3*t, d1V, 'k', 1e3*t, d2V, 'r--');
    grid on; ylabel('\DeltaV_o (V)');
    legend('PIL pert. - Normal', 'PIL pert. - Modelo pert.', 'Location', 'best');
    title(sprintf('Perturbacion de +%.3g V en Delta\\_VA0, rama PIL (%s)', pert, esc));
    subplot(2,1,2);
    plot(1e3*t, d1D, 'k', 1e3*t, d2D, 'r--');
    grid on; xlabel('Tiempo (ms)'); ylabel('\DeltaDuty (%)');
    exportgraphics(f, "Prueba_independencia_" + esc + ".pdf");
end

%% Suma la perturbacion entre la planta y la entrada Delta_VA0 de la rama PIL
function insertarPerturbacion(banco, pert)
    dtf = sprintf('Discrete\nTransfer Fcn_PIL');
    delete_line(banco, [dtf '/1'], 'Delta_single_P/1');
    pos = get_param([banco '/Delta_single_P'], 'Position');
    add_block('simulink/Math Operations/Sum', [banco '/Perturb_PIL'], ...
        'Inputs', '++', 'Position', pos + [-60 0 -60 0]);
    add_block('simulink/Sources/Constant', [banco '/Valor_Perturb_PIL'], ...
        'Value', num2str(pert), 'Position', pos + [-130 40 -110 40]);
    add_line(banco, [dtf '/1'], 'Perturb_PIL/1', 'autorouting', 'smart');
    add_line(banco, 'Valor_Perturb_PIL/1', 'Perturb_PIL/2', 'autorouting', 'smart');
    add_line(banco, 'Perturb_PIL/1', 'Delta_single_P/1', 'autorouting', 'smart');
end

%% prueba_independencia_PIL.m
% Prueba diagnostica de la seccion 22.6 de la guia. Comprueba que las ramas
% Normal y PIL son realmente independientes.
%
% Se suma +0.01 V a Delta_VA0 solo en la rama PIL, sin guardar el modelo:
%  1) PIL perturbado frente a Normal nominal: deben aparecer diferencias.
%  2) PIL perturbado frente al modelo con la misma perturbacion: deben
%     coincidir, porque el codigo debe responder igual que el modelo.
%  3) Corrida nominal sin perturbacion: es el resultado final de la etapa
%     y actualiza Resultado_PIL_LQR.mat.
%
% Usa el puerto COM guardado en Controlador_LQR_PIL por la ultima ejecucion.
function prueba_independencia_PIL
    cd(fileparts(mfilename('fullpath')));
    banco = 'Boost_LQR_PIL';
    pert = 0.01;   % V, sobre Delta_VA0
    bdclose(banco);

    %% Corridas con perturbacion
    load_system(banco);
    limpiar = onCleanup(@() bdclose(banco));   % descarta la perturbacion
    insertarPerturbacion(banco, pert);

    r1 = simular(banco);                       % PIL perturbado
    set_param([banco '/Controller_PIL'], 'SimulationMode', 'Normal');
    r2 = simular(banco);                       % modelo con la misma perturbacion
    bdclose(banco);

    %% Criterio 1: la perturbacion debe notarse frente a la rama Normal
    d1V = r1.Vo_PIL - r1.Vo_Normal;
    d1D = r1.Duty_PIL - r1.Duty_Normal;
    independientes = max(abs(d1D)) > 0 && max(abs(d1V)) > 0;

    %% Criterio 2: el codigo debe responder igual que el modelo perturbado
    d2V = r1.Vo_PIL - r2.Vo_PIL;
    d2D = r1.Duty_PIL - r2.Duty_PIL;
    mismaRespuesta = isequal(r1.Vo_PIL, r2.Vo_PIL) && isequal(r1.Duty_PIL, r2.Duty_PIL);

    fprintf('\n--- Prueba de independencia (+%.3g V en Delta_VA0, rama PIL) ---\n', pert);
    fprintf('PIL perturbado - Normal nominal:  max|dVo| = %.6g V,  max|dDuty| = %.6g %%\n', ...
        max(abs(d1V)), max(abs(d1D)));
    fprintf('PIL perturbado - Modelo perturbado: max|dVo| = %.6g V,  max|dDuty| = %.6g %%\n', ...
        max(abs(d2V)), max(abs(d2D)));
    fprintf('Ramas independientes: %d\n', independientes);
    fprintf('Misma respuesta que el modelo (igualdad exacta): %d\n', mismaRespuesta);

    %% Graficas y resultados de la prueba
    f = figure('Name', 'Prueba de independencia', 'Color', 'w');
    subplot(2,1,1);
    plot(1e3*r1.t, d1V, 'k', 1e3*r1.t, d2V, 'r--');
    grid on; ylabel('\DeltaV_o (V)');
    legend('PIL pert. - Normal', 'PIL pert. - Modelo pert.', 'Location', 'best');
    title(sprintf('Perturbacion de +%.3g V en Delta\\_VA0, rama PIL', pert));
    subplot(2,1,2);
    plot(1e3*r1.t, d1D, 'k', 1e3*r1.t, d2D, 'r--');
    grid on; xlabel('Tiempo (ms)'); ylabel('\DeltaDuty (%)');
    exportgraphics(f, 'Prueba_independencia_PIL.pdf');
    save('Prueba_independencia_PIL.mat', 'pert', 'r1', 'r2', 'independientes', 'mismaRespuesta');

    %% Corrida nominal final, con el modelo tal como esta guardado
    load_system(banco);
    assert(getSimulationMode(banco) == "Processor-in-the-loop (PIL)", ...
        'Controller_PIL debe estar en modo PIL.');
    assert(getSimulinkBlockHandle([banco '/Perturb_PIL']) == -1, ...
        'El modelo guardado no debe contener la perturbacion.');
    evalin('base', "sim('" + banco + "');");
    bdclose(banco);
    evalin('base', 'Comparacion_Normal_PIL');

    % El tiempo de ejecucion se conserva junto a los resultados nominales
    if evalin('base', "exist('executionProfile','var')") == 1
        evalin('base', "save('Resultado_PIL_LQR.mat','executionProfile','-append');");
        perfil = evalin('base', 'executionProfile');
        Ts = evalin('base', 'Ts');
        fprintf('\n--- Tiempo de ejecucion en el Mega ---\n');
        for s = perfil.Sections(:).'
            tMax = double(s.MaximumExecutionTimeInTicks)/double(perfil.TimerTicksPerSecond);
            fprintf('%-30s max = %.1f us (%.1f %% de Ts)\n', s.Name, 1e6*tMax, 100*tMax/Ts);
        end
    end
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

%% Simula desde el workspace base y devuelve las senales registradas
function r = simular(banco)
    evalin('base', "sim('" + banco + "');");
    r.t = evalin('base', 'Vo_PIL.Time');
    for n = ["Vo_Normal" "Duty_Normal" "Vo_PIL" "Duty_PIL"]
        r.(n) = double(evalin('base', n + ".Data(:)"));
    end
end

function modo = getSimulationMode(banco)
    modo = string(get_param([banco '/Controller_PIL'], 'SimulationMode'));
end

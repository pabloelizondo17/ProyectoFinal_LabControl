%% ejecutar_PIL_limites.m
% Prueba PIL del controlador con limites en el Arduino Mega 2560. Corre el
% escenario nominal y el de saturacion, compara cada uno con la rama Normal y
% mide el tiempo de ejecucion. Con el boost desconectado del Mega.
%
% Uso:  ejecutar_PIL_limites           % detecta el puerto COM automaticamente
%       ejecutar_PIL_limites("COM7")   % usa ese puerto
function ejecutar_PIL_limites(puertoCOM)
    arguments
        puertoCOM (1,1) string = ""
    end
    cd(fileparts(mfilename('fullpath')));
    ctrl = 'Controlador_LQR_lim';
    banco = 'Boost_LQR_lim';

    % Puerto de comunicacion PIL
    load_system(ctrl);
    cs = getActiveConfigSet(ctrl);
    d = get_param(cs, 'CoderTargetData');
    if strlength(puertoCOM) > 0
        d.HostBoardConnection.PIL_port_source1 = 'Manually Specify';
        d.HostBoardConnection.PIL_COMPort_specify = char(extractAfter(upper(puertoCOM), "COM"));
    else
        d.HostBoardConnection.PIL_port_source1 = 'Automatically';
    end
    set_param(cs, 'CoderTargetData', d);
    save_system(ctrl);

    load_system(banco);
    assert(strcmpi(get_param([banco '/Controller_Normal'], 'SimulationMode'), 'Normal'), ...
        'Controller_Normal debe estar en modo Normal.');
    assert(strcmp(get_param([banco '/Controller_PIL'], 'SimulationMode'), 'Processor-in-the-loop (PIL)'), ...
        'Controller_PIL debe estar en modo PIL.');

    resultados = struct();
    for esc = ["nominal" "saturacion"]
        out = sim(escenario_limites(esc));
        resultados.(esc) = comparar(out, esc);
    end

    save('Resultado_PIL_limites.mat', 'resultados');
    fprintf('\nResultados guardados en Resultado_PIL_limites.mat\n');
end

%% Comparacion muestra a muestra y tiempo de ejecucion
function r = comparar(out, esc)
    tol_V = 1e-3;   tol_D = 1e-3;   % mismas tolerancias que Comparacion_Normal_PIL
    t = out.Vo_Normal.Time;
    assert(isequal(t, out.Vo_PIL.Time, out.Duty_Normal.Time, out.Duty_PIL.Time), ...
        'Los vectores de tiempo no coinciden.');
    Vo_N = double(out.Vo_Normal.Data(:));   Vo_P = double(out.Vo_PIL.Data(:));
    D_N  = double(out.Duty_Normal.Data(:)); D_P  = double(out.Duty_PIL.Data(:));
    assert(all(isfinite([Vo_N; Vo_P; D_N; D_P])), 'Hay valores NaN o Inf.');

    r.t = t;  r.Vo_Normal = Vo_N;  r.Vo_PIL = Vo_P;  r.Duty_Normal = D_N;  r.Duty_PIL = D_P;
    r.maxV = max(abs(Vo_P - Vo_N));  r.maxD = max(abs(D_P - D_N));
    r.rmseV = sqrt(mean((Vo_P - Vo_N).^2));  r.rmseD = sqrt(mean((D_P - D_N).^2));
    r.exacto = isequal(Vo_P, Vo_N) && isequal(D_P, D_N);
    if r.exacto
        r.veredicto = "PASS";
    elseif r.maxV <= tol_V && r.maxD <= tol_D
        r.veredicto = "PASS_TOLERANCIA";
    else
        r.veredicto = "FAIL";
    end

    fprintf('\n--- Normal-PIL, escenario %s (%d muestras) ---\n', esc, numel(t));
    fprintf('Vo:   max = %.6g V,  RMSE = %.6g V\n', r.maxV, r.rmseV);
    fprintf('Duty: max = %.6g %%,  RMSE = %.6g %%\n', r.maxD, r.rmseD);
    fprintf('Duty PIL: %.2f a %.2f %%\n', min(D_P), max(D_P));
    fprintf('Resultado: %s\n', r.veredicto);

    if isprop(out, 'executionProfile') || any(strcmp(out.who, 'executionProfile'))
        perfil = out.executionProfile;
        for s = perfil.Sections(:).'
            tMax = double(s.MaximumExecutionTimeInTicks)/double(perfil.TimerTicksPerSecond);
            fprintf('%-30s max = %.1f us (%.1f %% de 250 us)\n', s.Name, 1e6*tMax, 100*tMax/250e-6);
        end
        r.executionProfile = perfil;
    end
end

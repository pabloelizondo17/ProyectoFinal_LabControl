%% ejecutar_PIL.m
% Ejecuta la prueba PIL del LQR en el Arduino Mega 2560 y la compara con la
% ejecucion Normal. Simulink genera, compila y descarga el codigo; no hace
% falta cargar nada a mano ni ejecutar slbuild antes.
%
% Uso:  ejecutar_PIL           % detecta el puerto COM automaticamente
%       ejecutar_PIL("COM5")   % usa ese puerto (necesario en algunos clones)
function ejecutar_PIL(puertoCOM)
    arguments
        puertoCOM (1,1) string = ""
    end
    cd(fileparts(mfilename('fullpath')));
    ctrl = 'Controlador_LQR_PIL';
    banco = 'Boost_LQR_PIL';

    fprintf('Puertos serie disponibles: %s\n', strjoin(serialportlist("available"), ", "));

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

    % Desde el workspace base, para que las senales queden disponibles ahi
    evalin('base', "sim('" + banco + "');");

    evalin('base', 'Comparacion_Normal_PIL');
    reportarTiempo();
end

%% Tiempo de ejecucion medido en el procesador frente a Ts
function reportarTiempo()
    if evalin('base', "exist('executionProfile','var')") ~= 1
        fprintf('\nNo se genero el perfil de tiempo de ejecucion.\n');
        return
    end
    perfil = evalin('base', 'executionProfile');
    Ts = evalin('base', 'Ts');
    ticksSeg = double(perfil.TimerTicksPerSecond);
    fprintf('\n--- Tiempo de ejecucion en el Mega ---\n');
    for s = perfil.Sections(:).'
        tMax = double(s.MaximumExecutionTimeInTicks)/ticksSeg;
        fprintf('%-30s max = %.1f us (%.1f %% de Ts)\n', s.Name, 1e6*tMax, 100*tMax/Ts);
    end
end

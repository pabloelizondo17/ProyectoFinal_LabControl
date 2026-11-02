%% crear_modelos_PIL.m
% =========================================================================
% Genera los dos modelos de la etapa PIL a partir de los de la etapa SIL,
% sin modificar los archivos de la carpeta SIL:
%
%   Controlador_LQR_PIL.slx : copia de Controlador_LQR_ref con el mismo
%                             algoritmo, en single, C y para el Mega 2560.
%   Boost_LQR_PIL.slx       : banco Normal-PIL con una planta por rama.
%
% Cambios respecto a SIL y por que son necesarios:
%  - single: Simulink declara double de 64 bits para AVR, pero avr-gcc lo
%    compila en 32 bits. Con single ambos lados usan la misma representacion.
%  - C99: avr-libc no proporciona los encabezados C++ <cmath> y <cstring>
%    que incluye el codigo generado en C++.
%  - Ganancias, Ts, estructura y escenario (10 -> 12 V) no cambian.
%
% Sobrescribe los modelos de esta carpeta. Volver a ejecutarlo solo si cambian
% los modelos de SIL o se quiere regenerar en otra version de MATLAB.
% =========================================================================
function crear_modelos_PIL
    aqui = fileparts(mfilename('fullpath'));
    dirSIL = fullfile(aqui, '..', 'SIL');
    cd(aqui);
    bdclose('all');

    crearControlador(dirSIL);
    crearBanco(dirSIL);

    bdclose('all');
    fprintf('Modelos creados en %s\n', aqui);
end

%% Controlador: single, C y Arduino Mega 2560
function crearControlador(dirSIL)
    mdl = 'Controlador_LQR_PIL';
    load_system(fullfile(dirSIL, 'Controlador_LQR_ref.slx'));
    save_system('Controlador_LQR_ref', fullfile(pwd, [mdl '.slx']));

    set_param([mdl '/Error_VA0'],  'OutDataTypeStr', 'single');
    set_param([mdl '/Delta_VA0'],  'OutDataTypeStr', 'single');
    set_param([mdl '/Delta_Duty'], 'OutDataTypeStr', 'single');
    for g = ["Gain2" "Gain3" "Gain4"]
        set_param(mdl + "/" + g, 'OutDataTypeStr', 'Inherit: Same as input', ...
            'ParamDataTypeStr', 'Inherit: Same as input');
    end
    set_param([mdl '/Sum4'], 'OutDataTypeStr', 'single');
    set_param([mdl sprintf('/Discrete-Time\nIntegrator')], 'OutDataTypeStr', 'single');

    set_param(mdl, 'HardwareBoard', 'Arduino Mega 2560');
    set_param(mdl, 'SystemTargetFile', 'ert.tlc');
    set_param(mdl, 'TargetLang', 'C');
    set_param(mdl, 'TargetLangStandard', 'C99 (ISO)');
    set_param(mdl, 'CodeInterfacePackaging', 'Reusable function');
    set_param(mdl, 'ModelReferenceNumInstancesAllowed', 'Multi');
    set_param(mdl, 'PropagateVarSize', 'During execution');
    set_param(mdl, 'StopTime', 'inf');

    % Comunicacion PIL por USB (Serial 0) a 115200 baudios
    cs = getActiveConfigSet(mdl);
    d = get_param(cs, 'CoderTargetData');
    d.HostBoardConnection.PIL_serial_port = 'Serial 0';
    d.HostBoardConnection.PIL_baud = '115200';
    set_param(cs, 'CoderTargetData', d);

    save_system(mdl);
    close_system(mdl);
end

%% Banco Normal-PIL: fuentes compartidas y una planta por rama
function crearBanco(dirSIL)
    mdl = 'Boost_LQR_PIL';
    load_system(fullfile(dirSIL, 'Boost_LQR_SIL.slx'));
    save_system('Boost_LQR_SIL', fullfile(pwd, [mdl '.slx']));

    % Registro en el workspace y medicion del tiempo de ejecucion en el Mega
    set_param(mdl, 'ReturnWorkspaceOutputs', 'off');
    set_param(mdl, 'CodeExecutionProfiling', 'on', ...
        'CodeProfilingSaveOptions', 'SummaryOnly', ...
        'CodeExecutionProfileVariable', 'executionProfile');

    % Rama Normal: la del banco SIL, con otro nombre de bloque y de variables
    set_param([mdl '/Subsystem'], 'Name', 'Controller_Normal');
    rn = [mdl '/Controller_Normal'];
    set_param(rn, 'ModelNameDialog', 'Controlador_LQR_PIL');
    set_param(rn, 'SimulationMode', 'Normal');
    set_param([mdl '/To Workspace3'], 'VariableName', 'Vo_Normal');
    set_param([mdl '/To Workspace4'], 'VariableName', 'Duty_Normal');

    % Conversiones en la frontera del controlador: la planta sigue en double
    dtf = sprintf('Discrete\nTransfer Fcn1');
    insertarEntrada(mdl, 'Sum3', 'Controller_Normal', 1, 'Err_single_N');
    insertarEntrada(mdl, dtf, 'Controller_Normal', 2, 'Delta_single_N');
    insertarSalida(mdl, 'Controller_Normal', 'Duty_double_N');

    % Rama PIL: copia de la planta, las sumas y los registros
    dy = 400;
    dtfP = sprintf('Discrete\nTransfer Fcn_PIL');
    copias = { ...
        'Controller_Normal', 'Controller_PIL'; ...
        'Err_single_N',      'Err_single_P'; ...
        'Delta_single_N',    'Delta_single_P'; ...
        'Duty_double_N',     'Duty_double_P'; ...
        'Sum3',              'Sum3_PIL'; ...
        dtf,                 dtfP; ...
        'Constant2',         'Constant2_PIL'; ...
        'Constant3',         'Constant3_PIL'; ...
        'Sum5',              'Sum5_PIL'; ...
        'Sum6',              'Sum6_PIL'; ...
        'Gain5',             'Gain5_PIL'; ...
        'To Workspace3',     'To Workspace_Vo_PIL'; ...
        'To Workspace4',     'To Workspace_Duty_PIL'};
    for i = 1:size(copias,1)
        src = [mdl '/' copias{i,1}];
        add_block(src, [mdl '/' copias{i,2}], ...
            'Position', get_param(src, 'Position') + [0 dy 0 dy]);
    end
    set_param([mdl '/Controller_PIL'], 'SimulationMode', 'Processor-in-the-loop (PIL)');
    set_param([mdl '/To Workspace_Vo_PIL'], 'VariableName', 'Vo_PIL');
    set_param([mdl '/To Workspace_Duty_PIL'], 'VariableName', 'Duty_PIL');

    lineas = { ...
        'Gain/1',            'Sum3_PIL/1'; ...
        'Sum3_PIL/1',        'Err_single_P/1'; ...
        'Err_single_P/1',    'Controller_PIL/1'; ...
        [dtfP '/1'],         'Delta_single_P/1'; ...
        'Delta_single_P/1',  'Controller_PIL/2'; ...
        'Controller_PIL/1',  'Duty_double_P/1'; ...
        'Duty_double_P/1',   [dtfP '/1']; ...
        'Duty_double_P/1',   'Sum6_PIL/2'; ...
        'Constant3_PIL/1',   'Sum6_PIL/1'; ...
        'Sum6_PIL/1',        'To Workspace_Duty_PIL/1'; ...
        'Constant2_PIL/1',   'Sum5_PIL/1'; ...
        [dtfP '/1'],         'Sum5_PIL/2'; ...
        'Sum5_PIL/1',        'Sum3_PIL/2'; ...
        'Sum5_PIL/1',        'Gain5_PIL/1'; ...
        'Gain5_PIL/1',       'To Workspace_Vo_PIL/1'};
    for i = 1:size(lineas,1)
        add_line(mdl, lineas{i,1}, lineas{i,2}, 'autorouting', 'smart');
    end

    save_system(mdl);
    close_system(mdl);
end

%% Inserta una conversion a single antes de una entrada del controlador
function insertarEntrada(mdl, src, ctrl, puerto, nombre)
    delete_line(mdl, [src '/1'], sprintf('%s/%d', ctrl, puerto));
    pc = get_param([mdl '/' ctrl], 'PortConnectivity');
    p = pc(puerto).Position;
    add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/' nombre], ...
        'OutDataTypeStr', 'single', 'Position', [p(1)-70 p(2)-10 p(1)-30 p(2)+10]);
    add_line(mdl, [src '/1'], [nombre '/1'], 'autorouting', 'smart');
    add_line(mdl, [nombre '/1'], sprintf('%s/%d', ctrl, puerto), 'autorouting', 'smart');
end

%% Inserta una conversion a double a la salida del controlador
function insertarSalida(mdl, ctrl, nombre)
    h = get_param([mdl '/' ctrl], 'LineHandles');
    destinos = get_param(h.Outport(1), 'DstPortHandle');
    delete_line(h.Outport(1));
    pos = get_param([mdl '/' ctrl], 'Position');
    ym = (pos(2) + pos(4))/2;
    add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/' nombre], ...
        'OutDataTypeStr', 'double', 'Position', [pos(3)+10 ym-10 pos(3)+40 ym+10]);
    add_line(mdl, [ctrl '/1'], [nombre '/1'], 'autorouting', 'smart');
    ph = get_param([mdl '/' nombre], 'PortHandles');
    for i = 1:numel(destinos)
        add_line(mdl, ph.Outport(1), destinos(i), 'autorouting', 'smart');
    end
end

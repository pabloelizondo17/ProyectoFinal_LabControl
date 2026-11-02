%% crear_modelos_limites.m
% =========================================================================
% Genera la version del LQR con limites de duty y anti-windup, a partir de
% Controlador_LQR_PIL y Boost_LQR_PIL, sin modificarlos:
%
%   Controlador_LQR_lim.slx : mismo LQR, con saturacion de DeltaD y clamping.
%   Boost_LQR_lim.slx       : banco Normal-PIL con referencia de tres escalones.
%
% Cambios en el controlador:
%  - Saturacion de DeltaD entre DeltaD_min y DeltaD_max (init_BOOT.m).
%  - El Unit Delay de Ku usa el DeltaD ya saturado, que es el aplicado.
%  - Clamping: el integrador se congela si seguir integrando empeora la
%    saturacion. Como -Ki > 0, un error positivo aumenta el duty.
%
% Sobrescribe Controlador_LQR_lim y Boost_LQR_lim.
% =========================================================================
function crear_modelos_limites
    aqui = fileparts(mfilename('fullpath'));
    dirPIL = aqui;
    cd(aqui);
    bdclose('all');

    crearControlador(dirPIL);
    crearBanco(dirPIL);

    bdclose('all');
    fprintf('Modelos creados en %s\n', aqui);
end

%% Controlador con saturacion y clamping
function crearControlador(dirPIL)
    mdl = 'Controlador_LQR_lim';
    load_system(fullfile(dirPIL, 'Controlador_LQR_PIL.slx'));
    save_system('Controlador_LQR_PIL', fullfile(pwd, [mdl '.slx']));
    integ = sprintf('Discrete-Time\nIntegrator');

    % Se retiran las conexiones que cambian
    delete_line(mdl, 'Sum4/1', 'Delta_Duty/1');
    delete_line(mdl, 'Sum4/1', 'Unit Delay/1');
    delete_line(mdl, 'Error_VA0/1', [integ '/1']);

    % Saturacion de la salida
    add_block('simulink/Discontinuities/Saturation', [mdl '/Sat_DeltaD'], ...
        'UpperLimit', 'DeltaD_max', 'LowerLimit', 'DeltaD_min', ...
        'OutDataTypeStr', 'Inherit: Same as input', ...
        'Position', [345 100 375 130]);
    set_param([mdl '/Delta_Duty'], 'Position', [420 108 450 122]);
    add_line(mdl, 'Sum4/1', 'Sat_DeltaD/1', 'autorouting', 'smart');
    add_line(mdl, 'Sat_DeltaD/1', 'Delta_Duty/1', 'autorouting', 'smart');
    add_line(mdl, 'Sat_DeltaD/1', 'Unit Delay/1', 'autorouting', 'smart');

    % Logica de clamping
    x = 20;  y = 280;
    bloque(mdl, 'Constant', 'Cte_max', [x y+60 x+60 y+80], ...
        {'Value', 'DeltaD_max', 'OutDataTypeStr', 'single'});
    bloque(mdl, 'Constant', 'Cte_min', [x y+180 x+60 y+200], ...
        {'Value', 'DeltaD_min', 'OutDataTypeStr', 'single'});
    bloque(mdl, 'Constant', 'Cero', [x y+290 x+60 y+310], ...
        {'Value', '0', 'OutDataTypeStr', 'single'});
    bloque(mdl, 'RelationalOperator', 'u_mayor_max', [140 y+40 170 y+70], {'Operator', '>'});
    bloque(mdl, 'RelationalOperator', 'e_positivo',  [140 y+90 170 y+120], {'Operator', '>'});
    bloque(mdl, 'RelationalOperator', 'u_menor_min', [140 y+160 170 y+190], {'Operator', '<'});
    bloque(mdl, 'RelationalOperator', 'e_negativo',  [140 y+210 170 y+240], {'Operator', '<'});
    bloque(mdl, 'Logic', 'Satura_arriba', [220 y+60 250 y+100], {'Operator', 'AND'});
    bloque(mdl, 'Logic', 'Satura_abajo',  [220 y+180 250 y+220], {'Operator', 'AND'});
    bloque(mdl, 'Logic', 'Satura_empeora', [300 y+120 330 y+160], {'Operator', 'OR'});
    bloque(mdl, 'Constant', 'Cte_AW', [300 y+200 360 y+220], ...
        {'Value', 'AW_activo', 'OutDataTypeStr', 'boolean'});
    bloque(mdl, 'Logic', 'Congelar', [390 y+150 420 y+190], {'Operator', 'AND'});
    bloque(mdl, 'Switch', 'Sw_integrador', [60 170 90 210], {'Criteria', 'u2 ~= 0'});

    conexiones = { ...
        'Sum4/1',          'u_mayor_max/1'; ...
        'Cte_max/1',       'u_mayor_max/2'; ...
        'Error_VA0/1',     'e_positivo/1'; ...
        'Cero/1',          'e_positivo/2'; ...
        'Sum4/1',          'u_menor_min/1'; ...
        'Cte_min/1',       'u_menor_min/2'; ...
        'Error_VA0/1',     'e_negativo/1'; ...
        'Cero/1',          'e_negativo/2'; ...
        'u_mayor_max/1',   'Satura_arriba/1'; ...
        'e_positivo/1',    'Satura_arriba/2'; ...
        'u_menor_min/1',   'Satura_abajo/1'; ...
        'e_negativo/1',    'Satura_abajo/2'; ...
        'Satura_arriba/1', 'Satura_empeora/1'; ...
        'Satura_abajo/1',  'Satura_empeora/2'; ...
        'Satura_empeora/1', 'Congelar/1'; ...
        'Cte_AW/1',        'Congelar/2'; ...
        'Cero/1',          'Sw_integrador/1'; ...
        'Congelar/1',      'Sw_integrador/2'; ...
        'Error_VA0/1',     'Sw_integrador/3'; ...
        'Sw_integrador/1', [integ '/1']};
    for i = 1:size(conexiones,1)
        add_line(mdl, conexiones{i,1}, conexiones{i,2}, 'autorouting', 'smart');
    end

    save_system(mdl);
    close_system(mdl);
end

function bloque(mdl, tipo, nombre, pos, params)
    rutas = struct('Constant', 'simulink/Sources/Constant', ...
        'RelationalOperator', 'simulink/Logic and Bit Operations/Relational Operator', ...
        'Logic', 'simulink/Logic and Bit Operations/Logical Operator', ...
        'Switch', 'simulink/Signal Routing/Switch');
    add_block(rutas.(tipo), [mdl '/' nombre], 'Position', pos, params{:});
end

%% Banco: mismas ramas, otro controlador y referencia de tres escalones
function crearBanco(dirPIL)
    mdl = 'Boost_LQR_lim';
    load_system(fullfile(dirPIL, 'Boost_LQR_PIL.slx'));
    save_system('Boost_LQR_PIL', fullfile(pwd, [mdl '.slx']));

    set_param([mdl '/Controller_Normal'], 'ModelNameDialog', 'Controlador_LQR_lim');
    set_param([mdl '/Controller_PIL'], 'ModelNameDialog', 'Controlador_LQR_lim');
    set_param(mdl, 'StopTime', 'Tfin');

    % Referencia: Vref_0, y escalones en t1, t2 y t3
    h = get_param([mdl '/Step'], 'LineHandles');
    destinos = get_param(h.Outport(1), 'DstPortHandle');
    delete_line(h.Outport(1));
    pos = get_param([mdl '/Step'], 'Position');
    set_param([mdl '/Step'], 'Time', 't1', 'Before', 'Vref_0', 'After', 'Vref_1', ...
        'Position', pos + [-100 -60 -100 -60]);
    add_block([mdl '/Step'], [mdl '/Step2'], 'Time', 't2', 'Before', '0', ...
        'After', 'Vref_2-Vref_1', 'Position', pos + [-100 0 -100 0]);
    add_block([mdl '/Step'], [mdl '/Step3'], 'Time', 't3', 'Before', '0', ...
        'After', 'Vref_3-Vref_2', 'Position', pos + [-100 60 -100 60]);
    add_block('simulink/Math Operations/Sum', [mdl '/Sum_ref'], 'Inputs', '+++', ...
        'IconShape', 'rectangular', 'Position', pos + [-20 -20 0 20]);
    for i = 1:3
        origen = "Step" + string(i);
        if i == 1, origen = "Step"; end
        add_line(mdl, origen + "/1", "Sum_ref/" + string(i), 'autorouting', 'smart');
    end
    ph = get_param([mdl '/Sum_ref'], 'PortHandles');
    for i = 1:numel(destinos)
        add_line(mdl, ph.Outport(1), destinos(i), 'autorouting', 'smart');
    end

    save_system(mdl);
    close_system(mdl);
end

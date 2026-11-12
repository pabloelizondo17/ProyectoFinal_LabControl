classdef PWM80k < matlab.System & coder.ExternalDependency
    %PWM80K PWM de 80 kHz en el pin D9 del Arduino Mega.
    % Entrada: duty en % (0 a 100). Se redondea a pasos de 0,5 %.
    % Uso: bloque "MATLAB System" de Simulink, con System object = PWM80k.
    % Los tres archivos (PWM80k.m, pwm80k.c, pwm80k.h) van en la misma carpeta,
    % y esa carpeta tiene que estar en el path de MATLAB.

    methods (Access = protected)
        function setupImpl(~)
            if coder.target('Rtw')
                coder.cinclude('pwm80k.h');
                coder.ceval('pwm80k_iniciar');
            end
        end

        function stepImpl(~, duty)
            cuentas = uint8(min(max(single(duty), 0), 100) * 2);
            if coder.target('Rtw')
                coder.ceval('pwm80k_fijar', cuentas);
            end
        end

        function releaseImpl(~)
            % Al detener el modelo, D9 queda en bajo (MOSFET apagado)
            if coder.target('Rtw')
                coder.ceval('pwm80k_fijar', uint8(0));
            end
        end

        function n = getNumOutputsImpl(~)
            n = 0;
        end
    end

    methods (Static, Access = protected)
        function modo = getSimulateUsingImpl
            modo = 'Interpreted execution';
        end
    end

    methods (Static)
        function nombre = getDescriptiveName(~)
            nombre = 'PWM80k';
        end

        function tf = isSupportedContext(~)
            tf = true;
        end

        function updateBuildInfo(buildInfo, contexto)
            if contexto.isCodeGenTarget('rtw')
                carpeta = fileparts(mfilename('fullpath'));
                buildInfo.addIncludePaths(carpeta);
                buildInfo.addSourceFiles('pwm80k.c', carpeta);
            end
        end
    end
end

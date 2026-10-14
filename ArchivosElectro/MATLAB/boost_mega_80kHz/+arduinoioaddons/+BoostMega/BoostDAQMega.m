classdef BoostDAQMega < matlabshared.addon.LibraryBase
    % Timer2: D9, 80 kHz. ADC: A0. Exclusivo, sin tone ni otras bibliotecas.
    properties (Access = protected, Constant = true)
        LibraryName = 'BoostMega/BoostDAQMega'
        DependentLibraries = {}
        LibraryHeaderFiles = {}
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'BoostDAQMega.h')
        CppClassName = 'BoostDAQMega'
    end
    methods
        function obj = BoostDAQMega(parentObj)
            obj.Parent = parentObj;
            obj.exchange(0, []);
        end
        function off(obj)
            obj.exchange(1, []);
        end
        function testPWM(obj, duty_pct)
            validateattributes(duty_pct, {'numeric'}, {'scalar','real','finite','>=',0,'<=',75});
            obj.exchange(2, uint8(round(2*duty_pct)));
            % El dispositivo apaga D9 automaticamente tras 5 segundos.
        end
        function out = capture(obj, duty_pct, samples, Ts_us, cutoff, settle_ms)
            validateattributes(duty_pct, {'numeric'}, {'vector','real','finite','>=',50,'<=',75});
            validateattributes(samples, {'numeric'}, {'vector','integer','positive','finite'});
            validateattributes(Ts_us, {'numeric'}, {'scalar','integer','>=',250,'<=',2000});
            validateattributes(cutoff, {'numeric'}, {'scalar','integer','>=',1,'<=',1022});
            validateattributes(settle_ms, {'numeric'}, {'scalar','integer','>=',0,'<=',2000});
            K = numel(duty_pct);
            assert(K == numel(samples) && K <= 8, 'Use de 1 a 8 tramos con igual numero de duraciones.');
            assert(sum(samples) <= 800 && sum(samples)*Ts_us <= 240000, ...
                'Maximo 800 muestras y 240 ms por captura. Reduzca niveles/duraciones o aumente Ts.');
            n = round(2*duty_pct);
            msg = [uint8(K), obj.u16(Ts_us), obj.u16(cutoff), obj.u16(settle_ms)];
            for j = 1:K
                msg = [msg uint8(n(j)) obj.u16(samples(j))]; %#ok<AGROW>
            end
            r = obj.exchange(3, msg);
            assert(numel(r)==5+2*K, 'Cabecera de captura incompleta.');
            out.status = double(r(1));
            out.N = obj.word(r(2:3));
            assert(out.N<=sum(samples), 'Cantidad de muestras no valida.');
            out.maxLate_us = obj.word(r(4:5));
            out.changeWrite_s = zeros(K,1);
            for j=1:K
                z = obj.word(r(6+2*(j-1):7+2*(j-1)));
                if z == 65535, out.changeWrite_s(j)=NaN;
                else, out.changeWrite_s(j)=z*4e-6; end
            end
            out.adc = zeros(out.N,1); out.t = zeros(out.N,1);
            % Transferencia posterior: ninguna comunicacion durante el registro.
            for first = 0:12:out.N-1
                count = min(12,out.N-first);
                r = obj.exchange(4,[obj.u16(first) uint8(count)]);
                assert(numel(r)==4*count, 'Respuesta de datos incompleta.');
                for j=1:count
                    q=4*(j-1);
                    out.adc(first+j)=obj.word(r(q+1:q+2));
                    out.t(first+j)=obj.word(r(q+3:q+4))*4e-6;
                end
            end
            out.duty_pct = repelem(n(:)/2,samples(:));
            out.duty_pct = out.duty_pct(1:out.N);
            out.Ts_requested = Ts_us*1e-6;
        end
    end
    methods (Access = private)
        function r = exchange(obj, cmd, bytes)
            r = uint8(sendCommand(obj,obj.LibraryName,cmd,uint8(bytes),10));
            r = r(:).';
            if numel(r)==1 && r(1)>=240
                error('Boost:Device','Error del dispositivo: %d',r(1));
            end
        end
    end
    methods (Static, Access = private)
        function b = u16(x)
            b=uint8([mod(double(x),256), floor(double(x)/256)]);
        end
        function x = word(b)
            x=double(b(1))+256*double(b(2));
        end
    end
end

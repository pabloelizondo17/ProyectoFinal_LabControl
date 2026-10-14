function varargout = boost_io(accion, varargin)
% BOOST_IO  Enlace serie MATLAB <-> Arduino (firmware boost_identificacion.ino)
%
%   [s, info] = boost_io('abrir', puerto)          abre el puerto y consulta limites
%   adc_medio = boost_io('set', s, n)              rampa a D = n/200, devuelve ADC medio
%   [y, abortado] = boost_io('run', s, div, N, dur, nv)   ejecuta un ensayo
%   boost_io('off', s)                             apaga el PWM
%
% Requiere MATLAB R2019b o posterior (serialport).

switch lower(accion)

    case 'abrir'
        puerto = varargin{1};
        s = serialport(puerto, 115200);
        configureTerminator(s, "LF");
        s.Timeout = 5;
        pause(2.5);                         % el Arduino se reinicia al abrir el puerto
        flush(s);
        writeline(s, "P");
        r = split(strtrim(readline(s)));
        if numel(r) < 6 || r(1) ~= "BOOST"
            error('boost_io:enlace', 'El Arduino no respondio como se esperaba: %s', strjoin(r, " "));
        end
        info.Nmax = str2double(r(3));
        info.Kmax = str2double(r(4));
        info.Dmax = str2double(r(5));
        info.TOP  = str2double(r(6));
        varargout = {s, info};

    case 'set'
        s = varargin{1};  n = varargin{2};
        s.Timeout = 20;                     % la rampa tarda hasta ~2 s
        writeline(s, sprintf("S %d", n));
        r = split(strtrim(readline(s)));
        s.Timeout = 5;
        if r(1) ~= "OK"
            error('boost_io:set', 'Arduino respondio: %s', strjoin(r, " "));
        end
        varargout{1} = str2double(r(3)) / 32;     % ADC medio [cuentas]

    case 'run'
        [s, div, N, dur, nv] = varargin{:};
        K = numel(dur);
        par = [dur(:)'; nv(:)'];
        writeline(s, sprintf("R %d %d %d%s", div, N, K, sprintf(" %d %d", par)));
        s.Timeout = 20;
        h = split(strtrim(readline(s)));
        if h(1) ~= "DATA"
            s.Timeout = 5;
            error('boost_io:run', 'Arduino respondio: %s', strjoin(h, " "));
        end
        ns = str2double(h(2));
        abortado = str2double(h(4)) ~= 0;
        y = read(s, ns, "uint16");
        fin = strtrim(readline(s));
        s.Timeout = 5;
        if fin ~= "END"
            warning('boost_io:fin', 'Cierre de trama inesperado: "%s"', fin);
        end
        varargout = {double(y(:)), abortado};

    case 'off'
        s = varargin{1};
        writeline(s, "O");
        try, readline(s); catch, end

    otherwise
        error('boost_io:accion', 'Accion desconocida: %s', accion);
end
end

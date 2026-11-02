%% Comparacion_Normal_PIL.m
% Comparacion back-to-back entre el controlador en modo Normal y su codigo
% ejecutado en el Arduino Mega. Usa las senales que deja Boost_LQR_PIL en el
% workspace: Vo_Normal, Duty_Normal, Vo_PIL y Duty_PIL.
%
% Resultado:
%   PASS             igualdad exacta muestra a muestra (criterio de la guia)
%   PASS_TOLERANCIA  no hay igualdad exacta, pero el error es despreciable
%   FAIL             el error supera las tolerancias

% Tolerancias: muy por debajo de la resolucion real del sistema, que es
% 0.5 % de duty (PWM de 200 pasos) y ~24 mV de Vo (1 LSB del ADC en A0, con
% Vo = 5*VA0). Solo se usan si no hay igualdad exacta.
tol_V = 1e-3;   % V
tol_D = 1e-3;   % puntos porcentuales

nombres = ["Vo_Normal" "Duty_Normal" "Vo_PIL" "Duty_PIL"];
for n = nombres
    assert(evalin('base', "exist('" + n + "','var')") == 1, ...
        "Falta la senal %s. Ejecute primero Boost_LQR_PIL.", n);
    s.(n) = evalin('base', n);
    assert(isa(s.(n), 'timeseries'), "%s debe ser timeseries.", n);
    assert(all(isfinite(s.(n).Data(:))), "%s contiene NaN o Inf.", n);
end

t = s.Vo_Normal.Time;
for n = nombres(2:end)
    assert(isequal(t, s.(n).Time), "El vector de tiempo de %s no coincide.", n);
    assert(numel(s.Vo_Normal.Data) == numel(s.(n).Data), "Dimensiones distintas en %s.", n);
end
assert(numel(t) == 201, "Se esperaban 201 muestras y hay %d.", numel(t));
assert(t(1) == 0 && abs(t(end) - 0.05) < 1e-9, "El intervalo no es 0-0.05 s.");

Vo_N = double(s.Vo_Normal.Data(:));   Vo_P = double(s.Vo_PIL.Data(:));
D_N  = double(s.Duty_Normal.Data(:)); D_P  = double(s.Duty_PIL.Data(:));
error_V = Vo_P - Vo_N;
error_D = D_P - D_N;

[maxV, iV] = max(abs(error_V));
[maxD, iD] = max(abs(error_D));
rmseV = sqrt(mean(error_V.^2));
rmseD = sqrt(mean(error_D.^2));
exactoV = isequal(Vo_P, Vo_N);
exactoD = isequal(D_P, D_N);

if exactoV && exactoD
    veredicto = "PASS";
elseif maxV <= tol_V && maxD <= tol_D
    veredicto = "PASS_TOLERANCIA";
else
    veredicto = "FAIL";
end

fprintf('\n--- Comparacion Normal-PIL (%d muestras) ---\n', numel(t));
fprintf('%-6s %14s %12s %14s %8s\n', 'Senal', 'Max. absoluto', 't max [ms]', 'RMSE', 'Exacta');
fprintf('%-6s %14.6g %12.2f %14.6g %8d\n', 'Vo', maxV, 1e3*t(iV), rmseV, exactoV);
fprintf('%-6s %14.6g %12.2f %14.6g %8d\n', 'Duty', maxD, 1e3*t(iD), rmseD, exactoD);
fprintf('Resultado global: %s\n', veredicto);

%% Efecto de pasar de double (SIL) a single (PIL)
% Es una diferencia de diseno de la version para el Mega, no un error de PIL.
ref = load(fullfile('..', 'SIL', 'Referencia_MIL_LQR.mat'), 'Vo_MIL', 'Duty_MIL');
dSingleV = max(abs(Vo_N - double(ref.Vo_MIL.Data(:))));
dSingleD = max(abs(D_N - double(ref.Duty_MIL.Data(:))));
fprintf('\nNormal single frente a referencia double (SIL):\n');
fprintf('  Max. |dVo| = %.6g V,  Max. |dDuty| = %.6g %%\n', dSingleV, dSingleD);

%% Graficas
figure('Name', 'Normal vs PIL', 'Color', 'w');
subplot(2,1,1);
plot(1e3*t, Vo_N, 'b', 1e3*t, Vo_P, 'r--');
grid on; ylabel('V_o (V)'); legend('Normal', 'PIL', 'Location', 'southeast');
title('Comparacion Normal-PIL');
subplot(2,1,2);
plot(1e3*t, D_N, 'b', 1e3*t, D_P, 'r--');
grid on; xlabel('Tiempo (ms)'); ylabel('Duty (%)'); legend('Normal', 'PIL', 'Location', 'northeast');

figure('Name', 'Diferencias PIL - Normal', 'Color', 'w');
subplot(2,1,1);
plot(1e3*t, error_V, 'k');
grid on; ylabel('\DeltaV_o (V)'); title('Diferencias PIL - Normal');
subplot(2,1,2);
plot(1e3*t, error_D, 'k');
grid on; xlabel('Tiempo (ms)'); ylabel('\DeltaDuty (%)');

%% Guardar resultados
Resultados_Normal_PIL = struct('maxV', maxV, 'maxD', maxD, 'rmseV', rmseV, 'rmseD', rmseD, ...
    't_maxV', t(iV), 't_maxD', t(iD), 'exactoV', exactoV, 'exactoD', exactoD, ...
    'tol_V', tol_V, 'tol_D', tol_D, 'veredicto', veredicto, ...
    'dSingleV', dSingleV, 'dSingleD', dSingleD);
Vo_Normal = s.Vo_Normal;  Duty_Normal = s.Duty_Normal;
Vo_PIL = s.Vo_PIL;        Duty_PIL = s.Duty_PIL;
save('Resultado_PIL_LQR.mat', 'Vo_Normal', 'Duty_Normal', 'Vo_PIL', 'Duty_PIL', ...
    'Resultados_Normal_PIL');
fprintf('\nResultados guardados en Resultado_PIL_LQR.mat\n');

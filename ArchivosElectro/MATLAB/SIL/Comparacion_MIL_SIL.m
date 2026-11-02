load('Referencia_MIL_LQR.mat', 'Vo_MIL', 'Duty_MIL');
load('Resultado_SIL_LQR.mat', 'Vo_SIL', 'Duty_SIL');

assert(isequal(Vo_MIL.Time, Vo_SIL.Time), ...
    'Los tiempos de voltaje MIL y SIL no coinciden.');
assert(isequal(Duty_MIL.Time, Duty_SIL.Time), ...
    'Los tiempos de duty MIL y SIL no coinciden.');

error_V = double(Vo_SIL.Data(:)) - double(Vo_MIL.Data(:));
error_D = double(Duty_SIL.Data(:)) - double(Duty_MIL.Data(:));

fprintf('Diferencia maxima de voltaje: %.12g V\n', max(abs(error_V)));
fprintf('Diferencia maxima de duty: %.12g puntos porcentuales\n', max(abs(error_D)));

figure;
subplot(2,1,1);
plot(Vo_MIL.Time, Vo_MIL.Data, 'b', ...
    Vo_SIL.Time, Vo_SIL.Data, 'r--');
grid on;
ylabel('Voltaje (V)');
legend('MIL', 'SIL');

subplot(2,1,2);
plot(Duty_MIL.Time, Duty_MIL.Data, 'b', ...
    Duty_SIL.Time, Duty_SIL.Data, 'r--');
grid on;
xlabel('Tiempo (s)');
ylabel('Duty (%)');
legend('MIL', 'SIL');
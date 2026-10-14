function prueba_pwm_boost_mega(b)
%PRUEBA_PWM_BOOST Ejecutar con la etapa de potencia desconectada de D9.
% Verificar cada nivel con osciloscopio: 80 kHz, periodo 12.5 us.
proteccion=onCleanup(@() apagar(b)); %#ok<NASGU>
for duty=[50 62.5 75]
    fprintf('D9: %.1f %% por 4 segundos. Esperado: periodo 12.5 us.\n',duty);
    b.testPWM(duty);
    pause(4);
    b.off(); pause(0.5);
end
fprintf('Prueba terminada. D9 apagado.\n');
end
function apagar(b)
try, b.off(); catch ME, warning('Boost:Apagado','%s',ME.message); end
end

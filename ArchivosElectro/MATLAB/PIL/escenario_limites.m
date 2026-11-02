%% escenario_limites.m
% Crea la entrada de simulacion para el banco Boost_LQR_lim.
%   "nominal"    : 10 -> 12 V en 25 ms, igual que MIL, SIL y PIL. No satura.
%   "saturacion" : 10 -> 22 -> 6 -> 12 V. Alcanza ambos limites y se recupera.
%
% Los 22 V y 6 V son solo de simulacion: estan fuera del rango de 10 a 20 V
% porque se usan para forzar la saturacion del controlador.
function in = escenario_limites(nombre)
    in = Simulink.SimulationInput('Boost_LQR_lim');
    if nombre == "saturacion"
        in = in.setVariable('Vref_1', 22).setVariable('Vref_2', 6).setVariable('Vref_3', 12);
        in = in.setVariable('t1', 0.025).setVariable('t2', 0.075).setVariable('t3', 0.125);
        in = in.setVariable('Tfin', 0.175);
    elseif nombre ~= "nominal"
        error('Escenario desconocido: %s', nombre);
    end
end

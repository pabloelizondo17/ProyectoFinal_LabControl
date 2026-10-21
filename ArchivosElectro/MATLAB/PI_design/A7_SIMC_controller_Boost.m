% ================================================
% Parametros del modelo nominal validado
% El valor de theta se escoge a partir del tiempo
% de muestro, ya que debe de ser mayor a cero.
% ================================================
K     = 0.0662;   % V/%
tau   = 9.10e-04; % s
theta = 2.5e-04;  % s

if theta <= 0
    error("El metodo requiere theta > 0.");
end

% ===========================
% Sintonia PI mediante SIMC
% ===========================
tau_c = 2*theta;
Kp = tau/(K*(tau_c + theta));
Ti = min(tau, 4*(tau_c + theta));
Ki = Kp/Ti;

% --- Controlador PI continuo
Gc = tf([Kp Ki],[1 0]);
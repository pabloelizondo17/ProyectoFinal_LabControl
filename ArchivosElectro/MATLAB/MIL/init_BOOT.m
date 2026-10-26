% Periodo de muestreo: 250 microsegundos
Ts = 250e-6;

% Planta: variacion de VA0 / variacion de duty en %
K   = 0.0662;
tau = 0.910e-3;

Gp = tf(K, [tau 1]);
Gp_d = c2d(Gp, Ts, 'zoh');

[num_Gp_d, den_Gp_d] = tfdata(Gp_d, 'v');

% Ganancias del PI
Kp = 18.328298086606246;
Ki = 20140.98690835851;
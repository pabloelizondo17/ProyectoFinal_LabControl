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


% LQR
% Punto de operacion
D0 = 50;
VA0_0 = 1.87543726;

% Planta nominal
a_LQR = exp(-Ts/0.910e-3);
b_LQR = 0.0662*(1-a_LQR);

% Estados: desviacion VA0, duty anterior e integral del error
A_LQR = [a_LQR, b_LQR, 0;
    0,     0,     0;
    -Ts,   0,     1];

B_LQR = [0; 1; 0];

Q_LQR = diag([1/0.2^2, 1/20^2, 1/(1e-4)^2]);
R_LQR = 1/5^2;

K_LQR = dlqr(A_LQR, B_LQR, Q_LQR, R_LQR);

Kx_LQR = K_LQR(1);
Ku_LQR = K_LQR(2);
Ki_LQR = K_LQR(3);
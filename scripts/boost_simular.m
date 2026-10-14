function [vo, vo0m, iL] = boost_simular(par, p, vs, nv, dur, Ts)
% BOOST_SIMULAR  Modelo promediado no lineal del boost con pérdidas.
%
%   par = [r Vf kL kC]
%     r  : resistencia serie equivalente en la rama del inductor [ohm]
%          (DCR + Ron del MOSFET + ESR efectiva)
%     Vf : caída del diodo [V]
%     kL, kC : factores sobre L y C nominales (tolerancias / valor real)
%
%   L*diL/dt = vs - r*iL - (1-d)*(vo + Vf)
%   C*dvo/dt = (1-d)*iL - vo/Req
%
%   nv, dur : niveles (cuentas) y duración (muestras) de cada tramo; d = n/TOP.
%   Se parte del equilibrio del propio modelo para el primer nivel.
%   vo(k) está en t = (k-1)*Ts y el nivel del tramo se aplica tras la muestra k.

r = par(1);  Vf = par(2);  L = par(3)*p.L;  C = par(4)*p.C;  Req = p.Req;
d0   = nv(1)/p.TOP;
vo0m = (vs - (1-d0)*Vf) / ((1-d0) + r/(Req*(1-d0)));
iL0  = vo0m/(Req*(1-d0));
x    = [iL0; vo0m];

N = sum(dur);  K = numel(dur);
vo = zeros(N,1);  iL = zeros(N,1);
opts = odeset('RelTol',1e-7,'AbsTol',1e-9);
k0 = 0;
for i = 1:K
    d   = nv(i)/p.TOP;
    idx = k0 + (1:dur(i));
    tvec = ((idx(1)-1):idx(end))' * Ts;      % muestras del tramo + inicio del siguiente
    if numel(tvec) == 2, tvec = [tvec(1); mean(tvec); tvec(2)]; end
    f = @(~,z) [(vs - r*z(1) - (1-d)*(z(2)+Vf))/L; ((1-d)*z(1) - z(2)/Req)/C];
    [~, X] = ode45(f, tvec, x, opts);
    iL(idx) = X(1:dur(i), 1);
    vo(idx) = X(1:dur(i), 2);
    x  = X(end, :)';
    k0 = idx(end);
end
end

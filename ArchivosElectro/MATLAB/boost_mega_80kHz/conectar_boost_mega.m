function [a,b] = conectar_boost_mega(puerto,recompilar)
%CONECTAR_BOOST Crea conexion con la biblioteca personalizada, PWM apagado.
% Cerrar previamente cualquier otro objeto arduino o serialport del puerto.
% La primera vez: [a,b] = conectar_boost_mega("COM5",true);
% MATLAB compila y carga codigo en la placa. No requiere Simulink ni un .ino.
if nargin<2, recompilar=false; end
raiz=fileparts(mfilename('fullpath'));
addpath(raiz); % Solo raiz: no agregar directamente carpetas +paquete.
a=arduino(char(puerto),'Mega2560','Libraries',{'BoostMega/BoostDAQMega'}, ...
    'ForceBuildOn',logical(recompilar));
b=addon(a,'BoostMega/BoostDAQMega');
fprintf('Biblioteca conectada. D9 apagado; Timer2 preparado para 80 kHz nominales.\n');
end

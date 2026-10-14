
function guardar_figura(fig, nombre)
    if nargin < 1 || isempty(fig)
        fig = gcf;
    end

    if nargin < 2 || isempty(nombre)
        nombre = 'figura';
    end

    % Asegurar que nombre sea un vector de caracteres
    nombre = char(string(nombre));
    nombre = nombre(:).';
    
    % Crear la carpeta si no existe
    carpeta = 'figuras';
    if ~exist(carpeta, 'dir')
        mkdir(carpeta);
    end

    % Construir la ruta y guardar
    archivo = fullfile(carpeta, [nombre '.png']);
    saveas(fig, archivo);

    fprintf('Figura guardada en: %s\n', archivo);
end

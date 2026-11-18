function accepted = boost_set_reference(value)
folder=fileparts(mfilename('fullpath'));
c=jsondecode(fileread(fullfile(folder,'config.json')));
validateattributes(value,{'numeric'},{'scalar','real','finite','>=',c.vmin,'<=',c.vmax});
assert(bdIsLoaded(c.model),'El modelo no está abierto.');
assert(strcmp(get_param(c.model,'SimulationMode'),'external'), ...
    'Inicie Monitor & Tune antes de enviar la referencia.');
assert(~strcmp(get_param(c.model,'SimulationStatus'),'stopped'), ...
    'Monitor & Tune está detenido.');
assert(strcmp(get_param(c.reference_block,'BlockType'),'Constant'), ...
    'reference_block debe apuntar al bloque Constant de referencia.');
set_param(c.reference_block,'Value',sprintf('%.12g',value));
accepted=value; % Accepted by Simulink; not a measurement of output voltage.
end

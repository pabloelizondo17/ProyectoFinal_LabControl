function boost_prepare
% Run once before Monitor & Tune, after naming the two top-level signals.
folder = fileparts(mfilename('fullpath')); addpath(folder);
c = jsondecode(fileread(fullfile(folder,'config.json')));
load_system(c.model);
assert(strcmp(get_param(c.model,'SimulationStatus'),'stopped'), ...
    'Detenga Monitor & Tune antes de preparar las señales.');
names = {'VA0_GUI','DUTY_GUI'};
ports = zeros(1,2);
for k=1:2
    lines = find_system(c.model,'FindAll','on','SearchDepth',1, ...
        'Type','line','Name',names{k});
    sources = [];
    for j=1:numel(lines)
        p = get_param(lines(j),'SrcPortHandle');
        if p>0, sources(end+1)=p; end %#ok<AGROW>
    end
    sources = unique(sources);
    assert(numel(sources)==1,'Nombre %s ausente o ambiguo en el modelo principal.',names{k});
    ports(k)=sources;
end
for k=1:2
    Simulink.sdi.markSignalForStreaming(ports(k),'on');
    Simulink.sdi.setDataAccess(ports(k),Enable=true, ...
        CallbackFunction="boost_capture",IncludeTime=true, ...
        FunctionParameter=string(k));
end
b.samples = {zeros(0,2),zeros(0,2)}; b.dropped=0;
setappdata(0,'BoostGUIBuffer',b);
if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine(c.session);
else
    fprintf('Sesión ya compartida: %s. Use ese nombre en config.json.\n',matlab.engine.engineName);
end
fprintf('Preparado. Guarde el modelo, inicie Monitor & Tune y conecte Python.\n');
end

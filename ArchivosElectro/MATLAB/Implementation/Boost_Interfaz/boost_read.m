function out = boost_read
folder=fileparts(mfilename('fullpath'));
c=jsondecode(fileread(fullfile(folder,'config.json')));
assert(isappdata(0,'BoostGUIBuffer'),'Ejecute boost_prepare antes de Monitor & Tune.');
b=getappdata(0,'BoostGUIBuffer');
r.va0=b.samples{1}; r.duty=b.samples{2}; r.dropped=b.dropped;
b.samples={zeros(0,2),zeros(0,2)}; setappdata(0,'BoostGUIBuffer',b);
r.status=get_param(c.model,'SimulationStatus');
out=jsonencode(r);
end

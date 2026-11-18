function boost_capture(y,t,channel)
% Host-side callback. Never insert this function in an Arduino MATLAB Function block.
key = 'BoostGUIBuffer';
if ~isappdata(0,key), return; end
b = getappdata(0,key);
k = double(channel);
if ~ismember(k,[1 2]), return; end
t = double(t(:)); y = double(y(:));
if numel(t) ~= numel(y), return; end
ok = isfinite(t) & isfinite(y);
p = [t(ok),y(ok)];
if isempty(p), return; end
if ~isempty(b.samples{k}) && p(1,1) < b.samples{k}(end,1)
    b.samples{k} = zeros(0,2);
end
b.samples{k} = [b.samples{k};p];
if size(b.samples{k},1)>20000
    b.dropped = b.dropped + size(b.samples{k},1)-20000;
    b.samples{k} = b.samples{k}(end-19999:end,:);
end
setappdata(0,key,b);
end

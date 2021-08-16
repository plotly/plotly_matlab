function ss = searchDoc(varargin)
%SEARCHDOC Searches plotly JSON documentation for keywords
if nargin==0
    return;
end

if ~isstruct(varargin{1})
    pr = load('plotly_reference.mat').pr;
else
    pr = varargin{1};
    varargin=varargin(2:end);
end

ss = expandStruct(pr,"pr(1)");
if ~isempty(varargin{1})
    for i = 1:numel(varargin)
        idx = cellfun(@(x) ~isempty(x), regexp(ss,['(\.',varargin{i},')$|(\.',varargin{i},'\.)']));
        ss = ss(idx);
    end
end

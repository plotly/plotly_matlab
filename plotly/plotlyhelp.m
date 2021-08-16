function plotlyref = plotlyhelp(varargin)
% [EX]: plotlyhelp('scatter','fill');

%converts graph_obj_meta.json to struct/cell array and outputs key
plotlyref = load('plotly_reference.mat');
pr = plotlyref.pr; 
pr.online = 'Access the online docs!';

try
    if (nargin==1) && (strcmpi('online',varargin{1}))
        web('http://plot.ly/matlab/','-browser');
    else
        try
            txt = 'plotlyref = pr';
            for i=1:nargin
                txt=[txt,'.',varargin{i}];
            end
            txt = [txt,';'];
            eval(txt);
        catch
            strVec = expandStruct(pr,"pr(1)");
            for i = 1:nargin
                idx = cellfun(@(x) ~isempty(x), regexp(strVec,['(\.',varargin{i},')$|(\.',varargin{i},'\.)']));
                strVec = strVec(idx);
            end
            eval(join(["plotlyref = ",strVec(1),";"],''));
        end
    end
catch
    fprintf('\n\nSorry! We could not find what you were looking for. Please specify a valid Plotly reference.\n\n');
end

end

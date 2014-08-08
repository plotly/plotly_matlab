function plotlyref = plotlyhelp(varargin)
% [EX]: plotlyhelp('scatter','fill'); 
% [TODO]: make graph objects separate classes (a la Python API) 
% [TODO]: better graph object descriptions 
 
%converts graph_obj_meta.json to struct/cell array and outputs key
pr = loadjson(fileread('graph_objs_meta.json'));
pr.online = 'Access the online docs!'; 
%only display relevant fields. 
%plotlyref = struct('scatter',plotlyref.scatter,'bar',plotlyref.bar,...
                %'box',plotlyref.box, 'histogram',plotlyref.histogram, 'heatmap',plotlyref.heatmap, 'contour',plotlyref.contour,... 
                %'layout',plotlyref.layout,'online','Access the online docs!');
try
    switch length(varargin)
        case 0
            plotlyref = pr; 
        case 1
            if(strcmpi('online',varargin{1}));
                web('http://plot.ly/matlab/','-browser')
            else
                plotlyref = pr.(lower(varargin{1})); 
            end 
        case 2
                plotlyref = pr.(lower(varargin{1})).(lower(varargin{2})); 
        case 3 %does the struct nesting ever go beyond 3 ?
                plotlyref = pr.(lower(varargin{1})).(lower(varargin{2})).(lower(varargin{3})); 
    end
    
catch exception
    fprintf('\n\nSorry! We could not find what you were looking for. Please specify a valid Plotly reference.\n\n');
end

end

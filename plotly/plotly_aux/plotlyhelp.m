function plotlyhelp(varargin)
% [EX]: plotlyhelp('scatter','fill'); 
% [TODO]: make graph objects separate classes (a la Python API) 
% [TODO]: better graph object descriptions 
 
%converts graph_obj_meta.json to struct/cell array and outputs key
plotlyref = loadjson(fileread('graph_objs_meta.json'));
%only display relevant fields. 
%plotlyref = struct('scatter',plotlyref.scatter,'bar',plotlyref.bar,...
                %'box',plotlyref.box, 'histogram',plotlyref.histogram, 'heatmap',plotlyref.heatmap, 'contour',plotlyref.contour,... 
                %'layout',plotlyref.layout,'online','Access the online docs!');
try
    switch length(varargin)
        case 0
            plotlyref
        case 1
            if(strcmpi('online',varargin{1}));
                web('http://plot.ly/matlab/','-browser')
            else
                plotlyref.(lower(varargin{1}))
            end 
        case 2
               plotlyref.(lower(varargin{1})).(lower(varargin{2}))
        case 3
                plotlyref.(lower(varargin{1})).(lower(varargin{2})).(lower(varargin{3}))
        case 4
                plotlyref.(lower(varargin{1})).(lower(varargin{2})).(lower(varargin{3})).(lower(varargin{4}))
        %does the struct nesting ever go beyond 5 ?
        case 5
                plotlyref.(lower(varargin{1})).(lower(varargin{2})).(lower(varargin{3})).(lower(varargin{4})).(lower(varargin{5})) 
    end
    
catch exception
    fprintf('\n\nSorry! We could not find what you were looking for. Please specify a valid Plotly reference.\n\n');
end

end

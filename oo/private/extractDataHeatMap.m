function data = extractDataHeatMap(d, xid, yid, CLim, colormap, strip_style)
% extractDataHeatMap - create a data struct for heat maps
%   data = extractDataHeatMap(d, xid, yid, CLim, colormap)
%       d - a data struct from matlab describing a scatter plot
%       xid,yid - reference axis indices
%       CLim - a 1x2 vector of extents of the color map
%       colormap - a kx3 matrix representing the colormap
% 
% For full documentation and examples, see https://plot.ly/api

data = {};

% copy general
if strcmp('on', d.Visible)
    data.visible = true;
else
    data.visible = false;
end

if numel(d.DisplayName)>0
    data.name = parseText(d.DisplayName);
else
    data.showlegend = false;
end

% copy in data type and values
data.type = 'heatmap';
data.showscale = false;

% set reference axis
if xid==1
    xid=[];
end
if yid==1
    yid=[];
end
data.xaxis = ['x' num2str(xid)];
data.yaxis = ['y' num2str(yid)];


%other attributes

data.z = d.CData;

if ~strip_style
    
    data.zmin = CLim(1);
    data.zmax = CLim(2);
    
    data.zauto = false;
    
    data.scl = {};
    for i=1:size(colormap,1)
        data.scl{i} = {(i-1)/(size(colormap,1)-1), parseColor(colormap(i,:))};  
    end
    
    data.colorbar = {};

    
end


end
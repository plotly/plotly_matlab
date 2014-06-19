function [data, layout] = extractDataBar(d, layout, xid, yid, CLim, colormap, strip_style)
% extractDataScatter - create a data struct for scatter plots
%   [data, layout] = extractDataBar(d, layout, xid, yid, CLim, colormap)
%       d - a data struct from matlab describing a scatter plot
%       layout - a layout strcut
%       xid,yid - reference axis indices
%       CLim - a 1x2 vector of extents of the color map
%       colormap - a kx3 matrix representing the colormap
%       data - a data strcut
% 
% For full documentation and examples, see https://plot.ly/api

data = {};

% copy general
data = extractDataGeneral(d, data);

data.x = (d.XData(2,:)+d.XData(3,:))/2;
data.y = d.YData(2,:);

% copy in data type and values
data.type = 'bar';

% set reference axis
if xid==1
    xid=[];
end
if yid==1
    yid=[];
end
data.xaxis = ['x' num2str(xid)];
data.yaxis = ['y' num2str(yid)];

layout.bargap = (d.XData(3,1)-d.XData(2,2))/(d.XData(3,1)-d.XData(2,1));


%other attributes
if ~strip_style
    if isfield(d, 'CData')
        color_ref = d.CData(2,:);
    else
        color_ref = d.Color;
    end
    
    color_field=[];
    if isfield(d, 'Color')
        color_field = d.Color;
    else
        if isfield(d, 'EdgeColor')
            color_field = d.EdgeColor;
        end
    end
    colors = setColorProperty(color_field, color_ref, CLim, colormap);
    if numel(colors{1})>0
        data.marker.line.color = colors{1};
    end
    
    color_field=[];
    if isfield(d, 'Color')
        color_field = d.Color;
    else
        if isfield(d, 'FaceColor')
            color_field = d.FaceColor;
        end
    end
    colors = setColorProperty(color_field, color_ref, CLim, colormap);
    if numel(colors{1})>0
        data.marker.color = colors{1};
    end
    
    data.marker.line.width = d.LineWidth;
    
end

end
function data = extractDataContourMap(d, xid, yid, CLim, colormap, strip_style)
% extractDataContourMap - create a data struct for contour maps
%   data = extractDataContourMap(d, xid, yid, CLim, colormap)
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
data.type = 'contour';
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

data.z = d.ZData;
min_x = min(min(d.XData));
min_y = min(min(d.YData));
max_x = max(max(d.XData));
max_y = max(max(d.YData));

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

%contour attributes
data.autocontour = false;
data.contours = struct( 'start', d.LevelList(1), 'size', d.LevelStep, ...
    'end', d.LevelList(end));

data.dx = (max_x-min_x)/size(d.ZData,1);
data.dy = (max_y-min_y)/size(d.ZData,2);
data.x0 = min_x;
data.y0 = min_y;


end
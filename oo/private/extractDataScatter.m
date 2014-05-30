function data = extractDataScatter(d, xid, yid, CLim, colormap, strip_style)
% extractDataScatter - create a data struct for scatter plots
%   data = extractDataScatter(d, xid, yid, CLim, colormap)
%       d - a data struct from matlab describing a scatter plot
%       xid,yid - reference axis indices
%       CLim - a 1x2 vector of extents of the color map
%       colormap - a kx3 matrix representing the colormap
% 
% For full documentation and examples, see https://plot.ly/api

data = {};

% copy general
data = extractDataGeneral(d, data);

% copy in data type and values
data.type = 'scatter';

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

marker_bool = false;
line_bool = false;
if isfield(d, 'Marker') && ~strcmp('none', d.Marker)
    marker_bool = true;
    if ~strip_style
        marker_str = parseMarker(d,CLim, colormap);
        
        
        if numel(marker_str)~=0
            data.marker = marker_str;
        end
    end
end

if isfield(d, 'LineStyle') && ~strcmp('none', d.LineStyle)
    line_bool = true;
    if ~strip_style
        line_str = parseLine(d);
        
        
        if numel(line_str)~=0
            data.line = line_str;
        end
    end
end

%define mode
if marker_bool && line_bool
    data.mode = 'lines+markers';
else
    if marker_bool
        data.mode = 'markers';
    end
    if line_bool
        data.mode = 'lines';
    end
end

% ERROR BARS
if isfield(d, 'LData')
    data.error_y.type = 'data';
    data.error_y.array = d.LData;
    data.error_y.visible = true;
    if ~strip_style
        if isfield(d, 'Color') && size(d.Color,2)==3
            data.error_y.color = parseColor(d.Color);
        else
            data.error_y.color = 'rgb(100, 100, 100)';
        end
        if isfield(data, 'marker') ...
                && isfield(data.marker, 'line') ...
                && isfield(data.marker.line, 'width')
            data.error_y.thickness = data.marker.line.width;
        end
    end
end



end
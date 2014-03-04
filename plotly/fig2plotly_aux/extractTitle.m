function data = extractTitle(d, xa, ya)
% extractTitle - create an annotation struct for plot titles
%   [data] = extractTitle(d, xa, ya)
%       xa,ya - reference axis structs
%       d - a data struct from matlab describing an annotation
%       data - a plotly annotation struct
% 
% For full documentation and examples, see https://plot.ly/api

data = {};

if numel(d.String)==0
    return
end

% set reference axis
data.xref = 'paper';
data.yref = 'paper';

%TEXT
data.text = parseText(d.String);
if strcmp(d.FontUnits, 'points')
    data.font.size = 1.3*d.FontSize;
end
data.font.color = parseColor(d.Color);
%TODO: add font type

%POSITION
xd_range = xa.domain(2) - xa.domain(1);
yd_range = ya.domain(2) - ya.domain(1);
xr_range = xa.range(2) - xa.range(1);
yr_range = ya.range(2) - ya.range(1);

%use center of bounding box as reference
data.x = xa.domain(1)+ (d.Extent(1)+d.Extent(3)/2 - xa.range(1))*xd_range / xr_range;
data.y = ya.domain(1)+ (d.Extent(2)+d.Extent(4)/2 - ya.range(1))*yd_range / yr_range;

data.align = d.HorizontalAlignment;
data.xanchor = 'middle';
data.yanchor = 'middle';

%ARROW
data.showarrow = false;



end
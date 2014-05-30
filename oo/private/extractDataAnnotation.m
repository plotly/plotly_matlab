function data = extractDataAnnotation(d, xid, yid, strip_style)
% extractDataAnnotation - create a general purpose annotation struct
%   [data] = extractDataAnnotation(d, xid, yid)
%       xid,yid - reference axis indices
%       d - a data struct from matlab describing an annotation
%       data - a plotly annotation struct
% 
% For full documentation and examples, see https://plot.ly/api

data = {};

if numel(d.String)==0
    return
end

% set reference axis
if xid==1
    xid=[];
end
if yid==1
    yid=[];
end
data.xref = ['x' num2str(xid)];
data.yref = ['y' num2str(yid)];

%TEXT
data.text = parseText(d.String);
if ~strip_style
    if strcmp(d.FontUnits, 'points')
        data.font.size = 1.3*d.FontSize;
    end
    data.font.color = parseColor(d.Color);
    %TODO: add font type
end

%POSITION
%use center of bounding box as reference
data.x = d.Extent(1)+d.Extent(3)/2;
data.y = d.Extent(2)+d.Extent(4)/2;
data.align = d.HorizontalAlignment;
data.xanchor = 'center';
data.yanchor = 'middle';

%ARROW
data.showarrow = false;

%TODO: if visible, set ax, ay




end
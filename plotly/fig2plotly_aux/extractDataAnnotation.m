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
data.text = parseLatex(d.String,d);
if ~strip_style
    if strcmp(d.FontUnits, 'points')
        data.font.size = 1.3*d.FontSize;
    end
    data.font.color = parseColor(d.Color);
    %FONT TYPE
    try
        data.font.family = extractFont(d.FontName);
    catch
        display(['We could not find the font family you specified.',...
            'The default font: Open Sans, sans-serif will be used',...
            'See https://www.plot.ly/matlab for more information.']);
        data.font.family = 'Open Sans, sans-serif';
    end
end

%POSITION
%NEW: try bottome left of bounding box as reference. OLD: use center of bounding box as reference
data.x = d.Extent(1);%+d.Extent(3)/2;
data.y = d.Extent(2);%+d.Extent(4)/2;
data.align = d.HorizontalAlignment;
data.xanchor = 'left';
data.yanchor = 'bottom';

%ARROW (NEED TO ADD ANNOTATION.M SUPPORT) 
data.showarrow = false;
%TODO: if visible, set ax, ay (if arrow) 

end
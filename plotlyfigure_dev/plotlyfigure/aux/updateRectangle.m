function obj = updateRectangle(obj, rectIndex)

%----RECTANGLE FIELDS----%

% x - [DONE]
% y - [DONE]
% mode - [DONE]
% name - [DONE]
% text - [NOT SUPPORTED IN MATLAB]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [HANDLED BY ERRORBAR]
% line.color - [DONE]
% line.width - [DONE]
% line.dash - [DONE]
% line.opacity - [NOT SUPPORTED IN MATLAB]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY RECTANGLE]
% fillcolor - [HANDLED BY RECTANGLE]
% opacity - [NOT SUPPORTED IN MATLAB]
% textfont - [NOT SUPPORTED IN MATLAB]
% textposition - [NOT SUPPORTED IN MATLAB]
% xaxis [DONE]
% yaxis [DONE]
% showlegend [DONE]
% stream - [HANDLED BY PLOTLYSTREAM]
% visible [DONE]
% type [DONE]

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(rectIndex).AssociatedAxis);

%-RECTANGLE DATA STRUCTURE- %
rect_data = get(obj.State.Plot(rectIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-RECTANGLE XAXIS-%
obj.data{rectIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-RECTANGLE YAXIS-%
obj.data{rectIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-RECTANGLE TYPE-%
obj.data{rectIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-RECTANGLE X-%
obj.data{rectIndex}.x = [rect_data.Position(1) rect_data.Position(1) ...
                         rect_data.Position(1) + rect_data.Position(3) ...
                         rect_data.Position(1) + rect_data.Position(3) ...
                         rect_data.Position(1)]; 

%-------------------------------------------------------------------------%

%-RECTANGLE X-%
obj.data{rectIndex}.y = [rect_data.Position(2) rect_data.Position(2) + rect_data.Position(4) ...
                         rect_data.Position(2) + rect_data.Position(4) ...
                         rect_data.Position(2) ...
                         rect_data.Position(2)]; 

%-------------------------------------------------------------------------%

%-RECTANGLE NAME-%
obj.data{rectIndex}.name = rect_data.DisplayName;

%-------------------------------------------------------------------------%

%-RECTANGLE MODE-%
obj.data{rectIndex}.mode = 'lines';

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH-%
obj.data{rectIndex}.marker.line.width = rect_data.LineWidth;

if(~strcmp(rect_data.LineStyle,'none'))
    
    %-RECTANGLE LINE COLOR-%
    
    if isnumeric(rect_data.EdgeColor)
        
        col = 255*rect_data.EdgeColor;
        obj.data{rectIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
    else
        switch rect_data.FaceColor
            case 'none'
                obj.data{rectIndex}.line.color = 'rgba(0,0,0,0,)';
        end
    end
    
    
    %-RECTANGLE LINE WIDTH-%
    obj.data{rectIndex}.line.width = rect_data.LineWidth;
    
    %-RECTANGLE LINE DASH-%
    switch rect_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    
    obj.data{rectIndex}.line.dash = LineStyle;
    
end

%-------------------------------------------------------------------------%

%-RECTANGLE FILL-%
obj.data{rectIndex}.fill = 'tonexty';

%-------------------------------------------------------------------------%

%-RECTANGLE FILL COLOR-%
if isnumeric(rect_data.FaceColor)
    
    col = 255*rect_data.FaceColor;
    obj.data{rectIndex}.fillcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch rect_data.FaceColor
        case 'none'
            obj.data{rectIndex}.fillcolor = 'rgba(0,0,0,0,)';
    end
end

%-------------------------------------------------------------------------%

%-RECTANGLE SHOWLEGEND-%
leg = get(rect_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{rectIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-RECTANGLE VISIBLE-%
obj.data{rectIndex}.visible = strcmp(rect_data.Visible,'on');


end
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
    rect_data = obj.State.Plot(rectIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    obj.data{rectIndex}.xaxis = "x" + xsource;
    obj.data{rectIndex}.yaxis = "y" + ysource;
    obj.data{rectIndex}.type = 'scatter';

    obj.data{rectIndex}.x = [rect_data.Position(1) rect_data.Position(1) ...
        rect_data.Position(1) + rect_data.Position(3) ...
        rect_data.Position(1) + rect_data.Position(3) ...
        rect_data.Position(1)];

    obj.data{rectIndex}.y = [rect_data.Position(2) ...
        rect_data.Position(2) + rect_data.Position(4) ...
        rect_data.Position(2) + rect_data.Position(4) ...
        rect_data.Position(2) ...
        rect_data.Position(2)];

    obj.data{rectIndex}.name = rect_data.DisplayName;
    obj.data{rectIndex}.mode = 'lines';
    obj.data{rectIndex}.visible = strcmp(rect_data.Visible,'on');
    obj.data{rectIndex}.fill = 'tonexty';
    obj.data{rectIndex}.line = extractPatchLine(rect_data);
    fill = extractPatchFace(rect_data);
    obj.data{rectIndex}.fillcolor = fill.color;

    switch rect_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{rectIndex}.showlegend = true;
        case "off"
            obj.data{rectIndex}.showlegend = false;
    end
end

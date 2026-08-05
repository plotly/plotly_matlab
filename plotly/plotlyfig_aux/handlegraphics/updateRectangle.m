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

    obj.data{rectIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{rectIndex}.yaxis = sprintf("y%d", ysource);
    obj.data{rectIndex}.type = 'scatter';
tmpPosition = get(rect_data, 'Position');

    obj.data{rectIndex}.x = [tmpPosition(1) tmpPosition(1) ...
        tmpPosition(1) + tmpPosition(3) ...
        tmpPosition(1) + tmpPosition(3) ...
        tmpPosition(1)];

    obj.data{rectIndex}.y = [tmpPosition(2) ...
        tmpPosition(2) + tmpPosition(4) ...
        tmpPosition(2) + tmpPosition(4) ...
        tmpPosition(2) ...
        tmpPosition(2)];

    if isprop(rect_data, 'DisplayName')
        obj.data{rectIndex}.name = get(rect_data, 'DisplayName');
    end
    obj.data{rectIndex}.mode = 'lines';
    obj.data{rectIndex}.visible = strcmp(get(rect_data, 'Visible'),'on');
    obj.data{rectIndex}.fill = 'tonexty';
    obj.data{rectIndex}.line = extractPatchLine(rect_data);
    fill = extractPatchFace(rect_data);
    obj.data{rectIndex}.fillcolor = fill.color;

    obj.data{rectIndex}.showlegend = getShowLegend(rect_data);
end

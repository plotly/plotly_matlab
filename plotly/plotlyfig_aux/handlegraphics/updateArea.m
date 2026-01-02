function data = updateArea(obj,areaIndex)
    % x: ...[DONE]
    % y: ...[DONE]
    % r: ...[NOT SUPPORTED IN MATLAB]
    % t: ...[NOT SUPPORTED IN MATLAB]
    % mode: ...[DONE]
    % name: ...[DONE]
    % text: ...[NOT SUPPORTED IN MATLAB]
    % error_y: ...[HANDLED BY ERRORBAR]
    % error_x: ...[HANDLED BY ERRORBAR]

    %----marker----%
    % color: ...[NA]
    % size: ...[NA]
    % symbol: ...[NA]
    % opacity: ...[NA]
    % sizeref: ...[NA]
    % sizemode: ...[NA]
    % colorscale: ...[NA]
    % cauto: ...[NA]
    % cmin: ...[NA]
    % cmax: ...[NA]
    % outliercolor: ...[NA]
    % maxdisplayed: ...[NA]

    %----marker line----%
    % color: ...[NA]
    % width: ...[NA]
    % dash: ...[NA]
    % opacity: ...[NA]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NA]
    % outlierwidth: ...[NA]

    %----line----%
    % color: .........[TODO]
    % width: .........[TODO]
    % dash: .........[TODO]
    % opacity: .........[TODO]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NA]
    % outlierwidth: ...[NA]

    % textposition: ...[NOT SUPPORTED IN MATLAB]
    % textfont: ...[NOT SUPPORTED IN MATLAB]
    % connectgaps: ...[NOT SUPPORTED IN MATLAB]
    % fill: ...[DONE]
    % fillcolor: ..........[TODO]
    % opacity: ..........[TODO]
    % xaxis: ...[DONE]
    % yaxis: ....[DONE]
    % showlegend: ...[DONE]
    % stream: ...[HANDLED BY PLOTLYSTREAM]
    % visible: ...[DONE]
    % type: ...[DONE]

    %-store original area handle-%
    area_data = obj.State.Plot(areaIndex).Handle;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(areaIndex).AssociatedAxis);

    %-check for multiple axes-%
    if numel(area_data.Parent.YAxis) > 1
        yaxMatch = zeros(1,2);
        for yax = 1:2
            yAxisColor = area_data.Parent.YAxis(yax).Color;
            yaxMatch(yax) = sum(yAxisColor == area_data.FaceColor);
        end
        [~, yaxIndex] = max(yaxMatch);
        [xsource, ysource] = findSourceAxis(obj, axIndex, yaxIndex);
    else
        [xsource, ysource] = findSourceAxis(obj,axIndex);
    end

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;
    data.type = "scatter";
    data.x = area_data.XData;

    prevAreaIndex = find(cellfun(@(x) isfield(x,"fill") ...
            && isequal({x.xaxis x.yaxis},{data.xaxis ...
            data.yaxis}),obj.data(1:areaIndex-1)),1,"last");
    if ~isempty(prevAreaIndex)
        data.y = obj.data{prevAreaIndex}.y + area_data.YData;
    else
        data.y = area_data.YData;
    end

    data.name = area_data.DisplayName;
    data.visible = area_data.Visible == "on";

    if ~isempty(prevAreaIndex)
        data.fill = "tonexty";
    else % first area plot
        data.fill = "tozeroy";
    end

    if isprop(area_data, "LineStyle") && area_data.LineStyle == "none"
        data.mode = "none";
    else
        data.mode = "lines";
    end

    data.line = extractAreaLine(area_data);
    data.fillcolor = extractAreaFace(area_data).color;

    switch area_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            data.showlegend = true;
        case "off"
            data.showlegend = false;
    end
end

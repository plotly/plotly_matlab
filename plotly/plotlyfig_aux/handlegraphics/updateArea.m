function updateArea(obj,areaIndex)
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

    %---------------------------------------------------------------------%

    %-store original area handle-%
    area_data = obj.State.Plot(areaIndex).Handle;

    %---------------------------------------------------------------------%

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(areaIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %---------------------------------------------------------------------%

    obj.data{areaIndex}.xaxis = "x" + xsource;
    obj.data{areaIndex}.yaxis = "y" + ysource;
    obj.data{areaIndex}.type = "scatter";
    obj.data{areaIndex}.x = area_data.XData;

    %---------------------------------------------------------------------%

    %-area y-%
    prevAreaIndex = find(cellfun(@(x) isfield(x,"fill") ...
            && isequal({x.xaxis x.yaxis},{obj.data{areaIndex}.xaxis ...
            obj.data{areaIndex}.yaxis}),obj.data(1:areaIndex-1)),1,"last");
    if ~isempty(prevAreaIndex)
        obj.data{areaIndex}.y = obj.data{prevAreaIndex}.y + area_data.YData;
    else
        obj.data{areaIndex}.y = area_data.YData;
    end

    %---------------------------------------------------------------------%

    obj.data{areaIndex}.name = area_data.DisplayName;
    obj.data{areaIndex}.visible = strcmp(area_data.Visible, "on");

    %---------------------------------------------------------------------%

    %-area fill-%
    if ~isempty(prevAreaIndex)
        obj.data{areaIndex}.fill = "tonexty";
    else % first area plot
        obj.data{areaIndex}.fill = "tozeroy";
    end

    %---------------------------------------------------------------------%

    %-AREA MODE-%
    if isprop(area_data, "LineStyle") ...
            && isequal(area_data.LineStyle, "none")
        obj.data{areaIndex}.mode = "none";
    else
        obj.data{areaIndex}.mode = "lines";
    end

    %---------------------------------------------------------------------%

    %-area line-%
    obj.data{areaIndex}.line = extractAreaLine(area_data);

    %---------------------------------------------------------------------%

    %-area fillcolor-%
    fill = extractAreaFace(area_data);
    obj.data{areaIndex}.fillcolor = fill.color;

    %---------------------------------------------------------------------%

    %-area showlegend-%
    leg = area_data.Annotation;
    legInfo = leg.LegendInformation;

    switch legInfo.IconDisplayStyle
        case "on"
            showleg = true;
        case "off"
            showleg = false;
    end

    obj.data{areaIndex}.showlegend = showleg;
end

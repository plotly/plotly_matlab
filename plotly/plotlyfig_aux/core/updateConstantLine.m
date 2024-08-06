function updateConstantLine(obj,plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    %---------------------------------------------------------------------%

    %-scatter xaxis-%
    obj.data{plotIndex}.xaxis = ["x" num2str(xsource)];

    %---------------------------------------------------------------------%

    %-scatter yaxis-%
    obj.data{plotIndex}.yaxis = ["y" num2str(ysource)];

    %---------------------------------------------------------------------%

    %-scatter type-%
    obj.data{plotIndex}.type = "scatter";

    %---------------------------------------------------------------------%

    %-scatter visible-%
    obj.data{plotIndex}.visible = strcmp(plotData.Visible, "on");

    %---------------------------------------------------------------------%

    %-scatter-%

    xaxis = obj.layout.("xaxis"+xsource);
    yaxis = obj.layout.("yaxis"+ysource);
    value = [plotData.Value plotData.Value];
    if plotData.InterceptAxis == "y"
        obj.data{plotIndex}.x = xaxis.range;
        obj.data{plotIndex}.y = value;
    else
        obj.data{plotIndex}.x = value;
        obj.data{plotIndex}.y = yaxis.range;
    end

    %---------------------------------------------------------------------%

    %-Fro 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    if isfield(plotData,"ZData")
        numbset = unique(plotData.ZData);
        if any(plotData.ZData) && length(numbset)>1
            %-scatter z-%
            obj.data{plotIndex}.z = plotData.ZData;

            %-overwrite type-%
            obj.data{plotIndex}.type = "scatter3d";

            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    %---------------------------------------------------------------------%

    %-scatter name-%
    obj.data{plotIndex}.name = plotData.DisplayName;

    %---------------------------------------------------------------------%

    %-scatter mode-%
    if plotData.Type ~= "constantline" ...
            && ~strcmpi("none", plotData.Marker) ...
            && ~strcmpi("none", plotData.LineStyle)
        mode = "lines+markers";
    elseif plotData.Type ~= "constantline" ...
            && ~strcmpi("none", plotData.Marker)
        mode = "markers";
    elseif ~strcmpi("none", plotData.LineStyle)
        mode = "lines";
    else
        mode = "none";
    end

    obj.data{plotIndex}.mode = mode;

    %---------------------------------------------------------------------%

    %-scatter line-%
    obj.data{plotIndex}.line = extractLineLine(plotData);

    %---------------------------------------------------------------------%

    %-scatter marker-%
    if plotData.Type ~= "constantline"
        obj.data{plotIndex}.marker = extractLineMarker(plotData);
    end

    %---------------------------------------------------------------------%

    %-scatter showlegend-%
    leg = get(plotData.Annotation);
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case "on"
            showleg = true;
        case "off"
            showleg = false;
    end

    obj.data{plotIndex}.showlegend = showleg;
end

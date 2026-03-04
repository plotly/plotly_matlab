function obj = updateSlice(obj, dataIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    xSource = findSourceAxis(obj,axIndex);

    %-update scene-%
    updateScene(obj, dataIndex, ...
        "normFacScale", 0.625, "aspectMultiplier", [1.15 1.0 0.9], ...
        "setTitleFont", false, "handleDatetimeTicks", false)

    %-get trace data-%
    xData = plotData.XData;
    yData = plotData.YData;
    zData = plotData.ZData;
    cData = plotData.CData;

    xDataSurf = zeros(2*(size(xData)-1));
    yDataSurf = zeros(2*(size(xData)-1));
    zDataSurf = zeros(2*(size(xData)-1));
    cDataSurf = zeros(2*(size(xData)-1));

    for n = 1:size(xData,2)-1
        n2 = 2*(n-1) + 1;

        for m = 1:size(xData,1)-1
            m2 = 2*(m-1) + 1;

            xDataSurf(m2:m2+1,n2:n2+1) = xData(m:m+1,n:n+1);
            yDataSurf(m2:m2+1,n2:n2+1) = yData(m:m+1,n:n+1);
            zDataSurf(m2:m2+1,n2:n2+1) = zData(m:m+1,n:n+1);

            if strcmp(plotData.FaceColor, 'flat')
                cDataSurf(m2:m2+1,n2:n2+1) = ones(2,2)*cData(m,n);
            elseif strcmp(plotData.FaceColor, 'interp')
                cDataSurf(m2:m2+1,n2:n2+1) = cData(m:m+1,n:n+1);
            end
        end
    end

    %-set trace-%
    obj.data{dataIndex}.type = 'surface';
    obj.data{dataIndex}.name = plotData.DisplayName;
    obj.data{dataIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{dataIndex}.scene = sprintf('scene%d', xSource);
    obj.data{dataIndex}.showscale = false;
    obj.data{dataIndex}.surfacecolor = cDataSurf;

    %-set trace data-%
    obj.data{dataIndex}.x = xDataSurf;
    obj.data{dataIndex}.y = yDataSurf;
    obj.data{dataIndex}.z = zDataSurf;

    %-update face color-%
    updateSurfaceFaceColor(obj, dataIndex, cDataSurf);

    %-update edge color-%
    if isnumeric(plotData.EdgeColor)
        updateSurfaceEdgeColor(obj, dataIndex);
    end
end

function updateSurfaceEdgeColor(obj, dataIndex)
    %-INITIALIZATIONS-%

    plotData = obj.State.Plot(dataIndex).Handle;

    xData = plotData.XData;
    yData = plotData.YData;
    zData = plotData.ZData;
    edgeColor = plotData.EdgeColor;

    xConst = ( xData(:) - min(xData(:)) ) <= 1e-6;
    yConst = ( yData(:) - min(yData(:)) ) <= 1e-6;

    %-edge lines in x direction-%
    xContourSize = mean(diff(xData(1,:)));
    xContourStart = min(xData(1,:));
    xContourEnd = max(xData(1,:));

    obj.data{dataIndex}.contours.x.show = true;
    obj.data{dataIndex}.contours.x.start = xContourStart;
    obj.data{dataIndex}.contours.x.end = xContourEnd;
    obj.data{dataIndex}.contours.x.size = xContourSize;

    %-edge lines in y direction-%
    yContourSize = mean(diff(yData(:,1)));
    yContourStart = min(yData(:,1));
    yContourEnd = max(yData(:,1));

    obj.data{dataIndex}.contours.y.show = true;
    obj.data{dataIndex}.contours.y.start = yContourStart;
    obj.data{dataIndex}.contours.y.end = yContourEnd;
    obj.data{dataIndex}.contours.y.size = yContourSize;

    %-edge lines in z direction-%

    if all(xConst) || all(yConst)
        zContourSize = mean(diff(zData(1,:)));
        zContourStart = min(zData(1,:));
        zContourEnd = max(zData(1,:));

        obj.data{dataIndex}.contours.z.show = true;
        obj.data{dataIndex}.contours.z.start = zContourStart;
        obj.data{dataIndex}.contours.z.end = zContourEnd;
        obj.data{dataIndex}.contours.z.size = zContourSize;
    end

    %-coloring-%
    stringColor = getStringColor(round(255*edgeColor));

    obj.data{dataIndex}.contours.x.color = stringColor;
    obj.data{dataIndex}.contours.y.color = stringColor;
    obj.data{dataIndex}.contours.z.color = stringColor;
end

function updateSurfaceFaceColor(obj, dataIndex, surfaceColor)
    %-INITIALIZATIONS-%

    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;

    faceColor = plotData.FaceColor;
    cLim = axisData.CLim;
    colorMap = axisData.Colormap;

    obj.data{dataIndex}.cauto = false;
    obj.data{dataIndex}.autocolorscale = false;

    if isnumeric(faceColor)
        numColor = round(255*faceColor);
        stringColor = getStringColor(numColor);

        colorScale{1} = {0, stringColor};
        colorScale{2} = {1, stringColor};
        obj.data{dataIndex}.colorscale = colorScale;
    elseif ismember(faceColor, {'flat', 'interp'})
        nColors = size(colorMap, 1);

        for c = 1:nColors
            stringColor = getStringColor(round(255*colorMap(c,:)));
            colorScale{c} = {(c-1)/(nColors-1), stringColor};
        end

        obj.data{dataIndex}.cmin = cLim(1);
        obj.data{dataIndex}.cmax = cLim(2);
    end

    obj.data{dataIndex}.surfacecolor = surfaceColor;
    obj.data{dataIndex}.colorscale = colorScale;
end

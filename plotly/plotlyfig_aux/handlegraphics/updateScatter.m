function data = updateScatter(obj,plotIndex)
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    plotData = obj.State.Plot(plotIndex).Handle;

    data.mode = "markers";
    data.visible = plotData.Visible == "on";
    data.name = plotData.DisplayName;
    data.marker = extractScatterMarker(plotData);
    [data.x, data.y] = getTraceData2D(plotData);

    isScatter3D = isprop(plotData,"ZData") && ~isempty(plotData.ZData);
    if ~isScatter3D
        data.type = "scatter";
        data.xaxis = "x" + xSource;
        data.yaxis = "y" + ySource;
        updateCategoricalAxis(obj, plotIndex);
    else
        data.type = "scatter3d";
        data.scene = "scene" + xSource;
        updateScene(obj, plotIndex);
        data.z = plotData.ZData;
        data.marker.size = 2*data.marker.size;
    end

    dataTipRows = plotData.DataTipTemplate.DataTipRows;
    dataTipRows = dataTipRows(~ismember({dataTipRows.Label},["Size" "Color" "X" "Y" "Z"]));
    if numel(dataTipRows) > 0
        customLabel = "";
        for i = 1:numel(dataTipRows)
            dataTipRow = dataTipRows(i);
            customLabel = customLabel + arrayfun(@(value) string(dataTipRow.Label) + ": " + string(value) + "<br>", dataTipRow.Value);
        end
        data.hovertext = "X: " + data.x + "<br>" + "Y: " + data.y + "<br>" + customLabel;
        data.hoverinfo = "text";
    end

    data.showlegend = getShowLegend(plotData);
end

function updateScene(obj, dataIndex)
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.("scene" + xSource);

    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    dataAspectRatio = axisData.DataAspectRatio;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition./dataAspectRatio;

    cameraOffset = 0.5;
    normFac = abs(min(cameraEye));
    normFac = normFac / (max(aspectRatio)/min(aspectRatio) + cameraOffset);

    %-aspect ratio-%
    scene.aspectratio.x = 1.0*aspectRatio(1);
    scene.aspectratio.y = 1.0*aspectRatio(2);
    scene.aspectratio.z = 1.0*aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1)/normFac;
    scene.camera.eye.y = cameraEye(2)/normFac;
    scene.camera.eye.z = cameraEye(3)/normFac;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-scene axis configuration-%
    scene.xaxis.range = axisData.XLim;
    scene.yaxis.range = axisData.YLim;
    scene.zaxis.range = axisData.ZLim;

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.ticklabelposition = "outside";
    scene.yaxis.ticklabelposition = "outside";
    scene.zaxis.ticklabelposition = "outside";

    scene.xaxis.title = axisData.XLabel.String;
    scene.yaxis.title = axisData.YLabel.String;
    scene.zaxis.title = axisData.ZLabel.String;

    scene.xaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.yaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.zaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.xaxis.titlefont.size = axisData.XLabel.FontSize;
    scene.yaxis.titlefont.size = axisData.YLabel.FontSize;
    scene.zaxis.titlefont.size = axisData.ZLabel.FontSize;
    scene.xaxis.titlefont.family = matlab2plotlyfont(axisData.XLabel.FontName);
    scene.yaxis.titlefont.family = matlab2plotlyfont(axisData.YLabel.FontName);
    scene.zaxis.titlefont.family = matlab2plotlyfont(axisData.ZLabel.FontName);

    %-tick labels-%
    xTick = axisData.XTick;
    if isduration(xTick) || isdatetime(xTick)
        xTickChar = char(xTick);
        xTickLabel = axisData.XTickLabel;
        for n = 1:length(xTickLabel)
            for m = 1:size(xTickChar, 1)
                if ~isempty(strfind(string(xTickChar(m, :)), xTickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        xTick = datenum(xTick(idx));
    end

    yTick = axisData.YTick;
    if isduration(yTick) || isdatetime(yTick)
        yTickChar = char(yTick);
        yTickLabel = axisData.YTickLabel;
        for n = 1:length(yTickLabel)
            for m = 1:size(yTickChar, 1)
                if ~isempty(strfind(string(yTickChar(m, :)), yTickLabel{n}))
                    idx(n) = m;
                end
            end
        end

        yTick = datenum(yTick(idx));
    end

    zTick = axisData.ZTick;
    if isduration(zTick) || isdatetime(zTick)
        zTickChar = char(zTick);
        zTickLabel = axisData.ZTickLabel;

        for n = 1:length(zTickLabel)
            for m = 1:size(zTickChar, 1)
                if ~isempty(strfind(string(zTickChar(m, :)), zTickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        zTick = datenum(zTick(idx));
    end

    scene.xaxis.tickvals = xTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.yaxis.tickvals = yTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.zaxis.tickvals = zTick;
    scene.zaxis.ticktext = axisData.ZTickLabel;

    scene.xaxis.tickcolor = "rgba(0,0,0,1)";
    scene.yaxis.tickcolor = "rgba(0,0,0,1)";
    scene.zaxis.tickcolor = "rgba(0,0,0,1)";
    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.size = axisData.FontSize;
    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    %-grid-%
    if strcmp(axisData.XGrid, "off")
        scene.xaxis.showgrid = false;
    end
    if strcmp(axisData.YGrid, "off")
        scene.yaxis.showgrid = false;
    end
    if strcmp(axisData.ZGrid, "off")
        scene.zaxis.showgrid = false;
    end

    obj.layout.(sprintf("scene%d", xSource)) = scene;
end

function updateCategoricalAxis(obj, plotIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    plotData = obj.State.Plot(plotIndex).Handle;

    xData = plotData.XData;
    yData = plotData.YData;

    if iscategorical(xData)
        ax = obj.layout.("xaxis" + xSource);
        nTicks = length(ax.ticktext);

        ax.autorange = false;
        ax.range = 0.5 + [0 nTicks];
        ax.type = "linear";
        ax.tickvals = 1:nTicks;

        obj.layout.("xaxis" + xSource) = ax;
    end

    if iscategorical(yData)
        ax = obj.layout.("yaxis " + ySource);
        nTicks = length(ax.ticktext);

        ax.autorange = false;
        ax.range = 0.5 + [0 nTicks];
        ax.type = "linear";
        ax.tickvals = 1:nTicks;

        obj.layout.("yaxis" + ySource) = ax;
    end
end

function [xData, yData] = getTraceData2D(plotData)
    %-initializations-%
    isSwarmchart = isfield(plotData, "XJitter");
    xData = categ2NumData(plotData.XData);
    yData = categ2NumData(plotData.YData);

    %-get 2D trace data-%
    if isSwarmchart
        if ~strcmp(plotData.XJitter, "none")
            xData = setJitData(xData, yData, plotData, "X");
        elseif ~strcmp(plotData.YJitter, "none")
            yData = setJitData(yData, xData, plotData, "Y");
        end
    end
end

function jitData = setJitData(jitData, refData, plotData, axName)
    jitType = plotData.(axName + "Jitter");
    jitWidth = plotData.(axName + "JitterWidth");
    jitUnique = sort(unique(jitData), "ascend");
    jitWeight = getJitWeight(jitData, refData);
    isJitDensity = strcmp(jitType, "density");

    for n = 1:length(jitUnique)
        jitInd = find(jitData == jitUnique(n));

        if length(jitInd) > 1
            jitDataN = getJitData(refData(jitInd), jitWidth, jitType);
            if isJitDensity
                jitDataN = jitWeight(n)*jitDataN;
            end
            jitData(jitInd) = jitData(jitInd) + jitDataN;
        end
    end
end

function jitWeight = getJitWeight(jitData, refData)
    jitUnique = sort(unique(jitData), "ascend");
    for n = 1:length(jitUnique)
        jitInd = find(jitData == jitUnique(n));
        if length(jitInd) > 1
            refDataN = refData(jitInd);
            stdData(n) = std(refDataN(~isnan(refDataN)));
        end
    end
    jitWeight = ( stdData/min(stdData) ).^(-1);
end

function jitData = getJitData(refData, jitWeight, jitType)
    jitData = rand(size(refData)) - 0.5;

    if strcmp(jitType, "density")
        refPoints = linspace(min(refData), max(refData), 2*length(refData));
        [densityData, refPoints] = ksdensity(refData, refPoints);
        densityData = jitWeight * rescale(densityData, 0, 1);
        for n = 1:length(refData)
            [~, refInd] = min(abs(refPoints - refData(n)));
            jitData(n) = jitData(n) * densityData(refInd);
        end
    elseif strcmp(jitType, "rand")
        jitData = jitWeight * jitData;
    elseif strcmp(jitType, "randn")
        jitData = jitWeight * rescale(randn(size(refData)), -0.5, 0.5);
    end
end

function numData = categ2NumData(categData)
    numData = categData;
    if iscategorical(categData)
        [~, ~, numData] = unique(numData);
        numData = numData';
    end
end

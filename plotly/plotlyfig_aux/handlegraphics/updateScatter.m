function data = updateScatter(obj,plotIndex)
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    plotData = obj.State.Plot(plotIndex).Handle;

    data.mode = "markers";
    data.visible = strcmp(get(plotData, 'Visible'), "on");
    data.name = get(plotData, 'DisplayName');
    data.marker = extractScatterMarker(plotData);
    [data.x, data.y] = getTraceData2D(plotData);

    isScatter3D = isprop(plotData,"ZData") && ~isempty(get(plotData, 'ZData'));
    if ~isScatter3D
        data.type = "scatter";
        data.xaxis = sprintf("x%d", xSource);
        data.yaxis = sprintf("y%d", ySource);
        updateCategoricalAxis(obj, plotIndex);
    else
        data.type = "scatter3d";
        data.scene = sprintf("scene%d", xSource);
        updateScene(obj, plotIndex);
        data.z = get(plotData, 'ZData');
        data.marker.size = 2*data.marker.size;
    end

    dataTipRows = [];
    if isprop(plotData, 'DataTipTemplate')
        try
            dataTipRows = plotData.DataTipTemplate.DataTipRows;
        catch
        end
    end
    if ~isempty(dataTipRows)
        dataTipRows = dataTipRows(~ismember({dataTipRows.Label}, {'Size' 'Color' 'X' 'Y' 'Z'}));
        if numel(dataTipRows) > 0
            customLabel = "";
            for i = 1:numel(dataTipRows)
                dataTipRow = dataTipRows(i);
                customLabel = customLabel + arrayfun(@(value) string(dataTipRow.Label) + ": " + string(value) + "<br>", dataTipRow.Value);
            end
            data.hovertext = "X: " + string(data.x(:)) + "<br>" + "Y: " + string(data.y(:)) + "<br>" + customLabel(:);
            data.hoverinfo = "text";
        end
    end

    data.showlegend = getShowLegend(plotData) & ~isempty(get(plotData, 'DisplayName'));
end

function updateCategoricalAxis(obj, plotIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    plotData = obj.State.Plot(plotIndex).Handle;

    xData = get(plotData, 'XData');
    yData = get(plotData, 'YData');

    if isa(xData, "categorical")
        ax = obj.layout.(sprintf("xaxis%d", xSource));
        nTicks = length(ax.ticktext);

        ax.autorange = false;
        ax.range = 0.5 + [0 nTicks];
        ax.type = "linear";
        ax.tickvals = 1:nTicks;

        obj.layout.(sprintf("xaxis%d", xSource)) = ax;
    end

    if isa(yData, "categorical")
        ax = obj.layout.(sprintf("yaxis %d", ySource));
        nTicks = length(ax.ticktext);

        ax.autorange = false;
        ax.range = 0.5 + [0 nTicks];
        ax.type = "linear";
        ax.tickvals = 1:nTicks;

        obj.layout.(sprintf("yaxis%d", ySource)) = ax;
    end
end

function [xData, yData] = getTraceData2D(plotData)
    %-initializations-%
    isSwarmchart = isprop(plotData, 'XJitter');
    xData = categ2NumData(get(plotData, 'XData'));
    yData = categ2NumData(get(plotData, 'YData'));

    %-get 2D trace data-%
    if isSwarmchart
        if ~strcmp(get(plotData, 'XJitter'), "none")
            xData = setJitData(xData, yData, plotData, "X");
        elseif ~strcmp(get(plotData, 'YJitter'), "none")
            yData = setJitData(yData, xData, plotData, "Y");
        end
    end
end

function jitData = setJitData(jitData, refData, plotData, axName)
    jitType = get(plotData, sprintf("%sJitter", axName));
    jitWidth = get(plotData, sprintf("%sJitterWidth", axName));
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
    if isa(categData, "categorical")
        [~, ~, numData] = unique(numData);
        numData = numData';
    end
end

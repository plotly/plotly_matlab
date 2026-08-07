function data = updateLineseries(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;

    %-check for multiple axes-%
    if isprop(get(plotData, 'Parent'), "YAxis") && numel(get(get(plotData, 'Parent'), 'YAxis')) > 1
        yaxMatch = zeros(1,2);
        for yax = 1:2
            tmpYAxis = get(get(plotData, 'Parent'), 'YAxis');
            yAxisColor = get(tmpYAxis(yax), 'Color');
            yaxMatch(yax) = sum(yAxisColor == get(plotData, 'Color'));
        end
        [~, yaxIndex] = max(yaxMatch);
        [xSource, ySource] = findSourceAxis(obj, axIndex, yaxIndex);
    else
        [xSource, ySource] = findSourceAxis(obj,axIndex);
    end

    treatAs = lower(obj.PlotOptions.TreatAs);
    isPolar = ismember('compass', treatAs) || ismember('ezpolar', treatAs);

    % Octave's polar()/rose()/ezpolar() draw the grid and the data
    % into a regular axes; the axes is marked with rtick/ttick
    % properties and the grid lines live in an hggroup tagged
    % "polar_grid"
    isOctavePolar = is_octave() && isprop(get(plotData, 'Parent'), 'rtick');
    isPolar = isPolar || isOctavePolar;

    isPlot3D = isprop(plotData, 'ZData') && ~isempty(get(plotData, 'ZData'));

    xData = get(plotData, 'XData');
    yData = get(plotData, 'YData');

    % rose() draws each petal as a (0,0)-(t,h)-(t+dt,h)-(0,0) loop in
    % both engines; render it as bars so every petal hovers as one unit
    isRose = ~isPlot3D && mod(numel(xData), 4) == 0 ...
        && all(xData(1:4:end) == 0) && all(xData(4:4:end) == 0) ...
        && all(yData(1:4:end) == 0) && all(yData(4:4:end) == 0);

    % MATLAB's compass draws one line per arrow: (0,0) to the tip,
    % back through a barb, to the tip again and out through the other
    % barb, so the tip appears twice
    isCompassArrow = ~isPlot3D && numel(xData) == 5 ...
        && xData(1) == 0 && yData(1) == 0 ...
        && xData(2) == xData(4) && yData(2) == yData(4);

    % feather draws one line per arrow: a base point on the
    % horizontal axis to the tip, back through a barb, to the tip
    % again and out through the other barb, so the tip appears twice
    isFeatherArrow = ~isPlot3D && ~isCompassArrow && ~isRose ...
        && numel(xData) == 5 ...
        && yData(1) == 0 ...
        && xData(2) == xData(4) && yData(2) == yData(4);

    % feather draws a baseline from the first to the last arrow base
    isFeatherBase = ~isPlot3D && ~isCompassArrow && ~isFeatherArrow ...
        && ~isRose && numel(xData) == 2 && all(yData == 0);

    % MATLAB's polar()/ezpolar()/compass()/rose() draw into a
    % regular axes with an equal aspect, symmetric limits and ticks,
    % and a 15% taller y-range for the labels; route them through
    % the polar machinery like Octave's (which marks its axes with
    % rtick).  The axes signature alone suffices — data is not
    % inspected to decide the routing.
    isMatlabPolarAxes = false;
    if ~is_octave() && ~isPolar && ~isPlot3D
        ax = get(plotData, 'Parent');
        xlim = get(ax, 'XLim');
        ylim = get(ax, 'YLim');
        xtick = get(ax, 'XTick');
        ytick = get(ax, 'YTick');
        isMatlabPolarAxes = isequal(get(ax, 'DataAspectRatio'), [1 1 1]) ...
            && xlim(1) == -xlim(2) ...
            && abs(ylim(2) - 1.15*xlim(2)) < 0.05*xlim(2) ...
            && ~isempty(xtick) && ~isempty(ytick) ...
            && xtick(1) == xlim(1) && xtick(end) == xlim(2) ...
            && max(abs(xtick + flip(xtick))) < 1e-9*max(abs(xtick)) ...
            && max(abs(ytick + flip(ytick))) < 1e-9*max(abs(ytick));
    end

    if isPolar
        rData = sqrt(xData.^2 + yData.^2);
        if isOctavePolar
            thetaData = rad2deg(atan2(yData, xData));
        else
            thetaData = atan2(xData, yData);
            thetaData = -(rad2deg(thetaData) - 90);
        end
    elseif isRose || isCompassArrow || isMatlabPolarAxes
        % the rose, the compass arrows and the polar family are lines
        % in a regular axes (no rtick marker); route them through the
        % same polar machinery, with the data laid out in the math
        % angle convention like Octave's
        isPolar = true;
        rData = sqrt(xData.^2 + yData.^2);
        thetaData = rad2deg(atan2(yData, xData));
    end

    if isPlot3D
        zData = get(plotData, 'ZData');
    end

    if isPolar
        data.type = "scatterpolar";
        data.subplot = sprintf("polar%d", xSource+1);
        updatePolarAxesLayout(obj, plotIndex);
    elseif ~isPlot3D
        data.type = "scatter";
        data.xaxis = sprintf("x%d", xSource);
        data.yaxis = sprintf("y%d", ySource);
    else
        data.type = "scatter3d";
        data.scene = sprintf("scene%d", xSource);
        updateScene(obj, plotIndex);
    end

    data.visible = strcmp(get(plotData, 'Visible'), "on");
    data.name = get(plotData, 'DisplayName');
    data.mode = getScatterMode(plotData);

    if isCompassArrow
        data.r = rData(1:2);
        data.theta = thetaData(1:2);
        data.hovertext = {'', sprintf("r: %.2f<br>θ: %.2f", rData(2), thetaData(2))};
        data.hoverinfo = 'text';
    elseif isFeatherArrow
        data.x = xData(1:2);
        data.y = yData(1:2);
        idx = xData(1);
        label = sprintf("(%d) (%.2f, %.2f)", idx, xData(2)-xData(1), yData(2));
        data.hovertext = {label, ''};
        data.hoverinfo = 'text';
    elseif isPolar
        data.r = rData;
        data.theta = thetaData;
    else
        data.x = xData;
        data.y = yData;
        if isPlot3D
            data.z = zData;
            obj.PlotOptions.is3d = true;
        end
    end

    % Handle custom datatip rows
    hasDataTipRows = isprop(plotData, "DataTipTemplate") && isprop(plotData.DataTipTemplate, "DataTipRows");
    if hasDataTipRows
        dataTipRows = plotData.DataTipTemplate.DataTipRows;
        exclude = {'Size' 'Color' 'X' 'Y' 'Z' 'Y Delta'};
        dataTipRows = dataTipRows(~ismember({dataTipRows.Label}, exclude));
        if numel(dataTipRows) > 0
            customLabel = "";
            xDataLabel = "X";
            yDataLabel = "Y";
            for i = 1:numel(dataTipRows)
                dataTipRow = dataTipRows(i);
                if isequal(dataTipRow.Value, "XData")
                    xDataLabel = dataTipRow.Label;
                    continue
                end
                if isequal(dataTipRow.Value, "YData")
                    yDataLabel = dataTipRow.Label;
                    continue
                end
                % only data rows carry numeric values; parameterized
                % functionline rows carry property-name chars ('TData',
                % 'XData'...) that arrayfun would iterate character by
                % character, and spy's rows carry function handles;
                % text rows (dataTipTextRow) carry cell/string values
                if isnumeric(dataTipRow.Value) || islogical(dataTipRow.Value)
                    customLabel = customLabel + arrayfun(@(value) dataTipRow.Label ...
                            + ": " + num2str(value) + "<br>", dataTipRow.Value);
                elseif iscell(dataTipRow.Value) || isstring(dataTipRow.Value)
                    customLabel = customLabel + arrayfun(@(value) dataTipRow.Label ...
                            + ": " + string(value) + "<br>", dataTipRow.Value);
                end
            end
            if isPolar
                data.hovertext = "r: " + data.r(:) + "<br>" + "θ: " + ...
                        data.theta(:) + "<br>";
            elseif isPlot3D
                data.hovertext = xDataLabel + ": " + data.x(:) + "<br>" ...
                               + yDataLabel + ": " + data.y(:) + "<br>" ...
                               + "Z: " + data.z(:) + "<br>";
            else
                data.hovertext = xDataLabel + ": " + data.x(:) + "<br>" ...
                               + yDataLabel + ": " + data.y(:) + "<br>";
            end
            % customLabel stays empty when every row's Value is a
            % function handle (fplot3, spy); appending it would
            % concatenate a 0x0 with the data strings
            if ~isempty(customLabel)
                data.hovertext = data.hovertext + customLabel(:);
            end
            data.hoverinfo = "text";
        end
    end

    data.line = extractLineLine(plotData);
    if isPolar
        data.line.width = data.line.width * 1.5;
    end
    data.marker = extractLineMarker(plotData);
    data.showlegend = getShowLegend(plotData) & ~isempty(get(plotData, 'DisplayName'));

    if isFeatherBase
        data.hoverinfo = 'skip';
    end

    if isRose
        % one bar per petal, centered on the petal's angular span and
        % filled like the native rose (white with the outline color)
        data.type = 'barpolar';
        petalStart = thetaData(2:4:end);
        petalEnd = thetaData(3:4:end);
        % unwrap the petal that crosses the +/-180 boundary (the
        % 180-198 petal reads as 180 to -162)
        crossed = petalEnd < petalStart - 180;
        petalEnd(crossed) = petalEnd(crossed) + 360;
        data.theta = (petalStart + petalEnd) / 2;
        data.r = rData(2:4:end);
        % the bars span the full petal so adjacent bars touch
        data.width = petalEnd - petalStart;

        if is_octave()
            % Octave's rose fills the petals white
            data.marker.color = 'rgb(255,255,255)';
        else
            % MATLAB's rose draws the petals as outlines only
            data.marker.color = 'rgba(0,0,0,0)';
        end
        data.marker.line.color = getStringColor(round(255*get(plotData, 'Color')));
        data.marker.line.width = max(1, 2*get(plotData, 'LineWidth'));
    end

    if (isRose || isCompassArrow || isMatlabPolarAxes) && ~isOctavePolar
        % the plotly polar direction defaults to clockwise; the rose
        % petals and the MATLAB polar family are laid out in the math
        % angle convention
        obj.layout.(data.subplot).angularaxis.direction = 'counterclockwise';
    end

    if isCompassArrow || isFeatherArrow
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        bi = obj.PlotOptions.nPlots;

        if isCompassArrow
            obj.data{bi}.type = 'scatterpolar';
            obj.data{bi}.subplot = data.subplot;
            obj.data{bi}.r = rData(2:5);
            obj.data{bi}.theta = thetaData(2:5);
        else
            obj.data{bi}.type = 'scatter';
            obj.data{bi}.xaxis = data.xaxis;
            obj.data{bi}.yaxis = data.yaxis;
            obj.data{bi}.x = xData(2:5);
            obj.data{bi}.y = yData(2:5);
        end

        obj.data{bi}.mode = 'lines';
        obj.data{bi}.visible = data.visible;
        if isfield(data, 'line')
            obj.data{bi}.line = data.line;
        end
        if isfield(data, 'marker')
            obj.data{bi}.marker = data.marker;
        end
        obj.data{bi}.hoverinfo = 'skip';
        obj.data{bi}.showlegend = false;
    end
end

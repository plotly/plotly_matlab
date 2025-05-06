function obj = updateTernaryColorbar(obj,colorbarIndex)
    % title: ...[DONE]
    % titleside: ...[DONE]
    % titlefont: ...[DONE]
    % thickness: ...[DONE]
    % thicknessmode: ...[DONE]
    % len: ...[DONE]
    % lenmode: ...[DONE]
    % x: ...[DONE]
    % y: ...[DONE]
    % autotick: ...[DONE]
    % nticks: ...[DONE]
    % ticks: ...[DONE]
    % showticklabels: ...[DONE]
    % tick0: ...[DONE]
    % dtick: ...[DONE]
    % ticklen: ...[DONE]
    % tickwidth: ...[DONE]
    % tickcolor: ...[DONE]
    % tickangle: ...[NOT SUPPORTED IN MATLAB]
    % tickfont: ...[DONE]
    % exponentformat: ...[DONE]
    % showexponent: ...[NOT SUPPORTED IN MATLAB]
    % xanchor: ...[DONE]
    % yanchor: ...[DONE]
    % bgcolor: ...[DONE]
    % outlinecolor: ...[DONE]
    % outlinewidth: ...[DONE]
    % borderwidth: ...[NOT SUPPORTED IN MATLAB]
    % bordercolor: ...[NOT SUPPORTED IN MATLAB]
    % xpad: ...[DONE]
    % ypad: ...[DONE]

    %-FIGURE STRUCTURE-%
    figureData = obj.State.Figure.Handle;

    %-PLOT DATA STRUCTURE- %
    try
        colorbarData = obj.State.Colorbar(colorbarIndex).Handle;
    catch
        disp('could not extract ColorBar data');
    end

    %-STANDARDIZE UNITS-%
    colorbarunits = colorbarData.Units;
    obj.State.Colorbar(colorbarIndex).Handle.Units = 'normalized';

    %-colorbar position-%
    colorbar.xanchor = 'left';
    colorbar.yanchor = 'bottom';
    colorbar.x = colorbarData.Position(1)*1.025;
    colorbar.y = colorbarData.Position(2);

    colorbar.exponentformat = obj.PlotlyDefaults.ExponentFormat;

    % get colorbar title and labels
    colorbarTitle = colorbarData.Label;

    if isHG2
        colorbarTitleData = colorbarTitle;
        colorbarYLabel = colorbarTitle;
        colorbarYLabelData = colorbarTitle;
        colorbarXLabelData.String = [];
    else
        colorbarTitleData = colorbarTitle;
        colorbarXLabel = colorbarData.XLabel;
        colorbarXLabelData = colorbarXLabel;
        colorbarYLabel = colorbarData.YLabel;
        colorbarYLabelData = colorbarYLabel;
    end

    %-colorbar title-%
    if ~isempty(colorbarTitleData.String)
        colorbar.title = parseString(colorbarTitleData.String, ...
                colorbarTitleData.Interpreter);
    elseif ~isempty(colorbarXLabelData.String)
        colorbar.title = parseString(colorbarXLabelData.String, ...
                colorbarXLabelData.Interpreter);
    elseif ~isempty(colorbarYLabelData.String)
        colorbar.title = parseString(colorbarYLabelData.String, ...
                colorbarYLabelData.Interpreter);
    end

    %-STANDARDIZE UNITS-%
    titleUnits = colorbarTitleData.Units;
    titleFontUnits = colorbarTitleData.FontUnits;
    yLabelUnits = colorbarYLabelData.Units;
    yLabelFontUnits = colorbarYLabelData.FontUnits;
    colorbarTitle.Units = 'data';
    colorbarYLabel.Units = 'data';
    colorbarYLabel.FontUnits = 'points';

    if ~isHG2
        xLabelUnits = colorbarXLabelData.Units;
        xLabelFontUnits = colorbarXLabelData.FontUnits;
        colorbarTitle.FontUnits = 'points';
        colorbarXLabel.Units = 'data';
        colorbarXLabel.FontUnits = 'points';
    end

    if ~isempty(colorbarTitleData.String)
        if colorbarTitleData.Rotation == 90
            colorbar.titleside = 'right';
        else
            colorbar.titleside = 'top';
        end

        colorbar.titlefont.family = ...
                matlab2plotlyfont(colorbarTitleData.FontName);
        col = round(255*colorbarTitleData.Color);
        colorbar.titlefont.color = getStringColor(col);
        colorbar.titlefont.size = 1.20 * colorbarTitleData.FontSize;
    elseif ~isempty(colorbarXLabelData.String)
        colorbar.titleside = 'right';
        colorbar.titlefont.family = ...
                matlab2plotlyfont(colorbarXLabelData.FontName);
        col = round(255*colorbarXLabelData.Color);
        colorbar.titlefont.color = getStringColor(col);
        colorbar.titlefont.size = 1.20 * colorbarXLabelData.FontSize;
    elseif ~isempty(colorbarYLabelData.String)
        colorbar.titleside = 'bottom';
        colorbar.titlefont.family = ...
                matlab2plotlyfont(colorbarYLabelData.FontName);
        col = round(255*colorbarYLabelData.Color);
        colorbar.titlefont.color = getStringColor(col);
        colorbar.titlefont.size = 1.20 * colorbarYLabelData.FontSize;
    end

    %-REVERT UNITS-%
    colorbarTitle.Units = titleUnits;
    colorbarTitle.FontUnits = titleFontUnits;
    colorbarYLabel.Units = yLabelUnits;
    colorbarYLabel.FontUnits = yLabelFontUnits;

    if ~isHG2
        colorbarXLabel.Units = xLabelUnits;
        colorbarXLabel.FontUnits = xLabelFontUnits;
    end

    %-some colorbar settings-%
    lineWidth = colorbarData.LineWidth ...
            * obj.PlotlyDefaults.AxisLineIncreaseFactor;
    tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(colorbarData.TickLength(1) * colorbarData.Position(3) ...
        * obj.layout.width, colorbarData.TickLength(1) ...
        * colorbarData.Position(4) * obj.layout.height));

    colorbar.thicknessmode = 'fraction';
    colorbar.thickness = colorbarData.Position(3);
    colorbar.tickwidth = lineWidth;
    colorbar.ticklen = tickLength;

    colorbar.lenmode = 'fraction';
    colorbar.len = colorbarData.Position(4)*1.025;
    colorbar.outlinewidth = lineWidth;

    % orientation vertical check
    orientVert = colorbar.len > colorbar.thickness;

    %-coloration-%
    if isHG2
        col = round(255*colorbarData.Color);
    else
        if orientVert
            col = round(255*colorbarData.YColor);
        else
            col = round(255*colorbarData.XColor);
        end
    end

    colorbarColor = getStringColor(col);

    colorbar.outlinecolor = colorbarColor;
    colorbar.tickcolor = colorbarColor;
    colorbar.tickfont.color = colorbarColor;
    colorbar.tickfont.size = colorbarData.FontSize;
    colorbar.tickfont.family = matlab2plotlyfont(colorbarData.FontName);
    colorbar.xpad = obj.PlotlyDefaults.MarginPad;
    colorbar.ypad = obj.PlotlyDefaults.MarginPad;

    %-set ticklabels-%
    nticks = length(colorbarData.Ticks);

    if isHG2
        if isempty(colorbarData.Ticks)
            %-hide tick labels-%
            colorbar.ticks = '';
            colorbar.showticklabels = false;
        else
            %-tick direction-%
            switch colorbarData.TickDirection
                case 'in'
                    colorbar.ticks = 'inside';
                case 'out'
                    colorbar.ticks = 'outside';
            end
            if strcmp(colorbarData.TickLabelsMode,'auto')
                colorbar.autotick = true;
                % nticks = max ticks (so + 1)
                colorbar.nticks = length(colorbarData.Ticks) + 1;
            else
                %-show tick labels-%
                if isempty(colorbarData.TickLabels)
                    colorbar.showticklabels = false;
                else
                    colorbar.autotick = false;
                    colorbar.tickvals = colorbarData.Ticks;
                    colorbar.ticktext = colorbarData.TickLabels;
                end
            end
        end
    else
        if orientVert
            if isempty(colorbarData.YTick)
                %-show tick labels-%
                colorbar.ticks = '';
                colorbar.showticklabels = false;
            else
                %-tick direction-%
                switch colorbarData.TickDir
                    case 'in'
                        colorbar.ticks = 'inside';
                    case 'out'
                        colorbar.ticks = 'outside';
                end
                if strcmp(colorbarData.YTickLabelMode, 'auto')
                    colorbar.autotick = true;
                    %-numticks-%
                    % nticks = max ticks (so + 1)
                    colorbar.nticks = length(colorbarData.YTick) + 1;
                else
                    %-show tick labels-%
                    if isempty(colorbarData.YTickLabel)
                        colorbar.showticklabels = false;
                    else
                        colorbar.autotick = false;
                        colorbar.tick0 = ...
                                str2double(colorbarData.YTickLabel(1,:));
                        colorbar.dtick = ...
                                str2double(colorbarData.YTickLabel(2,:)) ...
                                - str2double(colorbarData.YTickLabel(1,:));
                    end
                end
            end
        else
            if isempty(colorbarData.XTick)
                %-show tick labels-%
                colorbar.ticks = '';
                colorbar.showticklabels = false;
            else
                %-tick direction-%
                switch colorbarData.TickDir
                    case 'in'
                        colorbar.ticks = 'inside';
                    case 'out'
                        colorbar.ticks = 'outside';
                end
                if strcmp(colorbarData.XTickLabelMode,'auto')
                    colorbar.autotick = true;
                    colorbar.nticks = length(colorbarData.XTick) + 1;
                else
                    %-show tick labels-%
                    if isempty(colorbarData.XTickLabel)
                        colorbar.showticklabels = false;
                    else
                        colorbar.autotick = false;
                        colorbar.tick0 = ...
                                str2double(colorbarData.XTickLabel(1,:));
                        colorbar.dtick = ...
                                str2double(colorbarData.XTickLabel(2,:)) ...
                                - str2double(colorbarData.XTickLabel(1,:));
                    end
                end
            end
        end
    end

    %-colorbar bg-color-%
    if ~isHG2
        if ~ischar(colorbarData.Color)
            col = round(255*colorbarData.Color);
        else
            col = round(255*figureData.Color);
        end

        obj.layout.plot_bgcolor = getStringColor(col);
    end

    %-ASSOCIATED DATA-%
    if isfield(colorbarData.UserData,'dataref')
        colorbarDataIndex = colorbarData.UserData.dataref;
    else
        colorbarDataIndex = findColorbarData(obj,colorbarIndex);
    end

    if (nticks ~= 0)
        colorIndex = linspace(0, 1, nticks);
        colorData = linspace(0, 1, nticks-1);
        m = 1;

        for n = 1:nticks-1
            col = 1-colorData(n);
            colorscale{m} = {colorIndex(n), ...
                    getStringColor(round(255*[col, col, col]))};
            colorscale{m+1} = {colorIndex(n+1), ...
                    getStringColor(round(255*[col, col, col]))};
            m = 2*n+1;
        end
        obj.data{colorbarDataIndex}.marker.color = colorbarData.Ticks;
    else
        colorscale = {{0, 'rgb(255,255,255)'}, {1, 'rgb(0,0,0)'}};
    end

    obj.data{colorbarDataIndex}.marker.colorscale = colorscale;
    obj.data{colorbarDataIndex}.marker.colorbar = colorbar;
    obj.data{colorbarDataIndex}.showscale = true;

    %-REVERT UNITS-%
    obj.State.Colorbar(colorbarIndex).Handle.Units = colorbarunits;
end

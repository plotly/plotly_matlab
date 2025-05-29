function updateColorbar(obj,colorbarIndex)
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
        disp("could not get colorbar data");
    end

    %-STANDARDIZE UNITS-%
    colorbarUnits = colorbarData.Units;
    obj.State.Colorbar(colorbarIndex).Handle.Units = "normalized";

    %-variable initialization-%
    if isHG2
        outlineColor = [0 0 0];
    else
        if colorbarData.Position(4) > colorbarData.Position(3)
            outlineColor = round(255*colorbarData.YColor);
        else
            outlineColor = round(255*colorbarData.XColor);
        end
    end

    outlineColor = getStringColor(outlineColor);
    lineWidth = colorbarData.LineWidth ...
            * obj.PlotlyDefaults.AxisLineIncreaseFactor;
    tickLength = min(obj.PlotlyDefaults.MaxTickLength, ...
            max(colorbarData.TickLength(1) * colorbarData.Position(3) ...
            * obj.layout.width, colorbarData.TickLength(1) ...
            * colorbarData.Position(4) * obj.layout.height));

    %-colorbar placement-%
    colorbar.x = colorbarData.Position(1);
    colorbar.y = colorbarData.Position(2);
    colorbar.len = colorbarData.Position(4);
    colorbar.thickness = colorbarData.Position(3);

    colorbar.xpad = obj.PlotlyDefaults.MarginPad;
    colorbar.ypad = obj.PlotlyDefaults.MarginPad;
    colorbar.xanchor = "left";
    colorbar.yanchor = "bottom";

    colorbar.outlinewidth = lineWidth;
    colorbar.outlinecolor = outlineColor;
    colorbar.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    colorbar.thicknessmode = "fraction";
    colorbar.lenmode = "fraction";

    %-tick settings-%
    colorbar.tickcolor = outlineColor;
    colorbar.tickfont.color = outlineColor;
    colorbar.tickfont.size = colorbarData.FontSize;
    colorbar.tickfont.family = matlab2plotlyfont(colorbarData.FontName);
    colorbar.ticklen = tickLength;
    colorbar.tickwidth = lineWidth;

    %-get colorbar title and labels-%
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

    %-STANDARDIZE UNITS FOR TITLE-%
    titleunits = colorbarTitleData.Units;
    titlefontunits = colorbarTitleData.FontUnits;
    ylabelunits = colorbarYLabelData.Units;
    ylabelfontunits = colorbarYLabelData.FontUnits;
    colorbarTitle.Units = "data";
    colorbarYLabel.Units = "data";
    colorbarYLabel.FontUnits = "points";
    if ~isHG2
        xlabelunits = colorbarXLabelData.Units;
        xlabelfontunits = colorbarXLabelData.FontUnits;
        colorbarTitle.FontUnits = "points";
        colorbarXLabel.Units = "data";
        colorbarXLabel.FontUnits = "points";
    end

    %-colorbar title settings-%
    isTitle = true;

    if ~isempty(colorbarTitleData.String)
        titleString = colorbarTitleData.String;
        titleInterpreter = colorbarTitleData.Interpreter;

        if colorbarTitleData.Rotation == 90
            titleSide = "right";
        else
            titleSide = "top";
        end

        titleFontSize = 1.20 * colorbarTitleData.FontSize;
        titleFontColor = getStringColor(round(255*colorbarTitleData.Color));
        titleFontFamily = matlab2plotlyfont(colorbarTitleData.FontName);
    elseif ~isempty(colorbarXLabelData.String)
        titleString = colorbarXLabelData.String;
        titleInterpreter = colorbarXLabelData.Interpreter;

        titleSide = "right";
        titleFontSize = 1.20 * colorbarXLabelData.FontSize;
        titleFontColor = getStringColor(round(255*colorbarXLabelData.Color));
        titleFontFamily = matlab2plotlyfont(colorbarXLabelData.FontName);
    elseif ~isempty(colorbarYLabelData.String)
        titleString = colorbarYLabelData.String;
        titleInterpreter = colorbarYLabelData.Interpreter;

        titleSide = "bottom";
        titleFontSize = 1.20 * colorbarYLabelData.FontSize;
        titleFontColor = getStringColor(round(255*colorbarYLabelData.Color));
        titleFontFamily = matlab2plotlyfont(colorbarYLabelData.FontName);
    else
        isTitle = false;
    end

    if isTitle
        colorbar.title = parseString(titleString, titleInterpreter);
        colorbar.titleside = titleSide;
        colorbar.titlefont.size = titleFontSize;
        colorbar.titlefont.color = titleFontColor;
        colorbar.titlefont.family = titleFontFamily;
    end

    %-REVERT UNITS FOR TITLE-%
    colorbarTitle.Units = titleunits;
    colorbarTitle.FontUnits = titlefontunits;
    colorbarYLabel.Units = ylabelunits;
    colorbarYLabel.FontUnits = ylabelfontunits;

    if ~isHG2
        colorbarXLabel.Units = xlabelunits;
        colorbarXLabel.FontUnits = xlabelfontunits;
    end

    tickValues = colorbarData.Ticks;
    tickLabels = colorbarData.TickLabels;
    showTickLabels = true;

    if isHG2
        if isempty(tickValues)
            showTickLabels = false;
            colorbar.ticks = "";
        elseif isempty(tickLabels)
            colorbar.tickvals = tickValues;
        else
            colorbar.tickvals = tickValues;
            colorbar.ticktext = tickLabels;
        end
        if showTickLabels
            colorbar.showticklabels = showTickLabels;
            switch colorbarData.AxisLocation
                case "in"
                    colorbar.ticklabelposition = "inside";
                case "out"
                    colorbar.ticklabelposition = "outside";
            end
            switch colorbarData.TickDirection
                case "in"
                    colorbar.ticks = "inside";
                case "out"
                    colorbar.ticks = "outside";
            end
        end
    else
        colorbar = setTicksNotHG2(colorbar, colorbarData);
    end

    %-colorbar bg-color-%
    if ~isHG2
        if ~ischar(colorbarData.Color)
            bgColor = colorbarData.Color;
        else
            bgColor = figureData.Color;
        end

        obj.layout.plot_bgcolor = getStringColor(round(255*bgColor));
    end

    %-ASSOCIATED DATA-%
    if isfield(colorbarData.UserData, "dataref")
        colorbarDataIndex = colorbarData.UserData.dataref;
    else
        colorbarDataIndex = ...
                findColorbarData(obj,colorbarIndex, colorbarData);
    end

    obj.data{colorbarDataIndex}.colorbar = colorbar;
    obj.data{colorbarDataIndex}.showscale = true;

    %-REVERT UNITS-%
    obj.State.Colorbar(colorbarIndex).Handle.Units = colorbarUnits;
end

function colorbar = setTicksNotHG2(colorbar, colorbarData)
    verticalOrientation = colorbar.len > colorbar.thickness;

    if verticalOrientation
        tick = colorbarData.YTick;
        tickLabel = colorbarData.YTickLabel;
        tickLabelMode = colorbarData.YTickLabelMode;
    else
        tick = colorbarData.XTick;
        tickLabel = colorbarData.XTickLabel;
        tickLabelMode = colorbarData.XTickLabelMode;
    end

    if isempty(tick)
        colorbar.ticks = "";
        colorbar.showticklabels = false;
    else
        switch colorbarData.TickDir
            case "in"
                colorbar.ticks = "inside";
            case "out"
                colorbar.ticks = "outside";
        end
        if strcmp(tickLabelMode, "auto")
            colorbar.autotick = true;
            colorbar.nticks = length(tick) + 1;
        else
            if isempty(tickLabel)
                colorbar.showticklabels = false;
            else
                colorbar.autotick = false;
                colorbar.tick0 = str2double(tickLabel(1,:));
                colorbar.dtick = str2double(tickLabel(2,:)) ...
                                 - str2double(tickLabel(1,:));
            end
        end
    end
end

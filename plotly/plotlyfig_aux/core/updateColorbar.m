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

    %-PLOT DATA STRUCTURE- %
    try
        colorbarData = obj.State.Colorbar(colorbarIndex).Handle;
    catch
        disp("could not get colorbar data");
    end

    %-STANDARDIZE UNITS-%
    colorbarUnits = get(colorbarData, 'Units');
    set(obj.State.Colorbar(colorbarIndex).Handle, 'Units', "normalized");

    %-variable initialization-%
    outlineColor = [0 0 0];

    tmpTickLength = get(colorbarData, 'TickLength');
    tmpPosition = get(colorbarData, 'Position');
    outlineColor = getStringColor(outlineColor);
    lineWidth = get(colorbarData, 'LineWidth') ...
            * obj.PlotlyDefaults.AxisLineIncreaseFactor;
    tickLength = min(obj.PlotlyDefaults.MaxTickLength, ...
            max(tmpTickLength(1) * tmpPosition(3) ...
            * obj.layout.width, tmpTickLength(1) ...
            * tmpPosition(4) * obj.layout.height));

    %-colorbar placement-%
    colorbar.x = tmpPosition(1);
    colorbar.y = tmpPosition(2);
    colorbar.len = tmpPosition(4);
    colorbar.thickness = tmpPosition(3);

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
    colorbar.tickfont.size = get(colorbarData, 'FontSize');
    colorbar.tickfont.family = matlab2plotlyfont(get(colorbarData, 'FontName'));
    colorbar.ticklen = tickLength;
    colorbar.tickwidth = lineWidth;

    %-get colorbar title and labels-%
    colorbarTitle = get(colorbarData, 'Label');

    colorbarTitleData = colorbarTitle;
    colorbarYLabel = colorbarTitle;
    colorbarYLabelData = colorbarTitle;
    colorbarXLabelData.String = [];

    %-STANDARDIZE UNITS FOR TITLE-%
    titleunits = get(colorbarTitleData, 'Units');
    titlefontunits = get(colorbarTitleData, 'FontUnits');
    ylabelunits = get(colorbarYLabelData, 'Units');
    ylabelfontunits = get(colorbarYLabelData, 'FontUnits');
    set(colorbarTitle, 'Units', "data");
    set(colorbarYLabel, 'Units', "data");
    set(colorbarYLabel, 'FontUnits', "points");

    %-colorbar title settings-%
    isTitle = true;

    if ~isempty(get(colorbarTitleData, 'String'))
        titleString = get(colorbarTitleData, 'String');
        titleInterpreter = get(colorbarTitleData, 'Interpreter');

        if get(colorbarTitleData, 'Rotation') == 90
            titleSide = "right";
        else
            titleSide = "top";
        end

        titleFontSize = 1.20 * get(colorbarTitleData, 'FontSize');
        titleFontColor = getStringColor(round(255*get(colorbarTitleData, 'Color')));
        titleFontFamily = matlab2plotlyfont(get(colorbarTitleData, 'FontName'));
    elseif ~isempty(colorbarXLabelData.String)
        titleString = colorbarXLabelData.String;
        titleInterpreter = colorbarXLabelData.Interpreter;

        titleSide = "right";
        titleFontSize = 1.20 * colorbarXLabelData.FontSize;
        titleFontColor = getStringColor(round(255*colorbarXLabelData.Color));
        titleFontFamily = matlab2plotlyfont(colorbarXLabelData.FontName);
    elseif ~isempty(get(colorbarYLabelData, 'String'))
        titleString = get(colorbarYLabelData, 'String');
        titleInterpreter = get(colorbarYLabelData, 'Interpreter');

        titleSide = "bottom";
        titleFontSize = 1.20 * get(colorbarYLabelData, 'FontSize');
        titleFontColor = getStringColor(round(255*get(colorbarYLabelData, 'Color')));
        titleFontFamily = matlab2plotlyfont(get(colorbarYLabelData, 'FontName'));
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
    set(colorbarTitle, 'Units', titleunits);
    set(colorbarTitle, 'FontUnits', titlefontunits);
    set(colorbarYLabel, 'Units', ylabelunits);
    set(colorbarYLabel, 'FontUnits', ylabelfontunits);

    tickValues = get(colorbarData, 'Ticks');
    tickLabels = get(colorbarData, 'TickLabels');
    showTickLabels = true;

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
        switch get(colorbarData, 'AxisLocation')
            case "in"
                colorbar.ticklabelposition = "inside";
            case "out"
                colorbar.ticklabelposition = "outside";
        end
        switch get(colorbarData, 'TickDirection')
            case "in"
                colorbar.ticks = "inside";
            case "out"
                colorbar.ticks = "outside";
        end
    end

    %-ASSOCIATED DATA-%
    if isfield(get(colorbarData, 'UserData'), "dataref")
        colorbarDataIndex = get(colorbarData, 'UserData').dataref;
    else
        colorbarDataIndex = ...
                findColorbarData(obj,colorbarIndex, colorbarData);
    end

    obj.data{colorbarDataIndex}.colorbar = colorbar;
    obj.data{colorbarDataIndex}.showscale = true;

    %-REVERT UNITS-%
    set(obj.State.Colorbar(colorbarIndex).Handle, 'Units', colorbarUnits);
end

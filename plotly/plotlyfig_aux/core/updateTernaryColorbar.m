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

    %-PLOT DATA STRUCTURE- %
    try
        colorbarData = obj.State.Colorbar(colorbarIndex).Handle;
    catch
        disp("could not extract ColorBar data");
    end

    %-STANDARDIZE UNITS-%
    colorbarunits = get(colorbarData, 'Units');
    set(obj.State.Colorbar(colorbarIndex).Handle, 'Units', "normalized");

    %-colorbar position-%
    colorbar.xanchor = "left";
    colorbar.yanchor = "bottom";
    tmpPosition = get(colorbarData, 'Position');
    colorbar.x = tmpPosition(1)*1.025;
    colorbar.y = tmpPosition(2);

    colorbar.exponentformat = obj.PlotlyDefaults.ExponentFormat;

    % get colorbar title and labels
    colorbarTitle = get(colorbarData, 'Label');

    colorbarTitleData = colorbarTitle;
    colorbarYLabel = colorbarTitle;
    colorbarYLabelData = colorbarTitle;
    colorbarXLabelData.String = [];

    %-colorbar title-%
    if ~isempty(get(colorbarTitleData, 'String'))
        colorbar.title = parseString(get(colorbarTitleData, 'String'), ...
                get(colorbarTitleData, 'Interpreter'));
    elseif ~isempty(colorbarXLabelData.String)
        colorbar.title = parseString(colorbarXLabelData.String, ...
                colorbarXLabelData.Interpreter);
    elseif ~isempty(get(colorbarYLabelData, 'String'))
        colorbar.title = parseString(get(colorbarYLabelData, 'String'), ...
                get(colorbarYLabelData, 'Interpreter'));
    end

    %-STANDARDIZE UNITS-%
    titleUnits = get(colorbarTitleData, 'Units');
    titleFontUnits = get(colorbarTitleData, 'FontUnits');
    yLabelUnits = get(colorbarYLabelData, 'Units');
    yLabelFontUnits = get(colorbarYLabelData, 'FontUnits');
    set(colorbarTitle, 'Units', "data");
    set(colorbarYLabel, 'Units', "data");
    set(colorbarYLabel, 'FontUnits', "points");


    if ~isempty(get(colorbarTitleData, 'String'))
        if get(colorbarTitleData, 'Rotation') == 90
            colorbar.titleside = "right";
        else
            colorbar.titleside = "top";
        end

        colorbar.titlefont = getFont(colorbarTitleData);
    elseif ~isempty(colorbarXLabelData.String)
        colorbar.titleside = "right";
        colorbar.titlefont = getFont(colorbarXLabelData);
    elseif ~isempty(get(colorbarYLabelData, 'String'))
        colorbar.titleside = "bottom";
        colorbar.titlefont = getFont(colorbarYLabelData);
    end

    %-REVERT UNITS-%
    set(colorbarTitle, 'Units', titleUnits);
    set(colorbarTitle, 'FontUnits', titleFontUnits);
    set(colorbarYLabel, 'Units', yLabelUnits);
    set(colorbarYLabel, 'FontUnits', yLabelFontUnits);


    tmpTickLength = get(colorbarData, 'TickLength');
    %-some colorbar settings-%
    lineWidth = get(colorbarData, 'LineWidth') ...
            * obj.PlotlyDefaults.AxisLineIncreaseFactor;
    tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(tmpTickLength(1) * tmpPosition(3) ...
        * obj.layout.width, tmpTickLength(1) ...
        * tmpPosition(4) * obj.layout.height));

    colorbar.thicknessmode = "fraction";
    colorbar.thickness = tmpPosition(3);
    colorbar.tickwidth = lineWidth;
    colorbar.ticklen = tickLength;

    colorbar.lenmode = "fraction";
    colorbar.len = tmpPosition(4)*1.025;
    colorbar.outlinewidth = lineWidth;

    %-coloration-%
    col = get(colorbarData, 'Color');

    colorbarColor = getStringColor(round(255*col));

    colorbar.outlinecolor = colorbarColor;
    colorbar.tickcolor = colorbarColor;
    colorbar.tickfont.color = colorbarColor;
    colorbar.tickfont.size = get(colorbarData, 'FontSize');
    colorbar.tickfont.family = matlab2plotlyfont(get(colorbarData, 'FontName'));
    colorbar.xpad = obj.PlotlyDefaults.MarginPad;
    colorbar.ypad = obj.PlotlyDefaults.MarginPad;

    %-set ticklabels-%
    nticks = length(get(colorbarData, 'Ticks'));

    if isempty(get(colorbarData, 'Ticks'))
        colorbar.ticks = "";
        colorbar.showticklabels = false;
    else
        %-tick direction-%
        switch get(colorbarData, 'TickDirection')
            case "in"
                colorbar.ticks = "inside";
            case "out"
                colorbar.ticks = "outside";
        end
        if strcmp(get(colorbarData, 'TickLabelsMode'),"auto")
            colorbar.autotick = true;
            % nticks = max ticks (so + 1)
            colorbar.nticks = length(get(colorbarData, 'Ticks')) + 1;
        else
            if isempty(get(colorbarData, 'TickLabels'))
                colorbar.showticklabels = false;
            else
                colorbar.autotick = false;
                colorbar.tickvals = get(colorbarData, 'Ticks');
                colorbar.ticktext = get(colorbarData, 'TickLabels');
            end
        end
    end

    %-ASSOCIATED DATA-%
    if isfield(get(colorbarData, 'UserData'),"dataref")
        colorbarDataIndex = get(colorbarData, 'UserData').dataref;
    else
        colorbarDataIndex = findColorbarData(obj,colorbarIndex);
    end

    if (nticks ~= 0)
        colorIndex = linspace(0, 1, nticks);
        colorData = linspace(0, 1, nticks-1);

        colorscale = cell(1:2*(nticks-1));
        for n = 1:nticks-1
            col = 1-colorData(n);
            colorscale{2*n-1} = {colorIndex(n), ...
                    getStringColor(round(255*[col, col, col]))};
            colorscale{2*n} = {colorIndex(n+1), ...
                    getStringColor(round(255*[col, col, col]))};
        end
        obj.data{colorbarDataIndex}.marker.color = get(colorbarData, 'Ticks');
    else
        colorscale = {{0, "rgb(255,255,255)"}, {1, "rgb(0,0,0)"}};
    end

    obj.data{colorbarDataIndex}.marker.colorscale = colorscale;
    obj.data{colorbarDataIndex}.marker.colorbar = colorbar;
    obj.data{colorbarDataIndex}.showscale = true;

    %-REVERT UNITS-%
    set(obj.State.Colorbar(colorbarIndex).Handle, 'Units', colorbarunits);
end

function out = getFont(labelData)
    out = struct( ...
        "family", matlab2plotlyfont(get(labelData, 'FontName')), ...
        "color", getStringColor(round(255*get(labelData, 'Color'))), ...
        "size", 1.20 * get(labelData, 'FontSize') ...
    );
end

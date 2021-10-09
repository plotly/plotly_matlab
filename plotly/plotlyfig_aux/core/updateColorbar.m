function obj = updateColorbar(obj,colorbarIndex)

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
    figureData = get(obj.State.Figure.Handle);

    %-PLOT DATA STRUCTURE- %
    try
        colorbarData = get(obj.State.Colorbar(colorbarIndex).Handle);
    catch
        disp('could not get colorbar data');
    end

    %-STANDARDIZE UNITS-%
    colorbarUnits = colorbarData.Units;
    set(obj.State.Colorbar(colorbarIndex).Handle,'Units','normalized');

    %-------------------------------------------------------------------------%

    %-variable initialization-%
    if isHG2
        outlineColor = [0 0 0];
    else
        if colorbarData.Position(4) > colorbarData.Position(3)
            outlineColor = 255*colorbarData.YColor;
        else
            outlineColor = 255*colorbarData.XColor;
        end
    end

    outlineColor = sprintf('rgb(%f,%f,%f)', outlineColor);
    lineWidth = colorbarData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor;
    tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(colorbarData.TickLength(1)*colorbarData.Position(3)*obj.layout.width,...
        colorbarData.TickLength(1)*colorbarData.Position(4)*obj.layout.height));

    %-------------------------------------------------------------------------%

    %-colorbar placement-%
    colorbar.x = colorbarData.Position(1);
    colorbar.y = colorbarData.Position(2);
    colorbar.len = colorbarData.Position(4);
    colorbar.thickness = colorbarData.Position(3);

    colorbar.xpad = obj.PlotlyDefaults.MarginPad;
    colorbar.ypad = obj.PlotlyDefaults.MarginPad;
    colorbar.xanchor = 'left';
    colorbar.yanchor = 'bottom';

    colorbar.outlinewidth = lineWidth;
    colorbar.outlinecolor = outlineColor;
    colorbar.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    colorbar.thicknessmode = 'fraction';
    colorbar.lenmode = 'fraction';
    
    %-------------------------------------------------------------------------%

    %-tick setings-%
    colorbar.tickcolor = outlineColor;
    colorbar.tickfont.color = outlineColor;
    colorbar.tickfont.size = colorbarData.FontSize;
    colorbar.tickfont.family = matlab2plotlyfont(colorbarData.FontName);
    colorbar.ticklen = tickLength;
    colorbar.tickwidth = lineWidth;

    %-------------------------------------------------------------------------%

    %-get colorbar title and labels-%
    colorbarTitle = colorbarData.Label;

    if isHG2
        colorbarTitleData = get(colorbarTitle);
        colorbarYLabel = colorbarTitle;
        colorbarYLabelData = get(colorbarTitle);
        colorbarXLabelData.String = [];
    else
        colorbarTitleData = get(colorbarTitle);
        colorbarXLabel = colorbarData.XLabel;
        colorbarXLabelData = get(colorbarXLabel);
        colorbarYLabel = colorbarData.YLabel;
        colorbarYLabelData = get(colorbarYLabel);
    end

    %-------------------------------------------------------------------------%

    %-STANDARDIZE UNITS FOR TITLE-%
    titleunits = colorbarTitleData.Units;
    titlefontunits = colorbarTitleData.FontUnits;
    ylabelunits = colorbarYLabelData.Units;
    ylabelfontunits = colorbarYLabelData.FontUnits;
    set(colorbarTitle,'Units','data');
    set(colorbarYLabel,'Units','data');
    set(colorbarYLabel,'FontUnits','points');
    if ~isHG2
        xlabelunits = colorbarXLabelData.Units;
        xlabelfontunits = colorbarXLabelData.FontUnits;
        set(colorbarTitle,'FontUnits','points');
        set(colorbarXLabel,'Units','data');
        set(colorbarXLabel,'FontUnits','points');
    end

    %-------------------------------------------------------------------------%

    %-colorbar title settings-%
    isTitle = true;

    if ~isempty(colorbarTitleData.String)
        titleString = colorbarTitleData.String;
        titleInterpreter = colorbarTitleData.Interpreter;

        if colorbarTitleData.Rotation == 90
            titleSide = 'right';
        else
            titleSide = 'top';
        end

        titleFontSize = 1.20 * colorbarTitleData.FontSize;
        titleFontColor = sprintf('rgb(%f,%f,%f)', 255*colorbarTitleData.Color);
        titleFontFamily = matlab2plotlyfont(colorbarTitleData.FontName);

    elseif ~isempty(colorbarXLabelData.String)
        titleString = colorbarXLabelData.String;
        titleInterpreter = colorbarXLabelData.Interpreter;

        titleSide = 'right';
        titleFontSize = 1.20 * colorbarXLabelData.FontSize;
        titleFontColor = sprintf('rgb(%f,%f,%f)', 255*colorbarXLabelData.Color);
        titleFontFamily = matlab2plotlyfont(colorbarXLabelData.FontName);

    elseif ~isempty(colorbarYLabelData.String)
        titleString = colorbarYLabelData.String;
        titleInterpreter = colorbarYLabelData.Interpreter;

        titleSide = 'bottom';
        titleFontSize = 1.20 * colorbarYLabelData.FontSize;
        titleFontColor = sprintf('rgb(%f,%f,%f)', 255*colorbarYLabelData.Color);
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

    %-------------------------------------------------------------------------%

    %-REVERT UNITS FOR TITLE-%
    set(colorbarTitle,'Units',titleunits);
    set(colorbarTitle,'FontUnits',titlefontunits);
    set(colorbarYLabel,'Units',ylabelunits);
    set(colorbarYLabel,'FontUnits',ylabelfontunits);

    if ~isHG2
        set(colorbarXLabel,'Units',xlabelunits);
        set(colorbarXLabel,'FontUnits',xlabelfontunits);
    end

    %-------------------------------------------------------------------------%

    %-tick labels-%
    tickValues = colorbarData.Ticks;
    tickLabels = colorbarData.TickLabels;
    showTickLabels = true;

    if isHG2
        if isempty(tickValues)
            showTickLabels = false;
            colorbar.ticks = '';

        elseif isempty(tickLabels)
            colorbar.tickvals = tickValues;

        else
            colorbar.tickvals = tickValues;
            colorbar.ticktext = tickLabels;
        end

        if showTickLabels
            colorbar.showticklabels = showTickLabels;

            switch colorbarData.AxisLocation
                case 'in'
                    colorbar.ticklabelposition = 'inside';
                case 'out'
                    colorbar.ticklabelposition = 'outside';
            end

            switch colorbarData.TickDirection
                case 'in'
                    colorbar.ticks = 'inside';
                case 'out'
                    colorbar.ticks = 'outside';
            end

        end

    else
        colorbar = setTicksNotHG2(colorbar, colorbarData);
    end

    %-------------------------------------------------------------------------%

    %-colorbar bg-color-%
    if ~isHG2
        if ~ischar(colorbarData.Color)
            bgColor = 255*colorbarData.Color;
        else
            bgColor = 255*figureData.Color;
        end
        
        obj.layout.plot_bgcolor = sprintf('rgb(%f,%f,%f', bgColor);
    end

    %-------------------------------------------------------------------------%

    %-ASSOCIATED DATA-%
    if isfield(colorbarData.UserData,'dataref')
        colorbarDataIndex = colorbarData.UserData.dataref;
    else
        colorbarDataIndex = findColorbarData(obj,colorbarIndex,colorbarData);
    end

    obj.data{colorbarDataIndex}.colorbar = colorbar;
    obj.data{colorbarDataIndex}.showscale = true;

    %-------------------------------------------------------------------------%

    %-REVERT UNITS-%
    set(obj.State.Colorbar(colorbarIndex).Handle,'Units',colorbarUnits);

    %-------------------------------------------------------------------------%
end


function colorbar = setTicksNotHG2(colorbar, colorbarData)
    verticalOrientation = colorbar.len > colorbar.thickness;

    if verticalOrientation
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
            
            if strcmp(colorbarData.YTickLabelMode,'auto')
                %-autotick-%
                colorbar.autotick = true;
                %-numticks-%
                colorbar.nticks = length(colorbarData.YTick) + 1; %nticks = max ticks (so + 1)
            else
                %-show tick labels-%
                if isempty(colorbarData.YTickLabel)
                    colorbar.showticklabels = false;
                else
                    %-autotick-%
                    colorbar.autotick = false;
                    %-tick0-%
                    colorbar.tick0 = str2double(colorbarData.YTickLabel(1,:));
                    %-dtick-%
                    colorbar.dtick = str2double(colorbarData.YTickLabel(2,:)) - str2double(colorbarData.YTickLabel(1,:));
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
                %-autotick-%
                colorbar.autotick = true;
                %-numticks-%
                colorbar.nticks = length(colorbarData.XTick) + 1;
            else
                %-show tick labels-%
                if isempty(colorbarData.XTickLabel)
                    colorbar.showticklabels = false;
                else
                    %-autotick-%
                    colorbar.autotick = false;
                    %-tick0-%
                    colorbar.tick0 = str2double(colorbarData.XTickLabel(1,:));
                    %-dtick-%
                    colorbar.dtick = str2double(colorbarData.XTickLabel(2,:)) - str2double(colorbarData.XTickLabel(1,:));
                end
            end
        end
    end
end


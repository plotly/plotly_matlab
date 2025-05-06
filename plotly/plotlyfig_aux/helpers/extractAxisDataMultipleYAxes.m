function [axis, axisLim] = extractAxisDataMultipleYAxes(obj,parentAxisData,yaxIndex)
    childAxisData = parentAxisData.YAxis(yaxIndex);

    %-axis-side-%
    if yaxIndex == 1
        axis.side = 'left';
    elseif yaxIndex == 2
        axis.side = 'right';
    end

    %-y-axis initializations-%
    axis.zeroline = false;
    axis.autorange = false;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    axis.tickfont.size = childAxisData.FontSize;
    axis.tickfont.family = matlab2plotlyfont(childAxisData.FontName);

    %-y-axis ticklen-%
    axis.ticklen = min(obj.PlotlyDefaults.MaxTickLength,...
        max(childAxisData.TickLength(1)*parentAxisData.Position(3)*obj.layout.width,...
        childAxisData.TickLength(1)*parentAxisData.Position(4)*obj.layout.height));

    %-y-axis coloring-%
    axiscol = getStringColor(round(255*childAxisData.Color));

    axis.linecolor = axiscol;
    axis.tickcolor = axiscol;
    axis.tickfont.color = axiscol;

    if isprop(parentAxisData, "GridColor") && isprop(parentAxisData, "GridAlpha")
        axis.gridcolor = getStringColor( ...
                round(255*parentAxisData.GridColor), ...
                parentAxisData.GridAlpha);
    else
        axis.gridcolor = axiscol;
    end

    if strcmp(parentAxisData.YGrid, 'on')
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end

    linewidth = max(1,childAxisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    axis.linewidth = linewidth;
    axis.tickwidth = linewidth;
    axis.gridwidth = linewidth;
    axis.type = childAxisData.Scale;

    %-axis showtick labels / ticks-%
    tickValues = childAxisData.TickValues;

    if isempty(tickValues)
        axis.ticks = '';
        axis.showticklabels = false;
        axis.autorange = true;
    else
        axisLim = childAxisData.Limits;
        switch childAxisData.TickDirection
            case 'in'
                axis.ticks = 'inside';
            case 'out'
                axis.ticks = 'outside';
        end
        %-LOG TYPE-%
        if strcmp(axis.type, 'log')
            axis.range = log10(axisLim);
            axis.autotick = true;
            axis.nticks = length(tickValues) + 1;
        elseif strcmp(axis.type, 'linear')
            tickLabelMode = childAxisData.TickLabelsMode;
            %-AUTO MODE-%
            if strcmp(tickLabelMode, 'auto')
                if isnumeric(axisLim)
                    axis.range = axisLim;
                elseif isduration(axisLim)
                   [temp,type] = convertDuration(axisLim);
                   if (~isduration(temp))
                       axis.range = temp;
                       axis.type = 'duration';
                       axis.title = type;
                   else
                       nticks = length(tickValues) + 1;
                       delta = 0.1;
                       axis.range = [-delta nticks+delta];
                       axis.type = 'duration - specified format';
                   end
                elseif isdatetime(axisLim)
                    axis.range = convertDate(axisLim);
                    axis.type = 'date';
                else
                    % data is a category type other then duration and datetime
                end
                axis.autotick = true;
                axis.nticks = length(tickValues) + 1;
                axis.showticklabels = true;
            else %-CUSTOM MODE-%
                tickLabels = childAxisData.TickLabels;
                %-hide tick labels as lichkLabels field is empty-%
                if isempty(tickLabels)
                    %-hide tick labels-%
                    axis.showticklabels = false;
                    axis.autorange = true;
                else %-axis show tick labels as tickLabels matlab field-%
                    axis.showticklabels = true;
                    if isnumeric(axisLim)
                        axis.range = axisLim;
                    else
                        axis.autorange = true;
                    end
                    axis.tickvals = tickValues;
                    axis.ticktext = tickLabels;
                end
            end
        end
    end

    %-scale direction-%
    if strcmp(childAxisData.Direction, 'reverse')
        axis.range = [axis.range(2) axis.range(1)];
    end

    %-y-axis label-%
    label = childAxisData.Label;
    labelData = label;

    % STANDARDIZE UNITS
    fontunits = label.FontUnits;
    label.FontUnits = 'points';

    %-title settings-%
    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = getStringColor(round(255*labelData.Color));
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    % REVERT UNITS
    label.FontUnits = fontunits;

    if strcmp(childAxisData.Visible, 'on')
        axis.showline = true;
    else
        axis.showline = false;
        axis.showticklabels = false;
        axis.ticks = '';
        axis.showline = false;
        axis.showticklabels = false;
        axis.ticks = '';
    end
end

function [axis, axisLim] = extractAxisDataMultipleYAxes(obj,parentAxisData,yaxIndex)
    tmpYAxis = get(parentAxisData, 'YAxis');
    childAxisData = tmpYAxis(yaxIndex);

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
    axis.tickfont.size = get(childAxisData, 'FontSize');
    axis.tickfont.family = matlab2plotlyfont(get(childAxisData, 'FontName'));

    tmpTickLength = get(childAxisData, 'TickLength');
    tmpPosition = get(parentAxisData, 'Position');
    %-y-axis ticklen-%
    axis.ticklen = min(obj.PlotlyDefaults.MaxTickLength,...
        max(tmpTickLength(1)*tmpPosition(3)*obj.layout.width,...
        tmpTickLength(1)*tmpPosition(4)*obj.layout.height));

    %-y-axis coloring-%
    axiscol = getStringColor(round(255*get(childAxisData, 'Color')));

    axis.linecolor = axiscol;
    axis.tickcolor = axiscol;
    axis.tickfont.color = axiscol;

    if isprop(parentAxisData, "GridColor") && isprop(parentAxisData, "GridAlpha")
        axis.gridcolor = getStringColor( ...
                round(255*get(parentAxisData, 'GridColor')), ...
                get(parentAxisData, 'GridAlpha'));
    else
        axis.gridcolor = axiscol;
    end

    if strcmp(get(parentAxisData, 'YGrid'), 'on')
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end

    linewidth = max(1,get(childAxisData, 'LineWidth')*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    axis.linewidth = linewidth;
    axis.tickwidth = linewidth;
    axis.gridwidth = linewidth;
    axis.type = get(childAxisData, 'Scale');

    %-axis showtick labels / ticks-%
    tickValues = get(childAxisData, 'TickValues');

    if isempty(tickValues)
        axis.ticks = '';
        axis.showticklabels = false;
        axis.autorange = true;
    else
        axisLim = get(childAxisData, 'Limits');
        switch get(childAxisData, 'TickDirection')
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
            tickLabelMode = get(childAxisData, 'TickLabelsMode');
            %-AUTO MODE-%
            if strcmp(tickLabelMode, 'auto')
                if isnumeric(axisLim)
                    axis.range = axisLim;
                elseif isa(axisLim, "duration")
                   [temp,type] = convertDuration(axisLim);
                   if (~isa(temp, "duration"))
                       axis.range = temp;
                       axis.type = 'duration';
                       axis.title = type;
                   else
                       nticks = length(tickValues) + 1;
                       delta = 0.1;
                       axis.range = [-delta nticks+delta];
                       axis.type = 'duration - specified format';
                   end
                elseif isa(axisLim, "datetime")
                    axis.range = convertDate(axisLim);
                    axis.type = 'date';
                else
                    % data is a category type other then duration and datetime
                end
                axis.autotick = true;
                axis.nticks = length(tickValues) + 1;
                axis.showticklabels = true;
            else %-CUSTOM MODE-%
                tickLabels = get(childAxisData, 'TickLabels');
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
    if strcmp(get(childAxisData, 'Direction'), 'reverse')
        axis.range = [axis.range(2) axis.range(1)];
    end

    %-y-axis label-%
    label = get(childAxisData, 'Label');
    labelData = label;

    % STANDARDIZE UNITS
    fontunits = get(label, 'FontUnits');
    set(label, 'FontUnits', 'points');

    %-title settings-%
    if ~isempty(get(labelData, 'String'))
        axis.title = parseString(get(labelData, 'String'),get(labelData, 'Interpreter'));
    end

    axis.titlefont.color = getStringColor(round(255*get(labelData, 'Color')));
    axis.titlefont.size = get(labelData, 'FontSize');
    axis.titlefont.family = matlab2plotlyfont(get(labelData, 'FontName'));

    % REVERT UNITS
    set(label, 'FontUnits', fontunits);

    if strcmp(get(childAxisData, 'Visible'), 'on')
        axis.showline = true;
    else
        axis.showline = false;
        axis.showticklabels = false;
        axis.showgrid = false;
        axis.ticks = '';
    end
end

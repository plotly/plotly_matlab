function [axis, axisLim] = extractAxisDataMultipleYAxes(obj,parentAxisData,yaxIndex)
    childAxisData = parentAxisData.YAxis(yaxIndex);

    %---------------------------------------------------------------------%

    %-axis-side-%
    if yaxIndex == 1
        axis.side = 'left';
    elseif yaxIndex == 2
        axis.side = 'right';
    end

    %---------------------------------------------------------------------%

    %-y-axis initializations-%
    axis.zeroline = false;
    axis.autorange = false;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    axis.tickfont.size = childAxisData.FontSize;
    axis.tickfont.family = matlab2plotlyfont(childAxisData.FontName);

    %---------------------------------------------------------------------%

    ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(childAxisData.TickLength(1)*parentAxisData.Position(3)*obj.layout.width,...
        childAxisData.TickLength(1)*parentAxisData.Position(4)*obj.layout.height));
    %-y-axis ticklen-%
    axis.ticklen = ticklength;

    %---------------------------------------------------------------------%

    %-y-axis coloring-%
    axiscol = sprintf("rgb(%d,%d,%d)", round(255*childAxisData.Color));

    axis.linecolor = axiscol;
    axis.tickcolor = axiscol;
    axis.tickfont.color = axiscol;

    try
        axis.gridcolor = sprintf("rgba(%d,%d,%d,%f)", ...
                round(255*parentAxisData.GridColor), ...
                parentAxisData.GridAlpha);
    catch
        axis.gridcolor = axiscol;
    end

    %---------------------------------------------------------------------%

    %-axis show grid-%
    if strcmp(parentAxisData.YGrid, 'on')
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end

    %---------------------------------------------------------------------%

    %-line widths-%
    linewidth = max(1,childAxisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    axis.linewidth = linewidth;
    axis.tickwidth = linewidth;
    axis.gridwidth = linewidth;

    %---------------------------------------------------------------------%

    %-axis type-%
    axis.type = childAxisData.Scale;

    %---------------------------------------------------------------------%

    %-axis showtick labels / ticks-%
    tickValues = childAxisData.TickValues;

    if isempty(tickValues)
        %-axis ticks-%
        axis.ticks = '';
        axis.showticklabels = false;
        
        %-axis autorange-%
        axis.autorange = true; 
    else
        %-get axis limits-%
        axisLim = childAxisData.Limits; 
        
        %-axis tick direction-%
        switch childAxisData.TickDirection
            case 'in'
                axis.ticks = 'inside';
            case 'out'
                axis.ticks = 'outside';
        end
        
        %---------------------------------------------------------------------%
        
        %-LOG TYPE-%
        if strcmp(axis.type, 'log')
            %-axis range-%
            axis.range = log10(axisLim);
            %-axis autotick-%
            axis.autotick = true;
            %-axis nticks-%
            axis.nticks = length(tickValues) + 1;
        elseif strcmp(axis.type, 'linear')
            %-get tick label mode-%
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
                %-axis autotick-%
                axis.autotick = true;
                %-axis numticks-%       
                axis.nticks = length(tickValues) + 1;
                axis.showticklabels = true;
            else %-CUSTOM MODE-%
                %-get tick labels-%
                tickLabels = childAxisData.TickLabels;

                %-hide tick labels as lichkLabels field is empty-%
                if isempty(tickLabels)
                    %-hide tick labels-%
                    axis.showticklabels = false;

                    %-axis autorange-%
                    axis.autorange = true;
                else %-axis show tick labels as tickLabels matlab field-%
                    axis.showticklabels = true;
                    % axis.type = 'linear';

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

    %---------------------------------------------------------------------%

    %-scale direction-%
    if strcmp(childAxisData.Direction, 'reverse')
        axis.range = [axis.range(2) axis.range(1)];
    end

    %---------------------------------------------------------------------%

    %-y-axis label-%
    label = childAxisData.Label;
    labelData = label;

    %STANDARDIZE UNITS
    fontunits = label.FontUnits;
    set(label,'FontUnits','points');

    %---------------------------------------------------------------------%

    %-title settings-%
    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = sprintf("rgb(%d,%d,%d)", ...
            round(255*labelData.Color));
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    %---------------------------------------------------------------------%

    %REVERT UNITS
    set(label,'FontUnits',fontunits);

    %---------------------------------------------------------------------%

    if strcmp(childAxisData.Visible,'on')
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

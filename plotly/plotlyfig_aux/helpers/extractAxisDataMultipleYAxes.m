function [axis, axisLim] = extractAxisDataMultipleYAxes(obj,parentAxisData,yaxIndex)

    childAxisData = get(parentAxisData.YAxis(yaxIndex));

    %-------------------------------------------------------------------------%

    %-axis-side-%
    if yaxIndex == 1
        axis.side = 'left';
    elseif yaxIndex == 2
        axis.side = 'right';
    end

    %-------------------------------------------------------------------------%

    %-y-axis initializations-%
    axis.zeroline = false;
    axis.autorange = false;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

    %-------------------------------------------------------------------------%

    %-y-axis tick font size-%
    axis.tickfont.size = childAxisData.FontSize;

    %-------------------------------------------------------------------------%

    %-y-axis tick font family-%
    axis.tickfont.family = matlab2plotlyfont(childAxisData.FontName);

    %-------------------------------------------------------------------------%

    ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(childAxisData.TickLength(1)*parentAxisData.Position(3)*obj.layout.width,...
        childAxisData.TickLength(1)*parentAxisData.Position(4)*obj.layout.height));
    %-y-axis ticklen-%
    axis.ticklen = ticklength;

    %-------------------------------------------------------------------------%

    %-y-axis coloring-%
    axiscol = sprintf('rgb(%f,%f,%f)', 255*childAxisData.Color);

    axis.linecolor = axiscol;
    axis.tickcolor = axiscol;
    axis.tickfont.color = axiscol;

    try
        axis.gridcolor = sprintf('rgba(%f,,%f,%f,%f)', 255*parentAxisData.GridColor, parentAxisData.GridAlpha);
    catch
        axis.gridcolor = axiscol;
    end

    %-------------------------------------------------------------------------%

    %-axis show grid-%
    if strcmp(parentAxisData.YGrid, 'on')
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end

    %-------------------------------------------------------------------------%

    % grid = eval(['parentAxisData.' axisName 'Grid;']);
    % minorGrid = eval(['parentAxisData.' axisName 'MinorGrid;']);

    % if strcmp(grid, 'on') || strcmp(minorGrid, 'on')
    %     %-axis show grid-%
    %     axis.showgrid = true;
    % else
    %     axis.showgrid = false;
    % end

    %-------------------------------------------------------------------------%

    %-line widths-%
    linewidth = max(1,childAxisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    axis.linewidth = linewidth;
    axis.tickwidth = linewidth;
    axis.gridwidth = linewidth;

    %-------------------------------------------------------------------------%

    %-axis type-%
    axis.type = childAxisData.Scale;

    %-------------------------------------------------------------------------%

    %-axis showtick labels / ticks-%
    tickValues = childAxisData.TickValues;

    if isempty(tickValues)
        
        %-axis ticks-%
        axis.ticks = '';
        axis.showticklabels = false;
        
        %-axis autorange-%
        axis.autorange = true; 
        
        %---------------------------------------------------------------------%
        
        % switch parentAxisData.Box
        %     case 'on'
        %         %-axis mirror-%
        %         axis.mirror = true;
        %     case 'off'
        %         axis.mirror = false;
        % end
        
        %---------------------------------------------------------------------%

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
        % switch parentAxisData.Box
        %     case 'on'
        %         %-axis mirror-%
        %         axis.mirror = 'ticks';
        %     case 'off'
        %         axis.mirror = false;
        % end
        
        %---------------------------------------------------------------------%
        
        %-LOG TYPE-%
        if strcmp(axis.type, 'log')
            
            %-axis range-%
            axis.range = log10(axisLim);
            %-axis autotick-%
            axis.autotick = true;
            %-axis nticks-%
            axis.nticks = length(tickValues) + 1;
         
        %---------------------------------------------------------------------%
        
        %-LINEAR TYPE-%
        elseif strcmp(axis.type, 'linear')

            %-----------------------------------------------------------------%

            %-get tick label mode-%
            tickLabelMode = childAxisData.TickLabelsMode;

            %-----------------------------------------------------------------%

            %-AUTO MODE-%
            if strcmp(tickLabelMode, 'auto')
                
                %-------------------------------------------------------------%
                
                if isnumeric(axisLim)
                    axis.range = axisLim;
                    
                %-------------------------------------------------------------%
                
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
                   
                %-------------------------------------------------------------%
                
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

            %-----------------------------------------------------------------%
            
            %-CUSTOM MODE-%
            else

                %-------------------------------------------------------------%

                %-get tick labels-%
                tickLabels = childAxisData.TickLabels;

                %-------------------------------------------------------------%

                %-hide tick labels as lichkLabels field is empty-%
                if isempty(tickLabels)
                    
                    %-------------------------------------------------------------%

                    %-hide tick labels-%
                    axis.showticklabels = false;

                    %-------------------------------------------------------------%

                    %-axis autorange-%
                    axis.autorange = true;

                    %-------------------------------------------------------------%

                %-axis show tick labels as tickLabels matlab field-%
                else

                    %-------------------------------------------------------------%

                    axis.showticklabels = true;
                    % axis.type = 'linear';

                    %-------------------------------------------------------------%

                    if isnumeric(axisLim)
                        axis.range = axisLim;
                    else
                        axis.autorange = true;
                    end
                    
                    %-------------------------------------------------------------%

                    axis.tickvals = tickValues;
                    axis.ticktext = tickLabels;

                    %-------------------------------------------------------------%

                    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
                    % NOTE: 
                    %    The next piece of code was replaced by the previous one. 
                    %    I think that the new piece of code is better, optimal and 
                    %    extends to all cases. However, I will leave this piece of 
                    %    code commented in case there is a problem in the future.
                    %
                    %    If there is a problem with the new piece of code, please 
                    %    comment and uncomment the next piece of code.
                    %
                    %    If everything goes well with the new gripping piece, at 
                    %    the end of the development we will be able to remove the 
                    %    commented lines
                    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

                    %-axis labels
                    % labels = str2double(tickLabels);
                    % try 
                    %     %find numbers in labels
                    %     labelnums = find(~isnan(labels));
                    %     %-axis type linear-%
                    %     axis.type = 'linear';
                    %     %-range (overwrite)-%
                    %     delta = (labels(labelnums(2)) - labels(labelnums(1)))/(labelnums(2)-labelnums(1));
                    %     axis.range = [labels(labelnums(1))-delta*(labelnums(1)-1) labels(labelnums(1)) + (length(labels)-labelnums(1))*delta];
                    %     %-axis autotick-%
                    %     axis.autotick = true;
                    %     %-axis numticks-%
                    %     axis.nticks = eval(['length(parentAxisData.' axisName 'Tick) + 1;']);
                    % catch
                    %     %-axis type category-%
                    %     axis.type = 'category';
                    %     %-range (overwrite)-%
                    %     axis.autorange = true;
                    %     %-axis autotick-%
                    %     % axis.autotick = true;
                    % end
                end
            end
        end
    end

    %-------------------------------------------------------------------------%

    %-scale direction-%
    if strcmp(childAxisData.Direction, 'reverse')
        axis.range = [axis.range(2) axis.range(1)];
    end

    %-------------------------------------------------------------------------%

    %-y-axis label-%
    label = childAxisData.Label;
    labelData = get(label);

    %STANDARDIZE UNITS
    fontunits = get(label,'FontUnits');
    set(label,'FontUnits','points');

    %-------------------------------------------------------------------------%

    %-title settings-%
    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = sprintf('rgb(%f,%f,%f)', 255*labelData.Color);
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    %-------------------------------------------------------------------------%

    %REVERT UNITS
    set(label,'FontUnits',fontunits);

    %-------------------------------------------------------------------------%

    if strcmp(childAxisData.Visible,'on')
        %-axis showline-%
        axis.showline = true;
    else
        %-axis showline-%
        axis.showline = false;
        %-axis showticklabels-%
        axis.showticklabels = false;
        %-axis ticks-%
        axis.ticks = '';
        %-axis showline-%
        axis.showline = false;
        %-axis showticklabels-%
        axis.showticklabels = false;
        %-axis ticks-%
        axis.ticks = '';
    end

    %-------------------------------------------------------------------------%
end



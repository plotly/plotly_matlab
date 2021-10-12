function [axis, exponentFormat] = extractAxisData(obj,axisData,axisName)
    % extract information related to each axis
    %   axisData is the data extrated from the figure, axisName take the
    %   values 'x' 'y' or 'z'

    %=========================================================================%
    %
    % AXIS INITIALIZATION
    %
    %=========================================================================%

    %-general axis settings-%
    axisColor = 255 * eval(sprintf('axisData.%sColor', axisName));
    axisColor = sprintf('rgb(%f,%f,%f)', axisColor);
    lineWidth = max(1,axisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);
    exponentFormat = eval(sprintf('axisData.%sAxis.Exponent', axisName));

    axis.side = eval(sprintf('axisData.%sAxisLocation', axisName));
    axis.zeroline = false;
    axis.autorange = false;
    axis.linecolor = axisColor;
    axis.linewidth = lineWidth;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

    %-------------------------------------------------------------------------%

    %-general tick settings-%
    tickRotation = eval(sprintf('axisData.%sTickLabelRotation', axisName));
    tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(axisData.TickLength(1)*axisData.Position(3)*obj.layout.width,...
        axisData.TickLength(1)*axisData.Position(4)*obj.layout.height));

    axis.tickfont.size = axisData.FontSize;
    axis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    axis.tickfont.color = axisColor;

    axis.ticklen = tickLength;
    axis.tickcolor = axisColor;
    axis.tickwidth = lineWidth;
    axis.tickangle = -tickRotation;

    switch axisData.TickDir
        case 'in'
            axis.ticks = 'inside';
        case 'out'
            axis.ticks = 'outside';
    end

    %-------------------------------------------------------------------------%

    %-set axis grid-%

    isGrid = sprintf('axisData.%sGrid', axisName);
    isMinorGrid = sprintf('axisData.%sMinorGrid', axisName);

    if strcmp(isGrid, 'on') || strcmp(isMinorGrid, 'on')
        axis.showgrid = true;
        axis.gridwidth = lineWidth;
    else
        axis.showgrid = false;
    end

    %-------------------------------------------------------------------------%

    %-axis grid color-%
    try
        gridColor = 255*axisData.GridColor;
        gridAlpha = axisData.GridAlpha;
        axis.gridcolor = sprintf('rgba(%f,,%f,%f,%f)', gridColor, gridAlpha);
    catch
        axis.gridcolor = axisColor;
    end

    %-------------------------------------------------------------------------%

    %-axis type-%
    axis.type = eval(sprintf('axisData.%sScale', axisName));

    %=========================================================================%
    %
    % SET TICK LABELS
    %
    %=========================================================================%

    %-get tick label data-%
    tickLabels = eval(sprintf('axisData.%sTickLabel', axisName));
    tickValues = eval(sprintf('axisData.%sTick', axisName));
    if isduration(tickValues), tickValues = datenum(tickValues); end

    %-------------------------------------------------------------------------%

    %-there is not tick label case-%
    if isempty(tickValues) && isempty(tickLabels)
        
        axis.ticks = '';
        axis.showticklabels = false;
        axis.autorange = true; 
        
        switch axisData.Box
            case 'on'
                axis.mirror = true;
            case 'off'
                axis.mirror = false;
        end

    %-------------------------------------------------------------------------%

    %-there is tick labels-%
    else

        %---------------------------------------------------------------------%

        %-some tick label settings-%
        axisLim = eval( sprintf('axisData.%sLim', axisName) );
        if isduration(axisLim), axisLim = datenum(axisLim); end

        switch axisData.Box
            case 'on'
                axis.mirror = 'ticks';
            case 'off'
                axis.mirror = false;
        end

        if isnumeric(axisLim)
            if strcmp(axis.type, 'linear')
                axis.range = axisLim;
            elseif strcmp(axis.type, 'log')
                axis.range = log10(axisLim);
            end

        else
            axis.autorange = true;
        end

        axis.showticklabels = true;

        %---------------------------------------------------------------------%

        %-set tick labels by using tick values and tick texts-%
        if ~isempty(tickValues) && ~isempty(tickLabels)
            axis.tickmode = 'array';
            axis.tickvals = tickValues;
            axis.ticktext = tickLabels;

        %---------------------------------------------------------------------%

        %-set tick labels by using only tick values-%
        elseif ~isempty(tickValues) && isempty(tickLabels)
            axis.tickmode = 'array';
            axis.tickvals = tickValues;

            %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
            %
            % TODO: determine if following code piece is necessary. For this we need 
            %       to test fig2plotly with more examples
            %
            %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

            % %-LOG TYPE-%
            % if strcmp(axis.type,'log')

            %     axis.range = log10(axisLim);
            %     axis.autotick = true;
            %     axis.nticks = eval(['length(axisData.' axisName 'Tick) + 1;']);

            % %---------------------------------------------------------------------%

            % %-LINEAR TYPE-%
            % elseif strcmp(axis.type,'linear')

            %     %-----------------------------------------------------------------%

            %     % %-get tick label mode-%
            %     % tickLabelMode = eval(['axisData.' axisName 'TickLabelMode;']);

            %     % %-----------------------------------------------------------------%

            %     % %-AUTO MODE-%
            %     % if strcmp(tickLabelMode,'auto')

            %         %-------------------------------------------------------------%
                
            %         if isnumeric(axisLim)
            %             %-axis range-%
            %             axis.range = axisLim;
            %             %-axis tickvals-%
            %             axis.tickvals = tick;
                    
            %         %-------------------------------------------------------------%
                
            %         elseif isduration(axisLim)
            %            [temp,type] = convertDuration(axisLim);

            %            if (~isduration(temp))              
            %                axis.range = temp;
            %                axis.type = 'duration';
            %                axis.title = type;
            %            else
            %                nticks = eval(['length(axisData.' axisName 'Tick)-1;']);
            %                delta = 0.1;
            %                axis.range = [-delta nticks+delta];
            %                axis.type = 'duration - specified format';     
            %            end
                   
            %         %-------------------------------------------------------------%
                
            %         elseif isdatetime(axisLim)
            %             axis.range = convertDate(axisLim);
            %             axis.type = 'date'; 
            %         else 
            %             % data is a category type other then duration and datetime
            %         end

            %         %-------------------------------------------------------------%

            %         if ~isnumeric(axisLim)
            %             %-axis autotick-%
            %             axis.autotick = true;
            %             %-axis numticks-%       
            %             axis.nticks = eval(['length(axisData.' axisName 'Tick)+1']);
            %         end
            %     end
            % end

            %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

        end
    end

    %-------------------------------------------------------------------------%

    %-axis direction-%
    axisDirection = eval(sprintf('axisData.%sDir', axisName));

    if strcmp(axisDirection,'reverse')
        axis.range = [axis.range(2) axis.range(1)];
    end

    %=========================================================================%
    %
    % SET AXIS LABEL
    %
    %=========================================================================%

    %-get label data-%
    label = eval(sprintf('axisData.%sLabel', axisName));
    labelData = get(label);

    %-------------------------------------------------------------------------%

    %-STANDARDIZE UNITS-%
    fontunits = get(label,'FontUnits');
    set(label,'FontUnits','points');

    %-------------------------------------------------------------------------%

    %-title label settings-%
    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = sprintf('rgb(%f,%f,%f)', 255*labelData.Color);
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    %-------------------------------------------------------------------------%

    %-REVERT UNITS-%
    set(label,'FontUnits',fontunits);

    %-------------------------------------------------------------------------%

    %-set visibility conditions-%
    if strcmp(axisData.Visible,'on')
        axis.showline = true;
    else
        axis.showticklabels = false;
        axis.showline = false;
        axis.ticks = '';
    end

    %-------------------------------------------------------------------------%
end



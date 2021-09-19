function [axis] = extractAxisData(obj,axis_data,axisName)
%extract information related to each axis
%   axis_data is the data extrated from the figure, axisName take the
%   values 'x' 'y' or 'z'


%-------------------------------------------------------------------------%

%-axis-side-%
try
    axis.side = eval(['axis_data.' axisName 'AxisLocation;']);
catch
    if axisName == 'X'
        axis.side = 'bottom';
    elseif axisName == 'Y'
        axis.side = 'left';
    end
end
%-------------------------------------------------------------------------%

%-axis zeroline-%
axis.zeroline = false;

%-------------------------------------------------------------------------%

%-axis autorange-%
axis.autorange = false;

%-------------------------------------------------------------------------%

%-axis exponent format-%
axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

%-------------------------------------------------------------------------%

%-axis tick font size-%
axis.tickfont.size = axis_data.FontSize;

%-------------------------------------------------------------------------%

%-axis tick font family-%
axis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

%-------------------------------------------------------------------------%

try
    ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(axis_data.TickLength(1)*axis_data.Position(3)*obj.layout.width,...
        axis_data.TickLength(1)*axis_data.Position(4)*obj.layout.height));
%-axis ticklen-%
    axis.ticklen = ticklength;
catch
    axis.ticklen = 0;
end
%-------------------------------------------------------------------------%

try
    col = eval(['255*axis_data.' axisName 'Color;']);
catch
    col = [0,0,0];
end
axiscol = sprintf('rgb(%i,%i,%i)',col);

%-axis linecolor-%
axis.linecolor = axiscol;
%-axis tickcolor-%
axis.tickcolor = axiscol;
%-axis tickfont-%
axis.tickfont.color = axiscol;
%-axis grid color-%
axis.gridcolor = axiscol;

%-------------------------------------------------------------------------%
try
    if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
        %-axis show grid-%
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end
catch
   axis.showgrid = false; 
end
%-------------------------------------------------------------------------%

try
    grid = eval(['axis_data.' axisName 'Grid;']);
    minorGrid = eval(['axis_data.' axisName 'MinorGrid;']);

    if strcmp(grid, 'on') || strcmp(minorGrid, 'on')
        %-axis show grid-%
        axis.showgrid = true;
    else
        axis.showgrid = false;
    end
catch
    axis.showgrid = false;
end

%-------------------------------------------------------------------------%
try
    linewidth = max(1,axis_data.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);
catch
    linewidth = 0;
end

%-axis line width-%
axis.linewidth = linewidth;
%-axis tick width-%
axis.tickwidth = linewidth;
%-axis grid width-%
axis.gridwidth = linewidth;

%-------------------------------------------------------------------------%

%-axis type-%
try
    axis.type = eval(['axis_data.' axisName 'Scale']);
catch
    axis.type = 'linear';
end

%-------------------------------------------------------------------------%

%-axis showtick labels / ticks-%
try
    tick = eval(['axis_data.' axisName 'Tick']);
catch
    tick=[];
end

if isempty(tick)
    
    %-axis ticks-%
    axis.ticks = '';
    axis.showticklabels = false;
    
    %-axis autorange-%
    axis.autorange = true; 
    
    %---------------------------------------------------------------------%
    try
        switch axis_data.Box
            case 'on'
                %-axis mirror-%
                axis.mirror = true;
            case 'off'
                axis.mirror = false;
        end
    catch
        axis.mirror = true;
    end
    
    %---------------------------------------------------------------------%

else

    %-get axis limits-%
    dataLim = eval( sprintf('axis_data.%sLim', axisName) );
    
    %-axis tick direction-%
    switch axis_data.TickDir
        case 'in'
            axis.ticks = 'inside';
        case 'out'
            axis.ticks = 'outside';
    end
    
    %---------------------------------------------------------------------%
    switch axis_data.Box
        case 'on'
            %-axis mirror-%
            axis.mirror = 'ticks';
        case 'off'
            axis.mirror = false;
    end
    
    %---------------------------------------------------------------------%
    
    %-LOG TYPE-%
    if strcmp(axis.type,'log')
        
        %-axis range-%
        axis.range = eval( sprintf('log10(dataLim)') ); %['log10(axis_data.' axisName 'Lim);']);
        %-axis autotick-%
        axis.autotick = true;
        %-axis nticks-%
        axis.nticks = eval(['length(axis_data.' axisName 'Tick) + 1;']);
     
    %---------------------------------------------------------------------%
    
    %-LINEAR TYPE-%
    elseif strcmp(axis.type,'linear')

        %-----------------------------------------------------------------%

        %-get tick label mode-%
        TickLabelMode = eval(['axis_data.' axisName 'TickLabelMode;']);

        %-----------------------------------------------------------------%

        %-AUTO MODE-%
        if strcmp(TickLabelMode,'auto')
            
            %-------------------------------------------------------------%
            
            if isnumeric(dataLim)
                axis.range = dataLim;
                
            %-------------------------------------------------------------%
            
            elseif isduration(dataLim)
               [temp,type] = convertDuration(dataLim);

               if (~isduration(temp))              
                   axis.range = temp;
                   axis.type = 'duration';
                   axis.title = type;
               else
                   nticks = eval(['length(axis_data.' axisName 'Tick)-1;']);
                   delta = 0.1;
                   axis.range = [-delta nticks+delta];
                   axis.type = 'duration - specified format';     
               end
               
            %-------------------------------------------------------------%
            
            elseif isdatetime(dataLim)
                axis.range = convertDate(dataLim);
                axis.type = 'date'; 
            else 
                % data is a category type other then duration and datetime
            end

            %-axis autotick-%
            axis.autotick = true;
            %-axis numticks-%       
            axis.nticks = eval(['length(axis_data.' axisName 'Tick)+1']);

        %-----------------------------------------------------------------%
        
        %-CUSTOM MODE-%
        else

            %-------------------------------------------------------------%

            %-get tick labels-%
            tickLabels = eval(['axis_data.' axisName 'TickLabel;']);

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
                axis.type = 'linear';

                %-------------------------------------------------------------%

                if isnumeric(dataLim)
                    axis.range = eval(['axis_data.' axisName 'Lim;']);
                else
                    axis.autorange = true;
                end
                
                %-------------------------------------------------------------%

                axis.tickvals = tick;
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
                %     axis.nticks = eval(['length(axis_data.' axisName 'Tick) + 1;']);
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
try
    Dir = eval(['axis_data.' axisName 'Dir;']);
catch
    Dir = '';
end
if strcmp(Dir,'reverse')
    axis.range = [axis.range(2) axis.range(1)];
end

%-------------------------------LABELS------------------------------------%
try
    label = eval(['axis_data.' axisName 'Label;']);
catch
    label=[];
end
if ~isempty(label)
    label_data = get(label);

    %STANDARDIZE UNITS
    fontunits = get(label,'FontUnits');
    set(label,'FontUnits','points');

    %-------------------------------------------------------------------------%

    %-title-%
    if ~isempty(label_data.String)
        axis.title = parseString(label_data.String,label_data.Interpreter);
    end

    %-------------------------------------------------------------------------%

    %-axis title font color-%
    col = 255*label_data.Color;
    axis.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

    %-------------------------------------------------------------------------%

    %-axis title font size-%
    axis.titlefont.size = label_data.FontSize;

    %-------------------------------------------------------------------------%

    %-axis title font family-%
    axis.titlefont.family = matlab2plotlyfont(label_data.FontName);

    %-------------------------------------------------------------------------%

    %REVERT UNITS
    set(label,'FontUnits',fontunits);
end
%-------------------------------------------------------------------------%

if strcmp(axis_data.Visible,'on')
    %-axis showline-%
    axis.showline = true;
else
    %-axis showline-%
    axis.showline = false;
    %-axis showticklabels-%
    axis.showticklabels = false;
    %-axis ticks-%
    axis.ticks = '';
end

%-------------------------------------------------------------------------%
end



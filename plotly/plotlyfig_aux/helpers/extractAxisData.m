function [axis] = extractAxisData(obj,axis_data,axisName)
%extract information related to each axis
%   axis_data is the data extrated from the figure, axisName take the
%   values 'x' 'y' or 'z'


%-------------------------------------------------------------------------%

%-axis-side-%
axis.side = eval(['axis_data.' axisName 'AxisLocation;']);

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

ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
    max(axis_data.TickLength(1)*axis_data.Position(3)*obj.layout.width,...
    axis_data.TickLength(1)*axis_data.Position(4)*obj.layout.height));
%-axis ticklen-%
axis.ticklen = ticklength;

%-------------------------------------------------------------------------%

col = eval(['255*axis_data.' axisName 'Color;']);
axiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

%-axis linecolor-%
axis.linecolor = axiscol;
%-axis tickcolor-%
axis.tickcolor = axiscol;
%-axis tickfont-%
axis.tickfont.color = axiscol;
%-axis grid color-%
axis.gridcolor = axiscol;

%-------------------------------------------------------------------------%

if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
    %-axis show grid-%
    axis.showgrid = true;
else
    axis.showgrid = false;
end

%-------------------------------------------------------------------------%

grid = eval(['axis_data.' axisName 'Grid;']);
minorGrid = eval(['axis_data.' axisName 'MinorGrid;']);

if strcmp(grid, 'on') || strcmp(minorGrid, 'on')
    %-axis show grid-%
    axis.showgrid = true;
else
    axis.showgrid = false;
end

%-------------------------------------------------------------------------%

linewidth = max(1,axis_data.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

%-axis line width-%
axis.linewidth = linewidth;
%-axis tick width-%
axis.tickwidth = linewidth;
%-axis grid width-%
axis.gridwidth = linewidth;

%-------------------------------------------------------------------------%

%-axis type-%

axis.type = eval(['axis_data.' axisName 'Scale']);

%-------------------------------------------------------------------------%

%-axis showtick labels / ticks-%
tick = eval(['axis_data.' axisName 'Tick']);
if isempty(tick)
    
    %-axis ticks-%
    axis.ticks = '';
    axis.showticklabels = false;
    
    %-axis autorange-%
    axis.autorange = true; 
    
    %---------------------------------------------------------------------%
    
    switch axis_data.Box
        case 'on'
            %-axis mirror-%
            axis.mirror = true;
        case 'off'
            axis.mirror = false;
    end
    
    %---------------------------------------------------------------------%

else
    
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
    
    if strcmp(axis.type,'log')
        
        %-axis range-%
        axis.range = eval(['log10(axis_data.' axisName 'Lim);']);
        %-axis autotick-%
        axis.autotick = true;
        %-axis nticks-%
        axis.nticks = eval(['length(axis_data.' axisName 'Tick) + 1;']);
     
    %---------------------------------------------------------------------%
    
    elseif strcmp(axis.type,'linear')
        TickLabelMode = eval(['axis_data.' axisName 'TickLabelMode;']);
        if strcmp(TickLabelMode,'auto')
            
            %-axis range-%
            dataLim = eval(['axis_data.' axisName 'Lim']);
            
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
        
        else
            %-axis show tick labels-%
            Tick = eval(['axis_data.' axisName 'TickLabel;']);
            if isempty(Tick)
                %-hide tick labels-%
                axis.showticklabels = false;
                %-axis autorange-%
                axis.autorange = true;
            else
                %-axis labels
                labels = str2double(axis_data.YTickLabel);
                try 
                    %find numbers in labels
                    labelnums = find(~isnan(labels));
                    %-axis type linear-%
                    axis.type = 'linear';
                    %-range (overwrite)-%
                    delta = (labels(labelnums(2)) - labels(labelnums(1)))/(labelnums(2)-labelnums(1));
                    axis.range = [labels(labelnums(1))-delta*(labelnums(1)-1) labels(labelnums(1)) + (length(labels)-labelnums(1))*delta];
                    %-axis autotick-%
                    axis.autotick = true;
                    %-axis numticks-%
                    axis.nticks = eval(['length(axis_data.' axisName 'Tick) + 1;']);
                catch
                    %-axis type category-%
                    axis.type = 'category';
                    %-range (overwrite)-%
                    axis.autorange = true;
                    %-axis autotick-%
                    % axis.autotick = true;
                end
            end
        end
    end
end

%-------------------------------------------------------------------------%

Dir = eval(['axis_data.' axisName 'Dir;']);
if strcmp(Dir,'reverse')
    axis.range = [axis.range(2) axis.range(1)];
end

%-------------------------------LABELS------------------------------------%

label = eval(['axis_data.' axisName 'Label;']);

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
    %-axis showline-%
    axis.showline = false;
    %-axis showticklabels-%
    axis.showticklabels = false;
    %-axis ticks-%
    axis.ticks = '';
end

%-------------------------------------------------------------------------%
end



%----UPDATE AXIS DATA/LAYOUT----%

function obj = updateAxis(obj,axIndex)

% title: ...[DONE]
% titlefont:...[DONE]
% range:...[DONE]
% domain:...[DONE]
% type:...[DONE]
% rangemode:...[NOT SUPPORTED IN MATLAB]
% autorange:...[DONE]
% showgrid:...[DONE]
% zeroline:...[DONE]
% showline:...[DONE
% autotick:...[DONE]
% nticks:...[DONE]
% ticks:...[DONE]
% showticklabels:...[DONE]
% tick0:...[DONE]
% dtick:...[DONE]
% ticklen:...[DONE]
% tickwidth:...[DONE]
% tickcolor:...[DONE]
% tickangle:...[NOT SUPPORTED IN MATLAB]
% tickfont:...[DONE]
% tickfont.family...[DONE]
% tickfont.size...[DONE]
% tickfont.color...[DONE]
% tickfont.outlinecolor...[NOT SUPPORTED IN MATLAB]
% exponentformat:...[DONE]
% showexponent:...[NOT SUPPORTED IN MATLAB]
% mirror:...[DONE]
% gridcolor:...[DONE]
% gridwidth:...[DONE]
% zerolinecolor:...[NOT SUPPORTED IN MATLAB]
% zerolinewidth:...[NOT SUPPORTED IN MATLAB]
% linecolor:...[DONE]
% linewidth:...[DONE]
% anchor:...[DONE]
% overlaying:...[NOT SUPPORTED IN MATLAB]
% side:...[DONE]
% position:...[NOT SUPPORTED IN MATLAB]

%-STANDARDIZE UNITS-%
axisunits = get(obj.State.Axis(axIndex).Handle,'Units');
fontunits = get(obj.State.Axis(axIndex).Handle,'FontUnits');
set(obj.State.Axis(axIndex).Handle,'Units','normalized');
set(obj.State.Axis(axIndex).Handle,'FontUnits','points');

%-FIGURE DATA-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA STRUCTURE-%
axis_data = get(obj.State.Axis(axIndex).Handle);

%-------------------------------------------------------------------------%

%-xaxis domain-%
xaxis.domain = min([axis_data.Position(1) axis_data.Position(1)+axis_data.Position(3)],1);

%-------------------------------------------------------------------------%

%-yaxis domain-%
yaxis.domain = min([axis_data.Position(2) axis_data.Position(2)+axis_data.Position(4)],1);

%-------------------------------------------------------------------------%

%-xaxis-side-%
xaxis.side = axis_data.XAxisLocation;

%-------------------------------------------------------------------------%

%-yaxis-side-%
yaxis.side = axis_data.YAxisLocation;

%-------------------------------!STYLE!-----------------------------------%

if ~obj.PlotOptions.Strip
    
    %---------------------------------------------------------------------%
    
    %-layout plot bg color-%
    if isnumeric(axis_data.Color)
        col = 255*axis_data.Color;
    else
        col = 255*figure_data.Color;
    end
    
    obj.layout.plot_bgcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %---------------------------------------------------------------------%
    
    %-xaxis zeroline-%
    xaxis.zeroline = false;
    
    %---------------------------------------------------------------------%
    
    %-xaxis autorange-%
    xaxis.autorange = false;
    
    %---------------------------------------------------------------------%
    
    %-yaxis zeroline-%
    yaxis.zeroline = false;
    
    %---------------------------------------------------------------------%
    
    %-yaxis autorange-%
    yaxis.autorange = false;
    
    %---------------------------------------------------------------------%
    
    %-xaxis exponent format-%
    xaxis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    
    %---------------------------------------------------------------------%
    
    %-yaxis exponent format-%
    yaxis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    
    %---------------------------------------------------------------------%
    
    %-xaxis tick font size-%
    xaxis.tickfont.size = axis_data.FontSize;
    
    %---------------------------------------------------------------------%
    
    %-yaxis tick font size-%
    yaxis.tickfont.size = axis_data.FontSize;
    
    %---------------------------------------------------------------------%
    
    %-xaxis tick font family-%
    xaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);
    
    %---------------------------------------------------------------------%
    
    %-yaxis tick font family-%
    yaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);
    
    %----------------------------------------------------------------------%
    
    ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(axis_data.TickLength(1)*axis_data.Position(3)*obj.layout.width,...
        axis_data.TickLength(1)*axis_data.Position(4)*obj.layout.height));
    %-xaxis ticklen-%
    xaxis.ticklen = ticklength;
    %-yaxis ticklen-%
    yaxis.ticklen = ticklength;
    
    %---------------------------------------------------------------------%
    
    col = 255*axis_data.XColor;
    xaxiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-xaxis linecolor-%
    xaxis.linecolor = xaxiscol;
    %-xaxis tickcolor-%
    xaxis.tickcolor = xaxiscol;
    %-xaxis tickfont-%
    xaxis.tickfont.color = xaxiscol;
    %-xaxis grid color-%
    xaxis.gridcolor = xaxiscol;
    
    %---------------------------------------------------------------------%
    
    col = 255*axis_data.XColor;
    yaxiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-yaxis linecolor-%
    yaxis.linecolor = yaxiscol;
    %-yaxis tickcolor-%
    yaxis.tickcolor = yaxiscol;
    %-yaxis tickfont-%
    yaxis.tickfont.color = yaxiscol;
    %-yaxis grid color-%
    yaxis.gridcolor = yaxiscol;
    
    %---------------------------------------------------------------------%
    
    if strcmp(axis_data.Visible,'on')
        %-xaxis showline-%
        xaxis.showline = true;
        %-xaxis showticklabels-%
        xaxis.showticklabels = true;
        %-yaxis showline-%
        yaxis.showline = true;
        %-yaxis showticklabels-%
        yaxis.showticklabels = true;
    else
        %-xaxis showline-%
        xaxis.showline = false;
        %-xaxis showticklabels-%
        xaxis.showticklabels = false;
        %-yaxis showline-%
        yaxis.showline = false;
        %-yaxis showticklabels-%
        yaxis.showticklabels = false;
    end
    
    %---------------------------------------------------------------------%
    
    if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
        %-xaxis show grid-%
        xaxis.showgrid = true;
    else
        xaxis.showgrid = false;
    end
    
    %---------------------------------------------------------------------%
    
    if strcmp(axis_data.YGrid,'on') || strcmp(axis_data.YMinorGrid,'on')
        %yaxis show grid-%
        yaxis.showgrid = true;
    else
        yaxis.showgrid = false;
    end
    
    %---------------------------------------------------------------------%
    
    linewidth = max(1,axis_data.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);
    
    %-xaxis line width-%
    xaxis.linewidth = linewidth;
    %-yaxis line width-%
    yaxis.linewidth = linewidth;
    %-xaxis tick width-%
    xaxis.tickwidth = linewidth;
    %-yaxis tick width-%
    yaxis.tickwidth = linewidth;
    %-xaxis grid width-%
    xaxis.gridwidth = linewidth;
    %-yaxis grid width-%
    yaxis.gridwidth = linewidth;
    
    %---------------------------------------------------------------------%
    
    %-xaxis type-%
    xaxis.type = axis_data.XScale;
    
    %---------------------------------------------------------------------%
    
    %-xaxis showtick labels / ticks-%
    if isempty(axis_data.XTick)
        
        %-xaxis ticks-%
        xaxis.ticks = '';
        xaxis.showticklabels = false;
        
        %-----------------------------------------------------------------%
        
        switch axis_data.Box
            case 'on'
                %-xaxis mirror-%
                xaxis.mirror = true;
            case 'off'
                xaxis.mirror = false;
        end
        
        %-----------------------------------------------------------------%
        
    else
        
        %-xaxis tick direction-%
        switch axis_data.TickDir
            case 'in'
                xaxis.ticks = 'inside';
            case 'out'
                xaxis.ticks = 'outside';
        end
        
        %-----------------------------------------------------------------%
        
        switch axis_data.Box
            case 'on'
                %-xaxis mirror-%
                xaxis.mirror = 'ticks';
            case 'off'
                xaxis.mirror = false;
        end
        
        %-----------------------------------------------------------------%
        
        if strcmp(xaxis.type,'log')
            
            %-xaxis range-%
            xaxis.range = log10(axis_data.XLim);
            %-xaxis autotick-%
            xaxis.autotick = true;
            %-xaxis nticks-%
            xaxis.nticks = length(axis_data.XTick) + 1;
            
        elseif strcmp(xaxis.type,'linear')
            
            %-xaxis range-%
            xaxis.range = axis_data.XLim;
            
            if strcmp(axis_data.XTickLabelMode,'auto')
                %-xaxis autotick-%
                xaxis.autotick = true;
                %-xaxis numticks-%
                xaxis.nticks = length(axis_data.XTick) + 1;
            else
                %-xaxis show tick labels-%
                if isempty(axis_data.XTickLabel)
                    xaxis.showticklabels = false;
                else
                    try datevec(axis_data.XTickLabel(1,:),axis_data.UserData.plotly.xdateformat);
                        %-xaxis type date-%
                        xaxis.type = 'date';
                        %-range (overwrite)-%
                        xaxis.range = [convertDate(datenum(axis_data.XTickLabel(1,:),axis_data.UserData.plotly.xdateformat)), ...
                            convertDate(datenum(axis_data.XTickLabel(end,:),axis_data.UserData.plotly.xdateformat))];
                        %-xaxis autotick-%
                        xaxis.autotick = true;
                        %-xaxis numticks-%
                        xaxis.nticks = length(axis_data.XTick) + 1;
                    catch
                        %-xaxis type category-%
                        xaxis.type = 'category';
                        %-xaxis tick0-%
                        xaxis.tick0 = str2double(axis_data.XTickLabel(1,:));
                        %-xaxis dtick-%
                        xaxis.dtick = str2double(axis_data.XTickLabel(2,:))- str2double(axis_data.XTickLabel(1,:));
                        %-xaxis autotick-%
                        xaxis.autotick = false;
                    end
                end
            end
        end
    end
    
    %---------------------------------------------------------------------%
    
    if strcmp(axis_data.XDir,'reverse')
        xaxis.range = [xaxis.range(2) xaxis.range(1)];
    end
    
    %---------------------------------------------------------------------%
    
    xlabel = axis_data.XLabel;
    ylabel = axis_data.YLabel;
    
    xlabel_data = get(xlabel);
    ylabel_data = get(ylabel);
    
    %STANDARDIZE UNITS
    xfontunits = get(xlabel,'FontUnits');
    set(xlabel,'FontUnits','points');
    yfontunits = get(ylabel,'FontUnits');
    set(ylabel,'FontUnits','points');
    
    %-x title-%
    if ~isempty(xlabel_data.String)
        xaxis.title = parseString(xlabel_data.String,xlabel_data.Interpreter);
    else
        xaxis.title = ' ';
    end
    
    %-x title font color-%
    col = 255*xlabel_data.Color;
    xaxis.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-x title font size-%
    xaxis.titlefont.size = xlabel_data.FontSize;
    
    %-x title font family-%
    xaxis.titlefont.family = matlab2plotlyfont(xlabel_data.FontName);
    
    %-y title-%
    if ~isempty(ylabel_data.String)
        yaxis.title = parseString(ylabel_data.String, ylabel_data.Interpreter);
    else
        yaxis.title = ' ';
    end
    
    %-y title font color-%
    col = 255*ylabel_data.Color;
    yaxis.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-y title font size-%
    yaxis.titlefont.size = ylabel_data.FontSize;
    
    %-y title font family-%
    yaxis.titlefont.family = matlab2plotlyfont(ylabel_data.FontName);
    
    %REVERT UNITS
    set(xlabel,'FontUnits',xfontunits);
    set(ylabel,'FontUnits',yfontunits);
    
    %---------------------------------------------------------------------%
    
    %-yaxis type-%
    yaxis.type = axis_data.YScale;
    
    %---------------------------------------------------------------------%
    
    %-yaxis range-%
    yaxis.range = axis_data.YLim;
    
    %---------------------------------------------------------------------%
    
    %-yaxis show tick labels-%
    yaxis.showticklabels = true;
    
    %---------------------------------------------------------------------%
    
    %-yaxis showtick labels / ticks-%
    if isempty(axis_data.YTick)
        
        %-yaxis ticks-%
        yaxis.ticks = '';
        yaxis.showticklabels = false;
        
        %-----------------------------------------------------------------%
        
        switch axis_data.Box
            case 'on'
                %-yaxis mirror-%
                yaxis.mirror = true;
            case 'off'
                yaxis.mirror = false;
        end
        
        %-----------------------------------------------------------------%
        
    else
        
        %-yaxis tick direction-%
        switch axis_data.TickDir
            case 'in'
                yaxis.ticks = 'inside';
            case 'out'
                yaxis.ticks = 'outside';
        end
        
        %-----------------------------------------------------------------%
        
        switch axis_data.Box
            case 'on'
                %-yaxis mirror-%
                yaxis.mirror = 'ticks';
            case 'off'
                yaxis.mirror = false;
        end
        
        %-----------------------------------------------------------------%
        
        if strcmp(yaxis.type,'log')
            
            %-yaxis autotick-%
            yaxis.autotick = true;
            %-yaxis nticks-%
            yaxis.nticks = length(axis_data.YTick) + 1;
            
        elseif strcmp(yaxis.type,'linear')
            
            %-xaxis range-%
            yaxis.range = axis_data.YLim;
            
            if strcmp(axis_data.YTickLabelMode,'auto')
                %-xaxis autotick-%
                yaxis.autotick = true;
                %-xaxis numticks-%
                yaxis.nticks = length(axis_data.YTick) + 1;
            else
                %-yaxis show tick labels-%
                if isempty(axis_data.YTickLabel)
                    yaxis.showticklabels = false;
                else
                    try datevec(axis_data.YTickLabel(1,:),axis_data.UserData.plotly.ydateformat);
                        %-yaxis type date-%
                        yaxis.type = 'date';
                        %-range (overwrite)-%
                        yaxis.range = [convertDate(datenum(axis_data.YTickLabel(1,:),axis_data.UserData.plotly.ydateformat)), ...
                            convertDate(datenum(axis_data.YTickLabel(end,:),axis_data.UserData.plotly.ydateformat))];
                        %-yaxis autotick-%
                        yaxis.autotick = true;
                        %-yaxis numticks-%
                        yaxis.nticks = length(axis_data.YTick) + 1;
                    catch
                        %-yaxis type category-%
                        yaxis.type = 'category';
                        %-yaxis tick0-%
                        yaxis.tick0 = str2double(axis_data.YTickLabel(1,:));
                        %-yaxis dtick-%
                        yaxis.dtick = str2double(axis_data.YTickLabel(2,:))- str2double(axis_data.YTickLabel(1,:));
                        %-yaxis autotick-%
                        yaxis.autotick = false;
                    end
                end
            end
        end
    end
    
    %---------------------------------------------------------------------%
    
    if strcmp(axis_data.YDir,'reverse')
        yaxis.range = [yaxis.range(2) yaxis.range(1)];
    end
    
    %---------------------------------------------------------------------%
    
end

%-------------------------HANDLE MULTIPLE AXES----------------------------%

overlapping = isOverlapping(obj, axIndex);
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-------------------------------------------------------------------------%

%-xaxis anchor-%
xaxis.anchor = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-yaxis anchor-%
yaxis.anchor = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

% make overlap specific style modifications
if overlapping
    
    % fix x mirror
    if xsource == axIndex
        xaxis.mirror = false;
    end
    
    %---------------------------------------------------------------------%
    
    % fix y mirror
    if ysource == axIndex && overlapping
        yaxis.mirror = false;
    end
    
    %---------------------------------------------------------------------%
    
    %-layout plot bg color-%
    obj.layout.plot_bgcolor = 'rgba(0,0,0,0)';
    
    %---------------------------------------------------------------------%
    
end

%-------------------------------------------------------------------------%

% update the layout field (overites source)
obj.layout = setfield(obj.layout,['xaxis' num2str(xsource)],xaxis);

%-------------------------------------------------------------------------%

% update the layout field (overwrites source)
obj.layout = setfield(obj.layout,['yaxis' num2str(ysource)],yaxis);

%-------------------------------------------------------------------------%

%-REVERT UNITS-%
set(obj.State.Axis(axIndex).Handle,'Units',axisunits);
set(obj.State.Axis(axIndex).Handle,'FontUnits',fontunits);

end

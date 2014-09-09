%----UPDATE AXIS DATA/LAYOUT----%

function obj = updateAxis(obj,axIndex)

% title: ...[DONE]
% titlefont:...[DONE]
% range:...[DONE]
% domain:...[DONE]
% type:...[DONE]
% rangemode:...[NOT HANDLED IN MATLAB]
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
% position:...[DONE]

%-FIGURE DATA-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA-%
axis_data = obj.State.Axis(axIndex).Handle;

%-STANDARDIZE UNITS-%
axisunits = axis_data.Units;
fontunits = axis_data.FontUnits;
set(axis_data,'Units','normalized');
set(axis_data,'FontUnits','points');

%-CONVERT TO PLOTLY AXIS NOTATION-%
if isfield(obj.layout,['xaxis' axIndex])
    xaxis = getfield(obj.layout,['xaxis' axIndex]);
end

if isfield(obj.layout,['yaxis' axIndex])
    yaxis = getfield(obj.layout,['yaxis' axIndex]);
end

%-------------------------------------------------------------------------%

%-xaxis anchor-%
xaxis.anchor = ['y' num2str(axIndex)];

%-xaxis zeroline-%
xaxis.zeroline = false;

%-yaxis anchor-%
yaxis.anchor = ['x' num2str(axIndex)];

%-yaxis zeroline-%
yaxis.zeroline = false;

%-------------------------------------------------------------------------%

%-exponent format-%
xaxis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
yaxis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

%-------------------------------------------------------------------------%

switch axis_data.Box
    case 'on'
        %-xaxis mirror-%
        xaxis.mirror = true;
        %-yaxis mirror-%
        yaxis.mirror = true;
        
    case 'off'
        xaxis.mirror = false;
        yaxis.mirror = false;
end

%-------------------------------------------------------------------------%

%-layout plot bg color-%
if ~ischar(axis_data.Color)
    col = 255*axis_data.Color;
else
    col = 255*figure_data.Color;
end

obj.layout.plot_bgcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

%-------------------------------------------------------------------------%

%-xaxis tick font size-%
xaxis.tickfont.size = axis_data.FontSize;

%-------------------------------------------------------------------------%

%-yaxis tick font size-%
yaxis.tickfont.size = axis_data.FontSize;

%-------------------------------------------------------------------------%

%-xaxis tick font family-%
xaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

%-------------------------------------------------------------------------%

%-yaxis tick font family-%
yaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

%-------------------------------------------------------------------------%

%assumes units are normalized (we force this)
xaxis.domain = min([axis_data.Position(1) axis_data.Position(1)+axis_data.Position(3)],1);
yaxis.domain = min([axis_data.Position(2) axis_data.Position(2)+axis_data.Position(4)],1);

%-------------------------------------------------------------------------%

%-xaxis-side-%
xaxis.side = axis_data.XAxisLocation;

%-------------------------------------------------------------------------%

%-yaxis-side-%
yaxis.side = axis_data.YAxisLocation;

%-------------------------------------------------------------------------%

ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
    max(axis_data.TickLength(1)*axis_data.Position(3)*obj.layout.width,...
    axis_data.TickLength(1)*axis_data.Position(4)*obj.layout.height));
%-xaxis ticklen-%
xaxis.ticklen = ticklength;
%-yaxis ticklen-%
yaxis.ticklen = ticklength;

%-------------------------------------------------------------------------%

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

%-------------------------------------------------------------------------%

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

%-------------------------------------------------------------------------%

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

%-------------------------------------------------------------------------%

if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
    %-xaxis show grid-%
    xaxis.showgrid = true;
else
    xaxis.showgrid = false;
end

%-------------------------------------------------------------------------%

if strcmp(axis_data.YGrid,'on') || strcmp(axis_data.YMinorGrid,'on')
    %yaxis show grid-%
    yaxis.showgrid = true;
else
    yaxis.showgrid = false;
end

%-------------------------------------------------------------------------%

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

%-------------------------------------------------------------------------%

%-xaxis type-%
xaxis.type = axis_data.XScale;

%-------------------------------------------------------------------------%

%-xaxis show tick labels-%
xaxis.showticklabels = true;

%-------------------------------------------------------------------------%

%-xaxis showtick labels / ticks-%
if isempty(axis_data.XTick)
    
    %-xaxis ticks-%
    xaxis.ticks = '';
    xaxis.showticklabels = false;
    
else
    
    %-xaxis tick direction-%
    switch axis_data.TickDir
        case 'in'
            xaxis.ticks = 'inside';
        case 'out'
            xaxis.ticks = 'outside';
    end
    
    %-------------------------------------------------------------------------%
    
    if strcmp(xaxis.type,'log')
        
        %-xaxis range-%
        xaxis.range = log10(axis_data.XLim);
        %-xaxis autotick-%
        xaxis.autotick = true;
        %-xaxis nticks-%
        xaxis.nticks = length(axis_data.XTick);
        
    elseif strcmp(xaxis.type,'linear')
        
        %-xaxis range-%
        xaxis.range = axis_data.XLim;
        
        if strcmp(axis_data.XTickLabelMode,'auto')
            %-xaxis autotick-%
            xaxis.autotick = true;
            %-xaxis numticks-%
            xaxis.nticks = length(axis_data.XTick);
        else
            %-xaxis show tick labels-%
            if isempty(axis_data.XTickLabel)
                xaxis.showticklabels = false;
            else
                try datenum(axis_data.XTickLabel(1,:));
                    %-xaxis type date-%
                    xaxis.type = 'date';
                    %-range (overwrite)-%
                    xaxis.range = [convertDate(datenum(axis_data.XTickLabel(1,:))) convertDate(datenum(axis_data.XTickLabel(end,:)))];
                    %-xaxis autotick-%
                    xaxis.autotick = true;
                    %-xaxis numticks-%
                    xaxis.nticks = length(axis_data.XTick);
                catch
                    %-xaxis type category-%
                    xaxis.type = 'category';
                    %-xaxis tick0-%
                    xaxis.tick0 = str2double(axis_data.XTickLabel(1,:));
                    %-xaxis dtick-%
                    xaxis.dtick = str2double(axis_data.XTickLabel(2,:))- str2double(axis_data.XtickLabel(1,:));
                    %-xaxis autotick-%
                    xaxis.autotick = false;
                end
            end
        end
    end
end

%-------------------------------------------------------------------------%

if strcmp(axis_data.XDir,'reverse')
    xaxis.range = [xaxis.range(2) xaxis.range(1)];
end

%-------------------------------------------------------------------------%

xlabel = get(axis_data,'XLabel');
ylabel = get(axis_data,'YLabel');

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

%-------------------------------------------------------------------------%

%-yaxis type-%
yaxis.type = axis_data.YScale;

%-------------------------------------------------------------------------%

%-yaxis range-%
yaxis.range = axis_data.YLim;

%-------------------------------------------------------------------------%

%-yaxis show tick labels-%
yaxis.showticklabels = true;

%-------------------------------------------------------------------------%

%-yaxis showtick labels / ticks-%
if isempty(axis_data.YTick)
    
    %-yaxis ticks-%
    yaxis.ticks = '';
    yaxis.showticklabels = false;
    
else
    
    %-yaxis tick direction-%
    switch axis_data.TickDir
        case 'in'
            yaxis.ticks = 'inside';
        case 'out'
            yaxis.ticks = 'outside';
    end
    
    %-------------------------------------------------------------------------%
    
    
    if strcmp(yaxis.type,'log')
        
        %-yaxis autotick-%
        yaxis.autotick = true;
        %-yaxis nticks-%
        yaxis.nticks = length(axis_data.YTick);
        
    elseif strcmp(yaxis.type,'linear')
        
        %-xaxis range-%
        yaxis.range = axis_data.YLim;
        
        if strcmp(axis_data.YTickLabelMode,'auto')
            %-xaxis autotick-%
            yaxis.autotick = true;
            %-xaxis numticks-%
            yaxis.nticks = length(axis_data.YTick);
        else
            %-yaxis show tick labels-%
            if isempty(axis_data.YTickLabel)
                yaxis.showticklabels = false;
            else
                try datenum(axis_data.YTickLabel(1,:));
                    %-yaxis type date-%
                    yaxis.type = 'date';
                    %-range (overwrite)-%
                    yaxis.range = [convertDate(datenum(axis_data.YTickLabel(1,:))) convertDate(datenum(axis_data.YTickLabel(end,:)))];
                    %-yaxis autotick-%
                    yaxis.autotick = true;
                    %-yaxis numticks-%
                    yaxis.nticks = length(axis_data.YTick);
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

%-------------------------------------------------------------------------%

if strcmp(axis_data.YDir,'reverse')
    yaxis.range = [yaxis.range(2) yaxis.range(1)];
end

%-------------------------------------------------------------------------%

%SET AXES USING PLOTLY SYNTAX
obj.layout = setfield(obj.layout,['xaxis' num2str(axIndex)],xaxis);
obj.layout = setfield(obj.layout,['yaxis' num2str(axIndex)],yaxis);

%-REVERT UNITS-%
set(axis_data,'Units',axisunits);
set(axis_data,'FontUnits',fontunits);

end

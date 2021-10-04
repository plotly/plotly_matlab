function obj = updateTernaryColorbar(obj,colorbarIndex)

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
    disp('could not extract ColorBar data');
end

%-STANDARDIZE UNITS-%
colorbarunits = colorbarData.Units;
set(obj.State.Colorbar(colorbarIndex).Handle,'Units','normalized');

%-------------------------------------------------------------------------%

%-colorbar position-%
colorbar.xanchor = 'left';
colorbar.yanchor = 'bottom';
colorbar.x = colorbarData.Position(1)*1.025;
colorbar.y = colorbarData.Position(2);

%-------------------------------------------------------------------------%

%-exponent format-%
colorbar.exponentformat = obj.PlotlyDefaults.ExponentFormat;

%-------------------------------------------------------------------------%

% get colorbar title and labels
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

%-colorbar title-%
if ~isempty(colorbarTitleData.String)
    colorbar.title = parseString(colorbarTitleData.String,colorbarTitleData.Interpreter);

elseif ~isempty(colorbarXLabelData.String)
    colorbar.title = parseString(colorbarXLabelData.String,colorbarXLabelData.Interpreter);

elseif ~isempty(colorbarYLabelData.String)
    colorbar.title = parseString(colorbarYLabelData.String,colorbarYLabelData.Interpreter);
end


%-------------------------------------------------------------------------%

%-STANDARDIZE UNITS-%
titleUnits = colorbarTitleData.Units;
titleFontUnits = colorbarTitleData.FontUnits;
yLabelUnits = colorbarYLabelData.Units;
yLabelFontUnits = colorbarYLabelData.FontUnits;
set(colorbarTitle,'Units','data');
set(colorbarYLabel,'Units','data');
set(colorbarYLabel,'FontUnits','points');

if ~isHG2
    xLabelUnits = colorbarXLabelData.Units;
    xLabelFontUnits = colorbarXLabelData.FontUnits;
    set(colorbarTitle,'FontUnits','points');
    set(colorbarXLabel,'Units','data');
    set(colorbarXLabel,'FontUnits','points');
end

if ~isempty(colorbarTitleData.String)
    if colorbarTitleData.Rotation == 90
        colorbar.titleside = 'right';
    else
        colorbar.titleside = 'top';
    end

    colorbar.titlefont.family = matlab2plotlyfont(colorbarTitleData.FontName);
    col = 255*colorbarTitleData.Color;
    colorbar.titlefont.color = sprintf('rgb(%f,%f,%f)', col);
    colorbar.titlefont.size = 1.20 * colorbarTitleData.FontSize;

elseif ~isempty(colorbarXLabelData.String)
    colorbar.titleside = 'right';
    colorbar.titlefont.family = matlab2plotlyfont(colorbarXLabelData.FontName);
    col = 255*colorbarXLabelData.Color;
    colorbar.titlefont.color = sprintf('rgb(%f,%f,%f)', col);
    colorbar.titlefont.size = 1.20 * colorbarXLabelData.FontSize;

elseif ~isempty(colorbarYLabelData.String)
    colorbar.titleside = 'bottom';
    colorbar.titlefont.family = matlab2plotlyfont(colorbarYLabelData.FontName);
    col = 255*colorbarYLabelData.Color;
    colorbar.titlefont.color = sprintf('rgb(%f,%f,%f)', col);
    colorbar.titlefont.size = 1.20 * colorbarYLabelData.FontSize;
end

%-REVERT UNITS-%
set(colorbarTitle,'Units',titleUnits);
set(colorbarTitle,'FontUnits',titleFontUnits);
set(colorbarYLabel,'Units',yLabelUnits);
set(colorbarYLabel,'FontUnits',yLabelFontUnits);

if ~isHG2
    set(colorbarXLabel,'Units',xLabelUnits);
    set(colorbarXLabel,'FontUnits',xLabelFontUnits);
end


%-------------------------------------------------------------------------%

%-some colorbar settings-%

lineWidth = colorbarData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor;
tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
    max(colorbarData.TickLength(1)*colorbarData.Position(3)*obj.layout.width,...
    colorbarData.TickLength(1)*colorbarData.Position(4)*obj.layout.height));

colorbar.thicknessmode = 'fraction';
colorbar.thickness = colorbarData.Position(3);
colorbar.tickwidth = lineWidth;
colorbar.ticklen = tickLength;

colorbar.lenmode = 'fraction';
colorbar.len = colorbarData.Position(4)*1.025;
colorbar.outlinewidth = lineWidth;

%-------------------------------------------------------------------------%

% orientation vertical check
orientVert = colorbar.len > colorbar.thickness;

%-------------------------------------------------------------------------%

%-coloration-%

if isHG2
    col = 255*colorbarData.Color;
else
    if orientVert
        col = 255*colorbarData.YColor;
    else
        col = 255*colorbarData.XColor;
    end
end

colorbarColor = sprintf('rgb(%f,%f,%f)', col);

colorbar.outlinecolor = colorbarColor;
colorbar.tickcolor = colorbarColor;
colorbar.tickfont.color = colorbarColor;

%-------------------------------------------------------------------------%

%-axis tickfont-%
colorbar.tickfont.size = colorbarData.FontSize;
colorbar.tickfont.family = matlab2plotlyfont(colorbarData.FontName);

%-------------------------------------------------------------------------%

%-colorbar pad-%
colorbar.xpad = obj.PlotlyDefaults.MarginPad;
colorbar.ypad = obj.PlotlyDefaults.MarginPad;

%-------------------------------------------------------------------------%

%-set ticklabels-%
nticks = length(colorbarData.Ticks);

if isHG2
    if isempty(colorbarData.Ticks)
        %-hide tick labels-%
        colorbar.ticks = '';
        colorbar.showticklabels = false;

    else

        %-tick direction-%
        switch colorbarData.TickDirection
            case 'in'
                colorbar.ticks = 'inside';
            case 'out'
                colorbar.ticks = 'outside';
        end

        if strcmp(colorbarData.TickLabelsMode,'auto')
            colorbar.autotick = true;
            colorbar.nticks = length(colorbarData.Ticks) + 1; %nticks = max ticks (so + 1)

        else

            %-show tick labels-%
            if isempty(colorbarData.TickLabels)
                colorbar.showticklabels = false;

            else
                colorbar.autotick = false;
                colorbar.tickvals = colorbarData.Ticks;
                colorbar.ticktext = colorbarData.TickLabels;
            end
        end
    end

else
    if orientVert
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

%-------------------------------------------------------------------------%

%-colorbar bg-color-%
if ~isHG2
    
    if ~ischar(colorbarData.Color)
        col = 255*colorbarData.Color;
    else
        col = 255*figureData.Color;
    end
    
    obj.layout.plot_bgcolor = sprintf('rgb(%f,%f,%f)', col);
end

%-------------------------------------------------------------------------%

%-ASSOCIATED DATA-%
if isfield(colorbarData.UserData,'dataref')
    colorbarDataIndex = colorbarData.UserData.dataref;
else
    colorbarDataIndex = findColorbarData(obj,colorbarIndex);
end

if (nticks ~= 0)
    colorIndex = linspace(0, 1, nticks);
    colorData = linspace(0, 1, nticks-1);
    m = 1;

    for n = 1:nticks-1
        col = 1-colorData(n);
        colorscale{m} = {colorIndex(n), sprintf('rgb(%f,%f,%f)', 255*[col, col, col])};
        colorscale{m+1} = {colorIndex(n+1), sprintf('rgb(%f,%f,%f)', 255*[col, col, col])};
        m = 2*n+1;
    end
    obj.data{colorbarDataIndex}.marker.color = colorbarData.Ticks;
else
    colorscale = {{0, 'rgb(255,255,255)'}, {1, 'rgb(0,0,0)'}}
end

obj.data{colorbarDataIndex}.marker.colorscale = colorscale;
obj.data{colorbarDataIndex}.marker.colorbar = colorbar;
obj.data{colorbarDataIndex}.showscale = true;

%-------------------------------------------------------------------------%

%-REVERT UNITS-%
set(obj.State.Colorbar(colorbarIndex).Handle,'Units',colorbarunits);

end


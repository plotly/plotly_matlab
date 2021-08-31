function [axis] = extractHeatmapAxisData(obj,axis_data,axisName)
%extract information related to each axis
%   axis_data is the data extrated from the figure, axisName take the
%   values 'x' 'y' or 'z'


%-------------------------------------------------------------------------%

%-axis-side-%
% axis.side = eval(['axis_data.' axisName 'AxisLocation;']);

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

tl = eval(['axis_data.' axisName 'Data;']);
tl = length(tl);

w = axis_data.Position(4);
h = axis_data.Position(3);

ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
    max(tl*w*obj.layout.width,tl*h*obj.layout.height));

%-axis ticklen-%
axis.ticklen = 0.1; %ticklength; 

%-------------------------------------------------------------------------%

% col = eval(['255*axis_data.' axisName 'Color;']);
axiscol = 'rgb(150, 150, 150)';

%-axis linecolor-%
axis.linecolor = axiscol;
%-axis tickcolor-%
axis.tickcolor = axiscol;
%-axis tickfont-%
axis.tickfont.color = 'black';
%-axis grid color-%
axis.gridcolor = 'rgb(0, 0, 0)';

%-------------------------------------------------------------------------%

axis.showgrid = true;

%-------------------------------------------------------------------------%

lw = 0.5;
linewidth = max(1,lw*obj.PlotlyDefaults.AxisLineIncreaseFactor);

%-axis line width-%
axis.linewidth = linewidth;
%-axis tick width-%
axis.tickwidth = linewidth;
%-axis grid width-%
axis.gridwidth = linewidth*1.2;

%-------------------------------------------------------------------------%

%-setting ticks-%
axis.ticks = 'inside';
axis.mirror = true;

labels = eval(['axis_data.' axisName 'DisplayLabels;']);
vals = eval(['axis_data.' axisName 'DisplayData;']);

axis.showticklabels = true;
axis.type = 'category';
axis.autorange = true;
axis.ticktext = labels;
axis.tickvals = vals;
axis.autotick = false;
axis.tickson = 'boundaries';

%-------------------------------LABELS------------------------------------%

label = eval(['axis_data.' axisName 'Label;']);

%-------------------------------------------------------------------------%

%-title-%
axis.title = label;

%-------------------------------------------------------------------------%

%-axis title font color-%
axis.titlefont.color = 'black';

%-------------------------------------------------------------------------%

%-axis title font size-%
axis.titlefont.size = axis_data.FontSize*1.3;
axis.tickfont.size = axis_data.FontSize*1.15;

%-------------------------------------------------------------------------%

%-axis title font family-%
axis.titlefont.family = matlab2plotlyfont(axis_data.FontName);
axis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

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



function [axis] = extractHeatmapAxisData(obj,axis_data,axisName)
    %extract information related to each axis
    %   axis_data is the data extrated from the figure, axisName take the
    %   values 'x' 'y' or 'z'

    %---------------------------------------------------------------------%

    axis.zeroline = false;
    axis.autorange = false;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;
    axis.tickfont.size = axis_data.FontSize;
    axis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

    %---------------------------------------------------------------------%

    tl = axis_data.(axisName + "Data");
    tl = length(tl);

    w = axis_data.Position(4);
    h = axis_data.Position(3);

    ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(tl*w*obj.layout.width,tl*h*obj.layout.height));

    axis.ticklen = 0.1; %ticklength; 

    %---------------------------------------------------------------------%

    axiscol = 'rgb(150, 150, 150)';

    axis.linecolor = axiscol;
    axis.tickcolor = axiscol;
    axis.tickfont.color = 'black';
    axis.gridcolor = 'rgb(0, 0, 0)';

    %---------------------------------------------------------------------%

    axis.showgrid = true;

    %---------------------------------------------------------------------%

    lw = 0.5;
    linewidth = max(1,lw*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    axis.linewidth = linewidth;
    axis.tickwidth = linewidth;
    axis.gridwidth = linewidth*1.2;

    %---------------------------------------------------------------------%

    %-setting ticks-%
    axis.ticks = 'inside';
    axis.mirror = true;

    labels = axis_data.(axisName + "DisplayLabels");
    vals = axis_data.(axisName + "DisplayData");

    axis.showticklabels = true;
    axis.type = 'category';
    axis.autorange = true;
    axis.ticktext = labels;
    axis.tickvals = vals;
    axis.autotick = false;
    axis.tickson = 'boundaries';

    %-------------------------------LABELS--------------------------------%

    label = axis_data.(axisName + "Label");
    axis.title = label;
    axis.titlefont.color = 'black';
    axis.titlefont.size = axis_data.FontSize*1.3;
    axis.tickfont.size = axis_data.FontSize*1.15;
    axis.titlefont.family = matlab2plotlyfont(axis_data.FontName);
    axis.tickfont.family = matlab2plotlyfont(axis_data.FontName);

    %---------------------------------------------------------------------%

    if strcmp(axis_data.Visible,'on')
        axis.showline = true;
    else
        axis.showline = false;
        axis.showticklabels = false;
        axis.ticks = '';
    end
end

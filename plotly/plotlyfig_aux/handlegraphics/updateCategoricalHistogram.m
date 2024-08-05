function obj = updateCategoricalHistogram(obj,histIndex)
    % x:...[DONE]
    % y:...[DONE]
    % histnorm:...[DONE]
    % name:...[DONE]
    % autobinx:...[DONE]
    % nbinsx:...[DONE]
    % xbins:...[DONE]
    % autobiny:...[DONE]
    % nbinsy:...[DONE]
    % ybins:...[DONE]
    % text:...[NOT SUPPORTED IN MATLAB]
    % error_y:...[HANDLED BY ERRORBARSERIES]
    % error_x:...[HANDLED BY ERRORBARSERIES]
    % opacity: --- [TODO]
    % xaxis:...[DONE]
    % yaxis:...[DONE]
    % showlegend:...[DONE]
    % stream:...[HANDLED BY PLOTLYSTREAM]
    % visible:...[DONE]
    % type:...[DONE]
    % orientation:...[DONE]

    % MARKER:
    % color: ...[DONE]
    % size: ...[NA]
    % symbol: ...[NA]
    % opacity: ...[TODO]
    % sizeref: ...[NA]
    % sizemode: ...[NA]
    % colorscale: ...[NA]
    % cauto: ...[NA]
    % cmin: ...[NA]
    % cmax: ...[NA]
    % outliercolor: ...[NA]
    % maxdisplayed: ...[NA]

    % MARKER LINE:
    % color: ...[DONE]
    % width: ...[DONE]
    % dash: ...[NA]
    % opacity: ...[TODO]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NA]
    % outlierwidth: ...[NA]

    %---------------------------------------------------------------------%

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);

    %-HIST DATA STRUCTURE- %
    hist_data = obj.State.Plot(histIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-AXIS DATA-%
    xaxis = obj.layout.("xaxis" + xsource);
    yaxis = obj.layout.("yaxis" + ysource);

    %---------------------------------------------------------------------%

    %-hist xaxis and yaxis-%
    obj.data{histIndex}.xaxis = ['x' num2str(xsource)];
    obj.data{histIndex}.yaxis = ['y' num2str(ysource)];

    %---------------------------------------------------------------------%

    %-bar type-%
    obj.data{histIndex}.type = 'bar';

    %---------------------------------------------------------------------%

    %-hist data-%
    obj.data{histIndex}.width = hist_data.BarWidth;
    obj.data{histIndex}.y = hist_data.Values;

    %---------------------------------------------------------------------%

    %-hist categorical layout on x-axis-%
    gap = 1 - hist_data.BarWidth;
    xmin = -gap;
    xmax = (hist_data.NumDisplayBins - 1) + gap;

    t = 'category';
    obj.layout.("xaxis" + xsource).type = t;
    obj.layout.("xaxis" + xsource).autotick = false;
    obj.layout.("xaxis" + xsource).range = {xmin, xmax};

    %---------------------------------------------------------------------%

    %-hist name-%
    obj.data{histIndex}.name = hist_data.DisplayName;

    %---------------------------------------------------------------------%

    %-layout barmode-%
    obj.layout.barmode = 'group';

    %---------------------------------------------------------------------%

    %-hist line width-%
    obj.data{histIndex}.marker.line.width = hist_data.LineWidth;

    %---------------------------------------------------------------------%

    %-hist opacity-%
    if ~ischar(hist_data.FaceAlpha)
        obj.data{histIndex}.opacity = 1.25*hist_data.FaceAlpha;
    end

    %---------------------------------------------------------------------%

    obj.data{histIndex}.marker = extractPatchFace(hist_data);

    %---------------------------------------------------------------------%

    %-hist visible-%
    obj.data{histIndex}.visible = strcmp(hist_data.Visible,'on');

    %---------------------------------------------------------------------%

    %-hist showlegend-%
    leg = hist_data.Annotation;
    legInfo = leg.LegendInformation;

    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end

    obj.data{histIndex}.showlegend = showleg;
end

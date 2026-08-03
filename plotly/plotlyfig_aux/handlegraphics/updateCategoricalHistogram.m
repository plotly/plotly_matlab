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

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);

    %-HIST DATA STRUCTURE- %
    hist_data = obj.State.Plot(histIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    obj.data{histIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{histIndex}.yaxis = sprintf("y%d", ysource);
    obj.data{histIndex}.type = 'bar';
    obj.data{histIndex}.width = get(hist_data, 'BarWidth');
    obj.data{histIndex}.y = get(hist_data, 'Values');

    %-hist categorical layout on x-axis-%
    gap = 1 - get(hist_data, 'BarWidth');
    xmin = -gap;
    xmax = (get(hist_data, 'NumDisplayBins') - 1) + gap;

    obj.layout.(sprintf("xaxis%d", xsource)).type = 'category';
    obj.layout.(sprintf("xaxis%d", xsource)).autotick = false;
    obj.layout.(sprintf("xaxis%d", xsource)).range = {xmin, xmax};

    obj.data{histIndex}.name = get(hist_data, 'DisplayName');
    obj.layout.barmode = 'group';
    obj.data{histIndex}.marker.line.width = get(hist_data, 'LineWidth');

    if ~ischar(get(hist_data, 'FaceAlpha'))
        obj.data{histIndex}.opacity = 1.25*get(hist_data, 'FaceAlpha');
    end

    obj.data{histIndex}.marker = extractPatchFace(hist_data);
    obj.data{histIndex}.visible = strcmp(get(hist_data, 'Visible'),'on');

    obj.data{histIndex}.showlegend = getShowLegend(hist_data);
end

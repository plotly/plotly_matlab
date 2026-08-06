function data = updateHistogramPolar(obj,histIndex)
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

    hist_data = obj.State.Plot(histIndex).Handle;

    axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);
    xsource = findSourceAxis(obj, axIndex);
    data.subplot = sprintf('polar%d', xsource+1);

    data.type = 'barpolar';

    binedges = rad2deg(get(hist_data, 'BinEdges'));
    data.theta = binedges(1:end-1) + 0.5*diff(binedges);
    data.width = diff(binedges);
    data.r = double(get(hist_data, 'BinCounts'));

    data.name = get(hist_data, 'DisplayName');
    obj.layout.barmode = "group";
    data.marker.line.width = get(hist_data, 'LineWidth');

    if ~ischar(get(hist_data, 'FaceAlpha'))
        data.opacity = get(hist_data, 'FaceAlpha');
    end

    data.marker = extractPatchFace(hist_data);
    data.visible = strcmp(get(hist_data, 'Visible'), "on");

    data.showlegend = getShowLegend(hist_data);

    updatePolarAxesLayout(obj, histIndex);
end

function data = updateHistogram(obj,histIndex)
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

    axisData = obj.State.Plot(histIndex).AssociatedAxis;
    axIndex = obj.getAxisIndex(axisData);
    hist_data = obj.State.Plot(histIndex).Handle;
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;
    data.type = "bar";

    if isprop(hist_data, "Orientation")
        %-Matlab 2014+ histogram() function-%
        orientation = hist_data.Orientation;
    else
        %-Matlab <2014 hist() function-%
        orientation = histogramOrientation(hist_data);
    end

    switch orientation
        case {"vertical", "horizontal"}
            %-hist y data-%
            data.x = hist_data.BinEdges(1:end-1) ...
                    + 0.5*diff(hist_data.BinEdges);
            data.width = diff(hist_data.BinEdges);
            data.y = double(hist_data.Values);
        case "v"
            %-hist x data-%
            xdata = mean(hist_data.XData(2:3,:));

            %-hist y data-%
            xlength = 0;
            for d = 1:length(xdata)
                xnew = repmat(xdata(d),1,hist_data.YData(2,d));
                data.x(xlength+1:xlength+length(xnew)) = xnew;
                xlength = length(data.x);
            end

            %-hist autobinx-%
            data.autobinx = false;

            %-hist xbins-%
            xbins.start = hist_data.XData(2,1);
            xbins.end = hist_data.XData(3,end);
            xbins.size = diff(hist_data.XData(2:3,1));
            data.xbins = xbins;

            %-layout bargap-%
            obj.layout.bargap = ...
                    (hist_data.XData(3,1) - hist_data.XData(2,2)) ...
                    / (hist_data.XData(3,1) - hist_data.XData(2,1));
        case "h"
            %-hist y data-%
            ydata = mean(hist_data.YData(2:3,:));

            ylength = 0;
            for d = 1:length(ydata)
                ynew = repmat(ydata(d),1,hist_data.XData(2,d));
                data.y(ylength+1:ylength+length(ynew)) = ynew;
                ylength = length(data.y);
            end

            %-hist autobiny-%
            data.autobiny = false;

            %-hist ybins-%
            ybins.start = hist_data.YData(2,1);
            ybins.end = hist_data.YData(3,end);
            ybins.size = diff(hist_data.YData(2:3,1));
            data.ybins = ybins;

            %-layout bargap-%
            obj.layout.bargap = ...
                    (hist_data.XData(3,1) - hist_data.XData(2,2)) ...
                    / (hist_data.XData(3,1) - hist_data.XData(2,1));
    end

    if axisData.Tag == "yhist"
        % scatterhist() function
        data.orientation = "h";
        temp = data.x;
        data.x = flip(data.y);
        data.y = temp;
    end

    data.name = hist_data.DisplayName;
    obj.layout.barmode = "overlay";
    data.marker.line.width = hist_data.LineWidth;

    %-hist opacity-%
    if ~ischar(hist_data.FaceAlpha)
        data.opacity = hist_data.FaceAlpha * 1.25;
    end

    data.marker = extractPatchFace(hist_data);
    data.visible = hist_data.Visible == "on";

    switch hist_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            data.showlegend = true;
        case "off"
            data.showlegend = false;
    end
end

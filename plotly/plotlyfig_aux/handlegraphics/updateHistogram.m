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

    isStairs = isprop(hist_data, "DisplayStyle") ...
            && hist_data.DisplayStyle == "stairs";

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;

    if isStairs
        data = updateHistogramStairs(data,hist_data);
    else
        data = updateHistogramBar(obj,data, hist_data,axisData);
    end

    data.name = hist_data.DisplayName;
    data.visible = hist_data.Visible == "on";
    data.showlegend = getShowLegend(hist_data);
end

function data = updateHistogramStairs(data, hist_data)
    % Render DisplayStyle="stairs" as a scatter trace with step
    % interpolation, matching MATLAB's unfilled staircase outline.
    data.type = "scatter";
    data.mode = "lines";

    edges = hist_data.BinEdges;
    vals = double(hist_data.Values);

    % Build explicit staircase coordinates: each edge appears twice so the
    % path traces vertical rises and horizontal runs without needing
    % line.shape interpolation.
    %   (edge1,0) -> (edge1,val1) -> (edge2,val1) -> (edge2,val2) -> ...
    %   ... -> (edgeN+1,valN) -> (edgeN+1,0)
    x = repelem(edges, 2);
    y = [0 repelem(vals, 2) 0];

    if hist_data.Orientation == "horizontal"
        [x, y] = deal(y, x);
    end

    data.x = x;
    data.y = y;

    % Edge color becomes the line color.
    if isnumeric(hist_data.EdgeColor)
        data.line.color = getStringColor(round(255*hist_data.EdgeColor));
    end
    data.line.width = hist_data.LineWidth;
    data.line.dash = getLineDash(hist_data.LineStyle);
end

function data = updateHistogramBar(obj,data,hist_data,axisData)
    data.type = "bar";

    if isprop(hist_data, "Orientation")
        orientation = hist_data.Orientation;
    else
        orientation = histogramOrientation(hist_data);
    end

    switch orientation
        case {"vertical", "horizontal"}
            data.x = hist_data.BinEdges(1:end-1) ...
                    + 0.5*diff(hist_data.BinEdges);
            data.width = diff(hist_data.BinEdges);
            data.y = double(hist_data.Values);
        case "v"
            xdata = mean(hist_data.XData(2:3,:));
            counts = hist_data.YData(2,:);
            data.x = repelem(xdata, counts);
            data.autobinx = false;
            xbins.start = hist_data.XData(2,1);
            xbins.end = hist_data.XData(3,end);
            xbins.size = diff(hist_data.XData(2:3,1));
            data.xbins = xbins;
            obj.layout.bargap = ...
                    (hist_data.XData(3,1) - hist_data.XData(2,2)) ...
                    / (hist_data.XData(3,1) - hist_data.XData(2,1));
        case "h"
            ydata = mean(hist_data.YData(2:3,:));
            counts = hist_data.XData(2,:);
            data.y = repelem(ydata, counts);
            data.autobiny = false;
            ybins.start = hist_data.YData(2,1);
            ybins.end = hist_data.YData(3,end);
            ybins.size = diff(hist_data.YData(2:3,1));
            data.ybins = ybins;
            obj.layout.bargap = ...
                    (hist_data.XData(3,1) - hist_data.XData(2,2)) ...
                    / (hist_data.XData(3,1) - hist_data.XData(2,1));
        otherwise
            error("updateHistogram:unknownOrientation", ...
                "Unknown histogram orientation: %s", orientation);
    end

    if axisData.Tag == "yhist"
        data.orientation = "h";
        [data.x, data.y] = deal(data.y, data.x);
    end

    obj.layout.barmode = "overlay";

    if ~ischar(hist_data.FaceAlpha)
        data.opacity = hist_data.FaceAlpha * 1.25;
    end

    data.marker = extractPatchFace(hist_data);
end

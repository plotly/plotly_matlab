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
            && strcmp(get(hist_data, 'DisplayStyle'), "stairs");

    data.xaxis = sprintf("x%d", xsource);
    data.yaxis = sprintf("y%d", ysource);

    if isStairs
        data = updateHistogramStairs(data,hist_data);
    else
        data = updateHistogramBar(obj,data, hist_data,axisData);
    end

    data.name = get(hist_data, 'DisplayName');
    data.visible = strcmp(get(hist_data, 'Visible'), "on");
    data.showlegend = getShowLegend(hist_data);
end

function data = updateHistogramStairs(data, hist_data)
    % Render DisplayStyle="stairs" as a scatter trace with step
    % interpolation, matching MATLAB's unfilled staircase outline.
    data.type = "scatter";
    data.mode = "lines";

    edges = get(hist_data, 'BinEdges');
    vals = double(get(hist_data, 'Values'));

    % Build explicit staircase coordinates: each edge appears twice so the
    % path traces vertical rises and horizontal runs without needing
    % line.shape interpolation.
    %   (edge1,0) -> (edge1,val1) -> (edge2,val1) -> (edge2,val2) -> ...
    %   ... -> (edgeN+1,valN) -> (edgeN+1,0)
    x = repelem(edges, 2);
    y = [0 repelem(vals, 2) 0];

    if strcmp(get(hist_data, 'Orientation'), "horizontal")
        [x, y] = deal(y, x);
    end

    data.x = x;
    data.y = y;

    % Edge color becomes the line color.
    if isnumeric(get(hist_data, 'EdgeColor'))
        data.line.color = getStringColor(round(255*get(hist_data, 'EdgeColor')));
    end
    data.line.width = get(hist_data, 'LineWidth');
    data.line.dash = getLineDash(get(hist_data, 'LineStyle'));
end

function data = updateHistogramBar(obj,data,hist_data,axisData)
    data.type = "bar";

    if isprop(hist_data, "Orientation")
        orientation = get(hist_data, 'Orientation');
    else
        orientation = histogramOrientation(hist_data);
    end

    switch orientation
        case {"vertical", "horizontal"}
            tmpBinEdges = get(hist_data, 'BinEdges');
            data.x = tmpBinEdges(1:end-1) ...
                    + 0.5*diff(get(hist_data, 'BinEdges'));
            data.width = diff(get(hist_data, 'BinEdges'));
            data.y = double(get(hist_data, 'Values'));
        case "v"
            tmpXData = get(hist_data, 'XData');
            xdata = mean(tmpXData(2:3,:));
            tmpYData = get(hist_data, 'YData');
            counts = tmpYData(2,:);
            data.x = xdata;
            data.y = counts;
            data.width = diff(tmpXData(2:3,:));
            obj.layout.bargap = ...
                    (tmpXData(3,1) - tmpXData(2,2)) ...
                    / (tmpXData(3,1) - tmpXData(2,1));
        case "h"
            ydata = mean(tmpYData(2:3,:));
            counts = tmpXData(2,:);
            data.y = ydata;
            data.x = counts;
            data.width = diff(tmpYData(2:3,:));
            data.orientation = 'h';
            obj.layout.bargap = ...
                    (tmpXData(3,1) - tmpXData(2,2)) ...
                    / (tmpXData(3,1) - tmpXData(2,1));
        otherwise
            error("updateHistogram:unknownOrientation", ...
                "Unknown histogram orientation: %s", orientation);
    end

    if strcmp(get(axisData, 'Tag'), "yhist")
        data.orientation = "h";
        [data.x, data.y] = deal(data.y, data.x);
    end

    obj.layout.barmode = "overlay";

    if ~ischar(get(hist_data, 'FaceAlpha'))
        % the 1.25 factor compensates for MATLAB's translucent hist
        % patches; Octave patches are fully opaque and the factor
        % would push the opacity past the valid range
        data.opacity = min(1, get(hist_data, 'FaceAlpha') * 1.25);
    end

    data.marker = extractPatchFace(hist_data);
    if isfield(data.marker, 'line') && isfield(data.marker.line, 'width')
        % plotly.js fails to draw bars when the marker line width is
        % set on large histogram datasets; drop the width (the color
        % alone draws the edge)
        data.marker.line = rmfield(data.marker.line, 'width');
    end
end

function updateGraphPlot(obj, dataIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj, axIndex);
    plotData = obj.State.Plot(dataIndex).Handle;

    xaxis = "x" + xSource;
    yaxis = "y" + ySource;

    %-EDGE TRACE (uses dataIndex slot)-%
    obj.data{dataIndex}.type = "scatter";
    obj.data{dataIndex}.xaxis = xaxis;
    obj.data{dataIndex}.yaxis = yaxis;
    obj.data{dataIndex}.mode = "lines";
    obj.data{dataIndex}.hoverinfo = "skip";
    obj.data{dataIndex}.showlegend = false;

    [edgeX, edgeY] = extractEdgeData(plotData);
    obj.data{dataIndex}.x = edgeX;
    obj.data{dataIndex}.y = edgeY;

    edgeColor = plotData.EdgeColor;
    if isnumeric(edgeColor)
        obj.data{dataIndex}.line.color = getStringColor( ...
                round(255*edgeColor), plotData.EdgeAlpha);
    end
    obj.data{dataIndex}.line.width = plotData.LineWidth;

    %-NODE TRACE (new slot)-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    nodeIndex = obj.PlotOptions.nPlots;

    obj.data{nodeIndex}.type = "scatter";
    obj.data{nodeIndex}.xaxis = xaxis;
    obj.data{nodeIndex}.yaxis = yaxis;
    obj.data{nodeIndex}.mode = "markers";
    obj.data{nodeIndex}.hoverinfo = "text";
    obj.data{nodeIndex}.showlegend = false;
    obj.data{nodeIndex}.x = plotData.XData;
    obj.data{nodeIndex}.y = plotData.YData;

    nodeColor = plotData.NodeColor;
    if isnumeric(nodeColor) && size(nodeColor, 1) == 1
        obj.data{nodeIndex}.marker.color = ...
                getStringColor(round(255*nodeColor));
    elseif isnumeric(nodeColor)
        colors = cell(1, size(nodeColor, 1));
        for k = 1:size(nodeColor, 1)
            colors{k} = getStringColor(round(255*nodeColor(k,:)));
        end
        obj.data{nodeIndex}.marker.color = colors;
    end

    obj.data{nodeIndex}.marker.size = plotData.MarkerSize;
    if isscalar(plotData.Marker)
        symbol = extractGraphMarker(plotData.Marker);
    else
        symbol = cellfun(@extractGraphMarker, plotData.Marker);
    end
    obj.data{nodeIndex}.marker.symbol = symbol;
    obj.data{nodeIndex}.marker.line.width = plotData.LineWidth;
end

function [edgeX, edgeY] = extractEdgeData(plotData)
    % Extract edge coordinates from the GraphPlot's internal LineStrip
    % primitive. Returns x,y arrays with NaN separators between edges.
    edgeX = [];
    edgeY = [];
    try
        drawnow;
        children = plotData.NodeChildren;
        for i = 1:numel(children)
            if isa(children(i), ...
                    'matlab.graphics.primitive.world.LineStrip')
                vd = double(children(i).VertexData);
                % LineStrip stores edges as consecutive vertex pairs.
                % Insert NaN separators between each pair for plotly.
                nVerts = size(vd, 2);
                nEdges = nVerts / 2;
                edgeX = NaN(1, 3*nEdges);
                edgeY = NaN(1, 3*nEdges);
                for e = 1:nEdges
                    idx = 3*(e-1);
                    srcIdx = 2*(e-1) + 1;
                    edgeX(idx+1) = vd(1, srcIdx);
                    edgeX(idx+2) = vd(1, srcIdx+1);
                    edgeY(idx+1) = vd(2, srcIdx);
                    edgeY(idx+2) = vd(2, srcIdx+1);
                    % edgeX(idx+3) and edgeY(idx+3) stay NaN
                end
                break;
            end
        end
    catch
        % Edge extraction not available
    end
end

function symbol = extractGraphMarker(matlabMarker)
    switch matlabMarker
        case "o"
            symbol = "circle";
        case {"s", "square"}
            symbol = "square";
        case {"d", "diamond"}
            symbol = "diamond";
        case "^"
            symbol = "triangle-up";
        case "v"
            symbol = "triangle-down";
        case ">"
            symbol = "triangle-right";
        case "<"
            symbol = "triangle-left";
        case {"p", "pentagram"}
            symbol = "star";
        case "h"
            symbol = "hexagon";
        case "+"
            symbol = "cross";
        case "x"
            symbol = "x";
        otherwise
            symbol = "circle";
    end
end

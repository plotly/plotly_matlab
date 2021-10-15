function marker = extractScatterMarker(plotData)

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    %                                                                         %
    % %-DESCRIPTION-%                                                         %
    %                                                                         %
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS OF TYPE "PATCH".      %
    % THESE OBJECTS ARE USED IN AREASERIES BARSERIES, CONTOURGROUP,           %
    % SCATTERGROUP.                                                           %
    %                                                                         %
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

    %-INITIALIZATIONS-%
    axisData = get(ancestor(plotData.Parent,'axes'));
    figureData = get(ancestor(plotData.Parent,'figure'));
    marker = struct();

    marker.sizeref = 1;
    marker.sizemode = 'area';
    marker.size = plotData.SizeData;
    marker.line.width = plotData.LineWidth;

    markerFaceColor = plotData.MarkerFaceColor;
    markerFaceAlpha = plotData.MarkerFaceAlpha;
    markerEdgeColor = plotData.MarkerEdgeColor;
    markerEdgeAlpha = plotData.MarkerEdgeAlpha;
    cData = plotData.CData;

    colorMap = axisData.Colormap;
    cLim = axisData.CLim;

    filledMarkerSet = {'o', 'square', 's', 'diamond', 'd', 'v', '^', ...
        '<', '>', 'hexagram', 'pentagram'};
    filledMarker = ismember(plotData.Marker, filledMarkerSet);
    nColors = size(colorMap, 1);

    %-------------------------------------------------------------------------%

    %-get marker symbol-%
    if ~strcmp(plotData.Marker,'none')

        switch plotData.Marker
            case '.'
                markerSymbol = 'circle';
            case 'o'
                markerSymbol = 'circle';
            case 'x'
                markerSymbol = 'x-thin-open';
            case '+'
                markerSymbol = 'cross-thin-open';
            case '*'
                markerSymbol = 'asterisk-open';
            case {'s','square'}
                markerSymbol = 'square';
            case {'d','diamond'}
                markerSymbol = 'diamond';
            case 'v'
                markerSymbol = 'triangle-down';
            case '^'
                markerSymbol = 'triangle-up';
            case '<'
                markerSymbol = 'triangle-left';
            case '>'
                markerSymbol = 'triangle-right';
            case {'p','pentagram'}
                markerSymbol = 'star';
            case {'h','hexagram'}
                markerSymbol = 'hexagram';
        end
        
        marker.symbol = markerSymbol;
    end

    %-------------------------------------------------------------------------%

    %-get marker fillColor-%
    if filledMarker
        
        if isnumeric(markerFaceColor)
            fillColor = sprintf('rgb(%f,%f,%f)', 255*markerFaceColor);

        else
            switch markerFaceColor
                
                case 'none'        
                    fillColor = 'rgba(0,0,0,0)';
                    
                case 'auto'
                    if ~strcmp(axisData.Color,'none')
                        fillColor = 255*axisData.Color;
                    else
                        fillColor = 255*figureData.Color;
                    end

                    fillColor = sprintf('rgb(%f,%f,%f)', fillColor);
                    
                case 'flat'

                    for n = 1:size(cData, 1)
                        if size(cData, 2) == 1
                            cIndex = max( min( cData(n), cLim(2) ), cLim(1) );
                            scaleColor = (cIndex - cLim(1)) / diff(cLim);
                            cIndex = 1 + floor(scaleColor*(nColors-1));
                            numColor =  255 * colorMap(cIndex, :);

                        elseif size(cData, 2) == 3
                            numColor = 255*cData(n, :);
                        end

                        fillColor{n} = sprintf('rgb(%f,%f,%f)', numColor);
                    end

            end
        end
        
        marker.color = fillColor;
        marker.opacity = markerFaceAlpha;
        
    end

    %-------------------------------------------------------------------------%

    %-get marker lineColor-%
    if isnumeric(markerEdgeColor)
        lineColor = sprintf('rgb(%f,%f,%f)', 255*markerEdgeColor);

    else
        switch markerEdgeColor

            case 'none'
                lineColor = 'rgba(0,0,0,0)';
                
            case 'auto'
                
                EdgeColor = plotData.EdgeColor;

                if ~strcmp(axisData.Color,'none')
                    lineColor = 255*axisData.Color;
                else
                    lineColor = 255*figureData.Color;
                end

                lineColor = sprintf('rgba(%f,%f,%f,%f)', lineColor, ...
                    markerEdgeAlpha);
                
            case 'flat'
                
                for n = 1:size(cData, 1)
                    if size(cData, 2) == 1
                        cIndex = max( min( cData(n), cLim(2) ), cLim(1) );
                        scaleColor = (cIndex - cLim(1)) / diff(cLim);
                        cIndex = 1 + floor(scaleColor*(nColors-1));
                        numColor =  255 * colorMap(cIndex, :);

                    elseif size(cData, 2) == 3
                        numColor = 255*cData(n, :);
                    end

                    lineColor{n} = sprintf('rgba(%f,%f,%f,%f)', numColor, ...
                        markerEdgeAlpha);
                end

        end
    end

    if filledMarker
        marker.line.color = lineColor;
    else
        marker.color = lineColor;
    end

    %-------------------------------------------------------------------------%
end

%----UPDATE PLOT DATA/STYLE----%
function obj = updateData(obj, dataIndex)

% update plot based on plot call class
switch obj.State.Plot(dataIndex).Class
    
    % Plotly supported MATLAB core objects
    
    case 'image'
        %updatePlotImage(obj);
    case 'line'
        updateLineseries(obj, dataIndex);
    case 'patch'
        %updateHistogram(obj);
        %updatePlotPatch(obj);
    case 'rectangle'
        %updatePlotRectangle(obj);
    case 'surface'
        %updatePlotSurface(obj);
    case 'text'
        %HANDLED BY UPDATETEXT
        
        % Plotly supported MATLAB plot objects
        
    case 'areaseries'
        %updatePlotAreaseries(obj);
    case 'barseries'
        updateBarseries(obj, dataIndex);
    case 'baseline'
        updateLineseries(obj, dataIndex);
    case 'contourgroup'
        %updatePlotContourgroup(obj);
    case 'errorbarseries'
        %updatePlotErrorbarseries(obj);
    case 'lineseries'
         updateLineseries(obj, dataIndex)
    case 'quivergroup'
        %updatePlotQuivergroup(obj);
    case 'scattergroup'
        %updatePlotScattergroup(obj);
    case 'stairseries'
        %updatePlotStairseries(obj);
    case 'stemseries'
        %updatePlotStemseries(obj);
    case 'surfaceplot'
        %updatePlotSurfaceplot(obj);
        
        % Plotly supported MATLAB plot objects
        
    case 'hggroup'
        %updatePlotHggroup(obj);
    case 'hgtransorm'
        %updatePlotHgtransform(obj);
    otherwise  
end
end
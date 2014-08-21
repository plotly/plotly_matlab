%----UPDATE PLOT DATA/STYLE----%
function obj = updatePlot(obj,~,~,prop)

% update plot based on plot call class
switch obj.State.Plot.Call
    
    
    % Plotly supported MATLAB core objects

    case 'image'
        %updatePlotImage(obj);
    case 'line'
        %updatePlotLine(obj);
    case 'patch'
        %updatePlotPatch(obj);
    case 'rectangle'
        %updatePlotRectangle(obj);
    case 'surface'
        %updatePlotSurface(obj);
    case 'text'
        %updatePlotText(obj);
        
        
        
        % Plotly supported MATLAB plot objects
        
    case 'areaseries'
        %updatePlotAreaseries(obj);
    case 'barseries'
        %updatePlotBarseries(obj);
    case 'contourgroup'
        %updatePlotContourgroup(obj);
    case 'errorbarseries'
        %updatePlotErrorbarseries(obj);
    case 'lineseries'
        extractPlotLineseries(obj,prop);
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
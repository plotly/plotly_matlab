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
        %updatePatch(obj, dataIndex); 
    case 'rectangle'
        %updateRectangle(obj,dataIndex);
    case 'surface'
        %updateSurface(obj,dataIndex);
    case 'text'
        %HANDLED BY UPDATETEXT
        
        % Plotly supported MATLAB plot objects
       
    case 'areaseries';
        updateAreaseries(obj, dataIndex);
    case 'barseries'
        updateBarseries(obj, dataIndex);
    case 'baseline'
        updateLineseries(obj, dataIndex);
    case 'contourgroup'
        updateContourgroup(obj,dataIndex);
    case 'errorbarseries'
        %updateErrorbarseries(obj,dataIndex);
    case 'lineseries'
        updateLineseries(obj, dataIndex);
    case 'quivergroup'
        %updateQuivergroup(obj, dataIndex);
    case 'scattergroup'
        %updateScattergroup(obj, dataIndex);
    case 'stairseries'
        %updateStairseries(obj, dataIndex);
    case 'stemseries'
        updateStemseries(obj, dataIndex);
    case 'surfaceplot'
        %updateSurfaceplot(obj,dataIndex);
        
        % Plotly supported MATLAB plot objects
        
    case 'hggroup'
        %updateHggroup(obj,dataIndex);
    case 'hgtransorm'
        %updatePlothgtransform(obj,dataIndex);
    otherwise
end
end
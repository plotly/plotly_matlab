%----UPDATE PLOT DATA/STYLE----%

function obj = updateData(obj, dataIndex)

%-update plot based on plot call class-%
switch obj.State.Plot(dataIndex).Class
    
    %--CORE PLOT OBJECTS--%
    case 'image'
        updateImage(obj, dataIndex);
    case 'line'
        updateLineseries(obj, dataIndex);
    case 'patch'
        % check for histogram
        if isHistogram(obj,dataIndex)
            updateHistogram(obj,dataIndex);
        else
            updatePatch(obj, dataIndex);
        end
    case 'rectangle'
        updateRectangle(obj,dataIndex);
    case 'surface'
        %updateSurface(obj,dataIndex); 

        %-GROUP PLOT OBJECTS-%
    case 'areaseries';
        updateAreaseries(obj, dataIndex);
    case 'barseries'
        updateBarseries(obj, dataIndex);
    case 'baseline'
        updateLineseries(obj, dataIndex);
    case 'contourgroup'
        updateContourgroup(obj,dataIndex);
    case 'errorbarseries'
        updateErrorbarseries(obj,dataIndex);
    case 'lineseries'
        updateLineseries(obj, dataIndex);
    case 'quivergroup'
        %updateQuivergroup(obj, dataIndex);
    case 'scattergroup'
        updateScattergroup(obj, dataIndex);
    case 'stairseries'
        updateStairseries(obj, dataIndex);
    case 'stemseries'
        updateStemseries(obj, dataIndex);
    case 'surfaceplot'
        %updateSurfaceplot(obj,dataIndex);
        
        %--Plotly supported MATLAB group plot objects--%
    case 'hggroup'
        % check for boxplot
        if isBoxplot(obj, dataIndex)
            updateBoxplot(obj, dataIndex);
        end
end

%----------------------------DATA CLEAN UP--------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-FIX X/Y DATA-%

% check for xaxis dates
if strcmpi(xaxis.type, 'date')
    obj.data{dataIndex}.x =  convertDate(obj.data{dataIndex}.x);
end

% check for yaxis dates
if strcmpi(yaxis.type, 'date')
    obj.data{dataIndex}.y =  convertDate(obj.data{dataIndex}.y);
end

end
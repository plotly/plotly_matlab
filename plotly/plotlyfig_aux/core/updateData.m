%----UPDATE PLOT DATA/STYLE----%

function obj = updateData(obj, dataIndex)

%-update plot based on plot call class-%
try
    switch lower(obj.State.Plot(dataIndex).Class)
        
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
            updateSurfaceplot(obj,dataIndex);
            
            %-GROUP PLOT OBJECTS-%
        case 'area'
            updateArea(obj, dataIndex); 
        case 'areaseries'
            updateAreaseries(obj, dataIndex);
        case 'bar'
            updateBar(obj, dataIndex); 
        case 'barseries'
            updateBarseries(obj, dataIndex);
        case 'baseline'
            updateBaseline(obj, dataIndex);
        case {'contourgroup','contour'}
            updateContourgroup(obj,dataIndex);
        case {'errorbarseries','errorbar'}
            updateErrorbarseries(obj,dataIndex);
        case 'lineseries'
            updateLineseries(obj, dataIndex);
        case {'quivergroup','quiver'}
            updateQuivergroup(obj, dataIndex);
        case {'scattergroup','scatter'}
            updateScattergroup(obj, dataIndex);
        case {'stairseries','stair'}
            updateStairseries(obj, dataIndex);
        case {'stemseries','stem'}
            updateStemseries(obj, dataIndex);
        case 'surfaceplot'
            updateSurfaceplot(obj,dataIndex);
            
            %--Plotly supported MATLAB group plot objects--%
        case {'hggroup','group'}
            % check for boxplot
            if isBoxplot(obj, dataIndex)
                updateBoxplot(obj, dataIndex);
            end
    end
    
catch
    if obj.UserData.Verbose
        fprintf(['\nWe had trouble parsing the ' obj.State.Plot(dataIndex).Class ' object.\n',...
                 'This trace will not be rendered.\n\n']);
    end
end

%------------------------AXIS/DATA CLEAN UP-------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

% check for xaxis dates
if strcmpi(xaxis.type, 'date')
    obj.data{dataIndex}.x =  convertDate(obj.data{dataIndex}.x);
end

% check for yaxis dates
if strcmpi(yaxis.type, 'date')
    obj.data{dataIndex}.y =  convertDate(obj.data{dataIndex}.y);
end

%-------------------------------------------------------------------------%

end
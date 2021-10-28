%----UPDATE PLOT DATA/STYLE----%

function obj = updateData(obj, dataIndex)

try
    
    %-update plot based on TreatAs PlotOpts-%
   
    if ismember('pie3', lower(obj.PlotOptions.TreatAs))
        updatePie3(obj, dataIndex);
    elseif ismember('pcolor', lower(obj.PlotOptions.TreatAs))
        updatePColor(obj, dataIndex);
    elseif ismember('contour3', lower(obj.PlotOptions.TreatAs))
        updateContour3(obj, dataIndex);
    elseif ismember('ezpolar', lower(obj.PlotOptions.TreatAs))
        updateLineseries(obj, dataIndex);
    elseif ismember('polarhistogram', lower(obj.PlotOptions.TreatAs))
        updateHistogramPolar(obj, dataIndex); 
    elseif ismember('coneplot', lower(obj.PlotOptions.TreatAs))
        updateConeplot(obj, dataIndex);
    elseif ismember('bar3', lower(obj.PlotOptions.TreatAs))
        updateBar3(obj, dataIndex);
    elseif ismember('bar3h', lower(obj.PlotOptions.TreatAs))
        updateBar3h(obj, dataIndex); 
    elseif ismember('fmesh', lower(obj.PlotOptions.TreatAs))
        updateFmesh(obj, dataIndex);
    elseif ismember('surfc', lower(obj.PlotOptions.TreatAs))
        updateSurfc(obj, dataIndex); 
    elseif ismember('meshc', lower(obj.PlotOptions.TreatAs))
        updateSurfc(obj, dataIndex); 
    elseif ismember('surfl', lower(obj.PlotOptions.TreatAs))
        updateSurfl(obj, dataIndex);
        
    %-update plot based on plot call class-%
    
    else

        switch lower(obj.State.Plot(dataIndex).Class)

            %--SPIDER PLOT -> SPECIAL CASE--%            
            case 'spider_plot_class'
                updateSpiderPlot(obj, dataIndex);

            %--GEOAXES -> SPECIAL CASE--%
            case 'geoaxes'
                UpdateGeoAxes(obj, dataIndex);

            %-EMULATE AXES -> SPECIAL CASE--%
            case 'nothing'
                updateOnlyAxes(obj, dataIndex);

            %--CORE PLOT OBJECTS--%
            case 'geobubble'
                updateGeobubble(obj, dataIndex);
            case 'scatterhistogram'
                updateScatterhistogram(obj, dataIndex); 
            case 'wordcloud'
                updateWordcloud(obj, dataIndex);
            case 'heatmap'
                updateHeatmap(obj, dataIndex);
            case 'image'
                if ~obj.PlotOptions.Image3D
                    updateImage(obj, dataIndex);
                else
                    updateImage3D(obj, dataIndex);
                end
            case 'line'
                if obj.PlotlyDefaults.isGeoaxis
                    updateGeoPlot(obj, dataIndex);
                elseif ismember('polarplot', lower(obj.PlotOptions.TreatAs))
                    updatePolarplot(obj, dataIndex);
                elseif ismember('ternplot', lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlot(obj, dataIndex);
                else
                    updateLineseries(obj, dataIndex);
                end
            case 'categoricalhistogram'
                updateCategoricalHistogram(obj, dataIndex); 
            case 'histogram'
                updateHistogram(obj, dataIndex);
            case 'histogram2'
                updateHistogram2(obj, dataIndex);
            case 'patch'
                % check for histogram
                if isHistogram(obj,dataIndex)
                    updateHistogram(obj,dataIndex);
                elseif ismember('ternplotpro', lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlotPro(obj, dataIndex);
                elseif ismember('ternpcolor', lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlotPro(obj, dataIndex);
                elseif ismember('isosurface', lower(obj.PlotOptions.TreatAs))
                    updateIsosurface(obj, dataIndex);
                else
                    updatePatch(obj, dataIndex);
                end
            case 'rectangle'
                updateRectangle(obj,dataIndex);
            case 'surface'
                if ismember('surf', lower(obj.PlotOptions.TreatAs))
                    updateSurf(obj, dataIndex); 
                elseif ismember('mesh', lower(obj.PlotOptions.TreatAs))
                    updateMesh(obj, dataIndex);
                elseif ismember('slice', lower(obj.PlotOptions.TreatAs))
                    updateSlice(obj, dataIndex);
                else
                    updateSurfaceplot(obj,dataIndex);
                end
            case {'functionsurface', 'parameterizedfunctionsurface'}
                updateFunctionSurface(obj,dataIndex);
            case 'implicitfunctionsurface'
                updateImplicitFunctionSurface(obj,dataIndex);

                %-GROUP PLOT OBJECTS-%
            case 'area'
                updateArea(obj, dataIndex); 
            case 'areaseries'
                updateAreaseries(obj, dataIndex);
            case 'animatedline'
                updateAnimatedLine(obj, dataIndex);
            case 'bar'
                updateBar(obj, dataIndex); 
            case 'barseries'
                updateBarseries(obj, dataIndex);
            case 'baseline'
                updateBaseline(obj, dataIndex);
            case {'contourgroup','contour'}
                if obj.PlotOptions.ContourProjection
                    updateContourProjection(obj,dataIndex);
                elseif ismember('terncontour', lower(obj.PlotOptions.TreatAs))
                    updateTernaryContour(obj, dataIndex);
                else
                    updateContourgroup(obj,dataIndex);
                end
            case 'functioncontour'
                updateFunctionContour(obj,dataIndex);
            case 'errorbar'
                updateErrorbar(obj,dataIndex); 
            case 'errorbarseries'
                updateErrorbarseries(obj,dataIndex);
            case 'lineseries'
                updateLineseries(obj, dataIndex);
            case 'quiver'
                updateQuiver(obj, dataIndex); 
            case 'quivergroup'
                updateQuivergroup(obj, dataIndex);
            case 'scatter'
                if ismember('scatterpolar', lower(obj.PlotOptions.TreatAs))
                    updateScatterPolar(obj, dataIndex);
                elseif obj.PlotlyDefaults.isGeoaxis
                    updateGeoScatter(obj, dataIndex);
                else
                    updateScatter(obj, dataIndex); 
                end
            case 'scattergroup'
                updateScattergroup(obj, dataIndex);
            case 'stair'
                updateStair(obj, dataIndex); 
            case 'stairseries'
                updateStairseries(obj, dataIndex);
            case 'stackedplot'
                updateStackedplot(obj, dataIndex);
            case 'stem'
                updateStem(obj, dataIndex); 
            case 'stemseries'
                updateStemseries(obj, dataIndex);
            case 'surfaceplot'
                updateSurfaceplot(obj,dataIndex);
            case 'implicitfunctionline'
                updateLineseries(obj, dataIndex);

                %--Plotly supported MATLAB group plot objects--%
            case {'hggroup','group'}
                % check for boxplot
                if isBoxplot(obj, dataIndex)
                    updateBoxplot(obj, dataIndex);
                end
        end
    end
    
catch exception
    if obj.UserData.Verbose
        fprintf([exception.message '\nWe had trouble parsing the ' obj.State.Plot(dataIndex).Class ' object.\n',...
                 'This trace might not render properly.\n\n']);
    end
end

%------------------------AXIS/DATA CLEAN UP-------------------------------%

try
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-AXIS DATA-%
    eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
    eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

    %---------------------------------------------------------------------%

    % check for xaxis dates
    if strcmpi(xaxis.type, 'date')
        obj.data{dataIndex}.x =  convertDate(obj.data{dataIndex}.x);
    end

    % check for xaxis categories
    if strcmpi(xaxis.type, 'category') && ...
            ~strcmp(obj.data{dataIndex}.type,'box')
        obj.data{dataIndex}.x =  get(obj.State.Plot(dataIndex).AssociatedAxis,'XTickLabel');
        eval(['obj.layout.xaxis' num2str(xsource) '.autotick=true;']);
    end

    % check for yaxis dates
    if strcmpi(yaxis.type, 'date')
        obj.data{dataIndex}.y =  convertDate(obj.data{dataIndex}.y);
    end

    % check for yaxis categories
    if strcmpi(yaxis.type, 'category') && ...
            ~strcmp(obj.data{dataIndex}.type,'box')
        obj.data{dataIndex}.y =  get(obj.State.Plot(dataIndex).AssociatedAxis,'YTickLabel');
        eval(['obj.layout.yaxis' num2str(xsource) '.autotick=true;']);
    end
catch
    % TODO to the future
    % disp('catch at line 157 in updateData.m file')
end

%-------------------------------------------------------------------------%

try
    if obj.layout.isAnimation
        %- Play Button Options-%
        opts{1} = nan;
        opts{2}.frame.duration = obj.PlotOptions.FrameDuration;
        opts{2}.frame.redraw = true;
        opts{2}.fromcurrent = true;
        opts{2}.mode = 'immediate';
        opts{2}.transition.duration = obj.PlotOptions.FrameTransitionDuration;

        button{1}.label = '&#9654;';
        button{1}.method = 'animate';
        button{1}.args = opts;
        
        opts{1} = {nan};
        opts{2}.transition.duration = 0;
        opts{2}.frame.duration = 0;
        
        button{2}.label = '&#9724;';
        button{2}.method = 'animate';
        button{2}.args = opts;

        obj.layout.updatemenus{1}.type = 'buttons';
        obj.layout.updatemenus{1}.buttons = button;
        obj.layout.updatemenus{1}.pad.r = 70;
        obj.layout.updatemenus{1}.pad.t = 10;
        obj.layout.updatemenus{1}.direction = 'left';
        obj.layout.updatemenus{1}.showactive = true;
        obj.layout.updatemenus{1}.x = 0.01;
        obj.layout.updatemenus{1}.y = 0.01;
        obj.layout.updatemenus{1}.xanchor = 'left';
        obj.layout.updatemenus{1}.yanchor = 'top';
        
        obj.layout = rmfield(obj.layout,'isAnimation');
    end
catch
end

end

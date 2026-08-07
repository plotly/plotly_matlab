function obj = updateData(obj, dataIndex)
    %----UPDATE PLOT DATA/STYLE----%

    %-update plot based on TreatAs PlotOpts-%
    treatAs = lower(obj.PlotOptions.TreatAs);
    if ismember("pie3", treatAs)
        updatePie3(obj, dataIndex);
    elseif ismember("pcolor", treatAs)
        updatePColor(obj, dataIndex);
    elseif ismember("ezpolar", treatAs)
        obj.data{dataIndex} = updateLineseries(obj, dataIndex);
    elseif ismember("coneplot", treatAs)
        updateConeplot(obj, dataIndex);
    elseif ismember("bar3", treatAs)
        updateBar3(obj, dataIndex);
    elseif ismember("bar3h", treatAs)
        updateBar3h(obj, dataIndex);
    elseif ismember("fmesh", treatAs)
        updateFmesh(obj, dataIndex);
    elseif ismember("surfc", treatAs)
        updateSurfc(obj, dataIndex);
    elseif ismember("meshc", treatAs)
        updateSurfc(obj, dataIndex);
    elseif ismember("surfl", treatAs)
        updateSurfl(obj, dataIndex);
    else %-update plot based on plot call class-%
        switch lower(obj.State.Plot(dataIndex).Class)
            %--SPIDER PLOT -> SPECIAL CASE--%
            case "spider_plot_class"
                updateSpiderPlot(obj, dataIndex);
            %--GEOAXES -> SPECIAL CASE--%
            case "geoaxes"
                UpdateGeoAxes(obj, dataIndex);
            %-EMULATE AXES -> SPECIAL CASE--%
            case "nothing"
                obj.data{dataIndex} = updateOnlyAxes(obj, dataIndex);
            %--CORE PLOT OBJECTS--%
            case "geobubble"
                updateGeobubble(obj, dataIndex);
            case "scatterhistogram"
                updateScatterhistogram(obj, dataIndex);
            case "wordcloud"
                updateWordcloud(obj, dataIndex);
            case "heatmap"
                obj.data{dataIndex} = updateHeatmap(obj, dataIndex);
            case "image"
                if ~obj.PlotOptions.Image3D
                    obj.data{dataIndex} = updateImage(obj, dataIndex);
                else
                    updateImage3D(obj, dataIndex);
                end
            case "line"
                if obj.PlotlyDefaults.isGeoaxis
                    updateGeoPlot(obj, dataIndex);
                elseif strcmp(get(obj.State.Plot(dataIndex).AssociatedAxis, 'Type'), "polaraxes")
                    obj.data{dataIndex} = updatePolarplot(obj, dataIndex);
                elseif ismember("ternplot", lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlot(obj, dataIndex);
                else
                    obj.data{dataIndex} = updateLineseries(obj, dataIndex);
                end
            case "constantline"
                obj.data{dataIndex} = updateConstantLine(obj, dataIndex);
            case "categoricalhistogram"
                updateCategoricalHistogram(obj, dataIndex);
            case "histogram"
                if strcmp(get(obj.State.Plot(dataIndex).AssociatedAxis, 'Type'), "polaraxes")
                    obj.data{dataIndex} = updateHistogramPolar(obj, dataIndex);
                else
                    obj.data{dataIndex} = updateHistogram(obj, dataIndex);
                end
            case "histogram2"
                updateHistogram2(obj, dataIndex);
            case "patch"
                % check for histogram
                if isHistogram(obj,dataIndex)
                    obj.data{dataIndex} = updateHistogram(obj,dataIndex);
                elseif ismember("ternplotpro", lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlotPro(obj, dataIndex);
                elseif ismember("ternpcolor", lower(obj.PlotOptions.TreatAs))
                    updateTernaryPlotPro(obj, dataIndex);
                elseif ismember("isosurface", lower(obj.PlotOptions.TreatAs))
                    obj.data{dataIndex} = updateIsosurface(obj, dataIndex);
                else
                    updatePatch(obj, dataIndex);
                end
            case "rectangle"
                updateRectangle(obj,dataIndex);
            case "surface"
                if ismember("surf", lower(obj.PlotOptions.TreatAs))
                    updateSurf(obj, dataIndex);
                elseif ismember("mesh", lower(obj.PlotOptions.TreatAs))
                    updateMesh(obj, dataIndex);
                elseif ismember("slice", lower(obj.PlotOptions.TreatAs))
                    updateSlice(obj, dataIndex);
                else
                    %-distinguish mesh/surf/slice/pcolor surfaces by
                    %-their properties: mesh and waterfall draw no
                    %-faces, pcolor has no z data, and slice planes
                    %-have one constant coordinate-%
                    surfHandle = obj.State.Plot(dataIndex).Handle;
                    faceColor = get(surfHandle, 'FaceColor');
                    if ischar(faceColor)
                        isMeshLike = strcmpi(faceColor, 'none') ...
                            || strcmpi(faceColor, 'w');
                    else
                        isMeshLike = numel(faceColor) == 3 ...
                            && all(faceColor == 1);
                    end
                    if isMeshLike
                        updateMesh(obj, dataIndex);
                    elseif isSliceSurface(surfHandle)
                        updateSlice(obj, dataIndex);
                    elseif all(nonzeros(get(surfHandle, 'ZData')) == 0) ...
                            || isempty(nonzeros(get(surfHandle, 'ZData')))
                        updatePColor(obj, dataIndex);
                    else
                        updateSurf(obj, dataIndex);
                    end
                end
            case {"functionsurface", "parameterizedfunctionsurface"}
                updateFunctionSurface(obj,dataIndex);
            case "implicitfunctionsurface"
                updateImplicitFunctionSurface(obj,dataIndex);
                %-GROUP PLOT OBJECTS-%
            case "area"
                obj.data{dataIndex} = updateArea(obj, dataIndex);
            case "areaseries"
                updateAreaseries(obj, dataIndex);
            case "animatedline"
                updateAnimatedLine(obj, dataIndex);
            case "bar"
                obj.data{dataIndex} = updateBar(obj, dataIndex);
            case "barseries"
                updateBarseries(obj, dataIndex);
            case "baseline"
                updateBaseline(obj, dataIndex);
            case {"contourgroup","contour"}
                if strcmp(get(obj.State.Plot(dataIndex).AssociatedAxis, 'ZGrid'), "on")
                    obj.data{dataIndex} = updateContour3(obj, dataIndex);
                elseif obj.PlotOptions.ContourProjection
                    updateContourProjection(obj,dataIndex);
                elseif ismember("terncontour", lower(obj.PlotOptions.TreatAs))
                    updateTernaryContour(obj, dataIndex);
                else
                    obj.data{dataIndex} = updateContourgroup(obj,dataIndex);
                end
            case "functioncontour"
                obj.data{dataIndex} = updateFunctionContour(obj,dataIndex);
            case "errorbar"
                obj.data{dataIndex} = updateErrorbar(obj,dataIndex);
            case "errorbarseries"
                obj.data{dataIndex} = updateErrorbarseries(obj,dataIndex);
            case "lineseries"
                obj.data{dataIndex} = updateLineseries(obj, dataIndex);
            case "quiver"
                updateQuiver(obj, dataIndex);
            case "quivergroup"
                updateQuivergroup(obj, dataIndex);
            case "scatter"
                if strcmp(get(obj.State.Plot(dataIndex).AssociatedAxis, 'Type'), "polaraxes")
                    updateScatterPolar(obj, dataIndex);
                elseif obj.PlotlyDefaults.isGeoaxis
                    updateGeoScatter(obj, dataIndex);
                else
                    obj.data{dataIndex} = updateScatter(obj, dataIndex);
                end
            case "scattergroup"
                updateScattergroup(obj, dataIndex);
            case "stair"
                obj.data{dataIndex} = updateStair(obj, dataIndex);
            case "stairseries"
                updateStairseries(obj, dataIndex);
            case "stackedplot"
                updateStackedplot(obj, dataIndex);
            case "stem"
                obj.data{dataIndex} = updateStem(obj, dataIndex);
            case "stemseries"
                updateStemseries(obj, dataIndex);
            case "surfaceplot"
                obj.data{dataIndex} = updateSurfaceplot(obj,dataIndex);
            case {"implicitfunctionline", "functionline", "parameterizedfunctionline"}
                obj.data{dataIndex} = updateLineseries(obj, dataIndex);
            case "graphplot"
                updateGraphPlot(obj, dataIndex);
                %--Plotly supported MATLAB group plot objects--%
            case {"hggroup","group"}
                % check for boxplot
                if isBoxplot(obj, dataIndex)
                    updateBoxplot(obj, dataIndex);
                elseif is_octave()
                    % Octave wraps bar, area, stairs, stem, quiver,
                    % errorbar, contour and rectangle plots in hggroup
                    % objects; identify the plot type from the custom
                    % properties each plotting function adds
                    switch getOctaveGroupClass(obj.State.Plot(dataIndex).Handle)
                        case 'bar'
                            updateBarseries(obj, dataIndex);
                        case 'area'
                            updateAreaseries(obj, dataIndex);
                        case 'rectangle'
                            updateRectangle(obj, dataIndex);
                        case 'stairs'
                            updateStairseries(obj, dataIndex);
                        case 'stem'
                            updateStemseries(obj, dataIndex);
                        case 'quiver'
                            updateQuivergroup(obj, dataIndex);
                        case 'errorbar'
                            obj.data{dataIndex} = updateErrorbarseries(obj, dataIndex);
                        case 'contour'
                            obj.data{dataIndex} = updateContourgroup(obj, dataIndex);
                        case 'scatter'
                            obj.data{dataIndex} = updateScatter(obj, dataIndex);
                    end
                end
            case {"uimenu","uicontextmenu","legend"}
                % Do nothing
                return
            otherwise
                error("Non-supported plot: %s", ...
                        lower(obj.State.Plot(dataIndex).Class));
        end
    end

    if is_octave() && ismember(lower(obj.State.Plot(dataIndex).Class), {"hggroup","group"}) ...
            && (dataIndex > numel(obj.data) || isempty(obj.data{dataIndex}))
        % Octave groups several plot types (scatter, bar, stem, stairs,
        % area, errorbar, quiver, rectangle, contour, plotmatrix...) into
        % hggroup objects. These are not supported, so warn and skip this
        % plot instead of failing the entire conversion.
        warning("Skipping unsupported hggroup plot of type ""%s"" in Octave", ...
                get(obj.State.Plot(dataIndex).AssociatedAxis, 'Type'));
        return
    end

    if ~isfield(obj.data{dataIndex},"showlegend")
        plotHandle = obj.State.Plot(dataIndex).Handle;
        showLeg = getShowLegend(plotHandle);
        if showLeg && isprop(plotHandle, 'DisplayName')
            showLeg = ~isempty(get(plotHandle, 'DisplayName'));
        end
        obj.data{dataIndex}.showlegend = showLeg;
    end
    if ~isfield(obj.data{dataIndex},"name")
        obj.data{dataIndex}.name = "";
    end
    assert(all(isfield(obj.data{dataIndex},{'name' 'showlegend'})), ...
            "Missing fields that are assumed to be present downstream");

    %----------------------AXIS/DATA CLEAN UP-----------------------------%

    ax = obj.State.Plot(dataIndex).AssociatedAxis;
    if ~ismember(get(ax, 'Type'), specialAxisPlots())
        %-AXIS INDEX-%
        axIndex = obj.getAxisIndex(ax);

        %-CHECK FOR MULTIPLE AXES-%
        [xsource, ysource] = findSourceAxis(obj,axIndex);

        %-AXIS DATA-%
        xaxis = obj.layout.(sprintf("xaxis%d", xsource));
        yaxis = obj.layout.(sprintf("yaxis%d", ysource));

        % check for xaxis dates
        if strcmp(xaxis.type, "date")
            obj.data{dataIndex}.x = convertDate(obj.data{dataIndex}.x);
        elseif strcmp(xaxis.type, "duration")
            obj.data{dataIndex}.x = convertDuration(obj.data{dataIndex}.x);
        end

        % check for yaxis dates
        if strcmpi(yaxis.type, "date")
            obj.data{dataIndex}.y = convertDate(obj.data{dataIndex}.y);
        elseif strcmp(yaxis.type, "duration")
            obj.data{dataIndex}.y = convertDuration(obj.data{dataIndex}.y);
        end

        % Plotly requires x and y to be iterable; a single converted date
        % is a 1xN char (not scalar), so wrap single-row chars too
        if isfield(obj.data{dataIndex},"x") && ...
                (isscalar(obj.data{dataIndex}.x) || ...
                (ischar(obj.data{dataIndex}.x) && size(obj.data{dataIndex}.x, 1) == 1))
            obj.data{dataIndex}.x = {obj.data{dataIndex}.x};
        end
        if isfield(obj.data{dataIndex},"y") && ...
                (isscalar(obj.data{dataIndex}.y) || ...
                (ischar(obj.data{dataIndex}.y) && size(obj.data{dataIndex}.y, 1) == 1))
            obj.data{dataIndex}.y = {obj.data{dataIndex}.y};
        end

        % check for xaxis categories
        if strcmpi(xaxis.type, "category") && ...
                ~any(strcmp(obj.data{dataIndex}.type, {'heatmap' 'box'}))
            obj.data{dataIndex}.x = get(ax, 'XTickLabel');
            obj.layout.(sprintf("xaxis%d", xsource)).autotick = true;
        end

        % check for yaxis categories
        if strcmpi(yaxis.type, "category") && ...
                ~any(strcmp(obj.data{dataIndex}.type, {'heatmap' 'box'}))
            obj.data{dataIndex}.y = get(ax, 'YTickLabel');
            obj.layout.(sprintf("yaxis%d", xsource)).autotick = true;
        end
    end

    try
        if obj.layout.isAnimation
            %- Play Button Options-%
            opts{1} = nan;
            opts{2}.frame.duration = obj.PlotOptions.FrameDuration;
            opts{2}.frame.redraw = true;
            opts{2}.fromcurrent = true;
            opts{2}.mode = "immediate";
            opts{2}.transition.duration = ...
                    obj.PlotOptions.FrameTransitionDuration;

            button{1}.label = "&#9654;";
            button{1}.method = "animate";
            button{1}.args = opts;

            opts{1} = {nan};
            opts{2}.transition.duration = 0;
            opts{2}.frame.duration = 0;

            button{2}.label = "&#9724;";
            button{2}.method = "animate";
            button{2}.args = opts;

            obj.layout.updatemenus{1}.type = "buttons";
            obj.layout.updatemenus{1}.buttons = button;
            obj.layout.updatemenus{1}.pad.r = 70;
            obj.layout.updatemenus{1}.pad.t = 10;
            obj.layout.updatemenus{1}.direction = "left";
            obj.layout.updatemenus{1}.showactive = true;
            obj.layout.updatemenus{1}.x = 0.01;
            obj.layout.updatemenus{1}.y = 0.01;
            obj.layout.updatemenus{1}.xanchor = "left";
            obj.layout.updatemenus{1}.yanchor = "top";

            obj.layout = rmfield(obj.layout, "isAnimation");
        end
    catch
    end
end

function isSlice = isSliceSurface(surfHandle)
    %-a slice plane is a rectangular grid with one coordinate
    %-constant; regular surfaces from surf/mesh vary in all three.
    %-pcolor also has an all-zero z grid, but it lives in a 2D-view
    %-axes, so slice planes are only recognized in 3D-view axes-%
    isSlice = false;
    try
        axView = get(get(surfHandle, 'Parent'), 'View');
        if isequal(axView, [0 90])
            return
        end
        xd = get(surfHandle, 'XData');
        yd = get(surfHandle, 'YData');
        zd = get(surfHandle, 'ZData');
        isSlice = (numel(unique(xd(:))) == 1) ...
            || (numel(unique(yd(:))) == 1) ...
            || (numel(unique(zd(:))) == 1);
    catch
    end
end

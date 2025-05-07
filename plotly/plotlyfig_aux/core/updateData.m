function obj = updateData(obj, dataIndex)
    %----UPDATE PLOT DATA/STYLE----%

    %-update plot based on TreatAs PlotOpts-%
    if ismember("pie3", lower(obj.PlotOptions.TreatAs))
        updatePie3(obj, dataIndex);
    elseif ismember("pcolor", lower(obj.PlotOptions.TreatAs))
        updatePColor(obj, dataIndex);
    elseif ismember("ezpolar", lower(obj.PlotOptions.TreatAs))
        obj.data{dataIndex} = updateLineseries(obj, dataIndex);
    elseif ismember("coneplot", lower(obj.PlotOptions.TreatAs))
        updateConeplot(obj, dataIndex);
    elseif ismember("bar3", lower(obj.PlotOptions.TreatAs))
        updateBar3(obj, dataIndex);
    elseif ismember("bar3h", lower(obj.PlotOptions.TreatAs))
        updateBar3h(obj, dataIndex);
    elseif ismember("fmesh", lower(obj.PlotOptions.TreatAs))
        updateFmesh(obj, dataIndex);
    elseif ismember("surfc", lower(obj.PlotOptions.TreatAs))
        updateSurfc(obj, dataIndex);
    elseif ismember("meshc", lower(obj.PlotOptions.TreatAs))
        updateSurfc(obj, dataIndex);
    elseif ismember("surfl", lower(obj.PlotOptions.TreatAs))
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
                elseif obj.State.Plot(dataIndex).AssociatedAxis.Type == "polaraxes"
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
                if obj.State.Plot(dataIndex).AssociatedAxis.Type == "polaraxes"
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
                    obj.data{dataIndex} = updateSurfaceplot(obj,dataIndex);
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
                if obj.State.Plot(dataIndex).AssociatedAxis.ZGrid == "on"
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
                if obj.State.Plot(dataIndex).AssociatedAxis.Type == "polaraxes"
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
            case "implicitfunctionline"
                obj.data{dataIndex} = updateLineseries(obj, dataIndex);
                %--Plotly supported MATLAB group plot objects--%
            case {"hggroup","group"}
                % check for boxplot
                if isBoxplot(obj, dataIndex)
                    updateBoxplot(obj, dataIndex);
                end
            case {"uimenu","uicontextmenu","legend"}
                % Do nothing
                return
            otherwise
                error("Non-supported plot: %s", ...
                        lower(obj.State.Plot(dataIndex).Class));
        end
    end

    if ~isfield(obj.data{dataIndex},"showlegend")
        obj.data{dataIndex}.showlegend = getShowLegend( ...
                obj.State.Plot(dataIndex).Handle);
    end
    if ~isfield(obj.data{dataIndex},"name")
        obj.data{dataIndex}.name = "";
    end
    assert(all(isfield(obj.data{dataIndex},["name" "showlegend"])), ...
            "Missing fields that are assumed to be present downstream");

    %----------------------AXIS/DATA CLEAN UP-----------------------------%

    ax = obj.State.Plot(dataIndex).AssociatedAxis;
    if ~ismember(ax.Type,specialAxisPlots())
        %-AXIS INDEX-%
        axIndex = obj.getAxisIndex(ax);

        %-CHECK FOR MULTIPLE AXES-%
        [xsource, ysource] = findSourceAxis(obj,axIndex);

        %-AXIS DATA-%
        xaxis = obj.layout.("xaxis" + xsource);
        yaxis = obj.layout.("yaxis" + ysource);

        % check for xaxis dates
        if xaxis.type == "date"
            obj.data{dataIndex}.x = convertDate(obj.data{dataIndex}.x);
        elseif xaxis.type == "duration"
            obj.data{dataIndex}.x = convertDuration(obj.data{dataIndex}.x);
        end

        % Plotly requires x and y to be iterable
        if isfield(obj.data{dataIndex},"x") && isscalar(obj.data{dataIndex}.x)
            obj.data{dataIndex}.x = {obj.data{dataIndex}.x};
        end
        if isfield(obj.data{dataIndex},"y") && isscalar(obj.data{dataIndex}.y)
            obj.data{dataIndex}.y = {obj.data{dataIndex}.y};
        end

        % check for xaxis categories
        if strcmpi(xaxis.type, "category") && ...
                ~any(strcmp(obj.data{dataIndex}.type,["heatmap" "box"]))
            obj.data{dataIndex}.x = ax.XTickLabel;
            obj.layout.("xaxis" + xsource).autotick = true;
        end

        % check for yaxis dates
        if strcmpi(yaxis.type, "date")
            obj.data{dataIndex}.y = convertDate(obj.data{dataIndex}.y);
        elseif yaxis.type == "duration"
            obj.data{dataIndex}.y = convertDuration(obj.data{dataIndex}.y);
        end

        % check for yaxis categories
        if strcmpi(yaxis.type, "category") && ...
                ~any(strcmp(obj.data{dataIndex}.type, ["heatmap" "box"]))
            obj.data{dataIndex}.y = ax.YTickLabel;
            obj.layout.("yaxis" + xsource).autotick = true;
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

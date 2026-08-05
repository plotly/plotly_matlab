function data = updateContour3(obj,contourIndex)
    %-FIGURE DATA STRUCTURE-%
    figure_data = obj.State.Figure.Handle;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    contour_data = obj.State.Plot(contourIndex).Handle;
    axisData = obj.State.Plot(contourIndex).AssociatedAxis;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-detect meshc/surfc/ezmeshc/ezsurfc projection shadows-%
    try
        axChildren = get(axisData, 'Children');
        types = get(axChildren, 'Type');
        hasSurface = iscell(types) && any(strcmp(types, 'surface'));
    catch
        hasSurface = false;
    end

    if hasSurface
        data = updateContour3Shadow(contour_data, axisData, ...
            figure_data, xsource);
        return
    end

    data.xaxis = sprintf("x%d", xsource);
    data.yaxis = sprintf("y%d", ysource);
    data.name = get(contour_data, 'DisplayName');
    data.type = "surface";

    %-setting the plot-%
    xdata = get(contour_data, 'XData');
    ydata = get(contour_data, 'YData');
    zdata = get(contour_data, 'ZData');

    if isvector(xdata)
        [xdata, ydata] = meshgrid(xdata, ydata);
    end
    data.x = xdata;
    data.y = ydata;
    data.z = zdata;

    %-setting for contour lines z-direction-%
    if length(get(contour_data, 'LevelList')) > 1
        tmpTextList = get(contour_data, 'TextList');
        zstart = tmpTextList(1);
        zend = tmpTextList(end);
        zsize = mean(diff(get(contour_data, 'TextList')));
    else
        zstart = tmpTextList(1) - 1e-3;
        zend = tmpTextList(end) + 1e-3;
        zsize = 2e-3;
    end

    data.contours.z = struct( ...
        "start", zstart, ...
        "end", zend, ...
        "size", zsize, ...
        "show", true, ...
        "usecolormap", true, ...
        "width", 2*get(contour_data, 'LineWidth') ...
    );
    data.hidesurface = true;

    colormap = get(figure_data, 'Colormap');
    for c = 1:size((colormap),1)
        col = round(255*(colormap(c,:)));
        data.colorscale{c} = ...
                {(c-1)/(size(colormap,1)-1), getStringColor(col)};
    end

    ar = obj.PlotOptions.AspectRatio;

    if ~isempty(ar)
        if ischar(ar)
            obj.layout.scene.aspectmode = ar;
        elseif isvector(ar) && length(ar) == 3
            xar = ar(1);
            yar = ar(2);
            zar = ar(3);
        end
    else
        %-define as default-%
        xar = max(xdata(:));
        yar = max(ydata(:));
        zar = 0.7*max([xar, yar]);
    end

    obj.layout.scene.aspectratio.x = xar;
    obj.layout.scene.aspectratio.y = yar;
    obj.layout.scene.aspectratio.z = zar;

    ey = obj.PlotOptions.CameraEye;

    if ~isempty(ey)
        if isvector(ey) && length(ey) == 3
            obj.layout.scene.camera.eye.x = ey(1);
            obj.layout.scene.camera.eye.y = ey(2);
            obj.layout.scene.camera.eye.z = ey(3);
        end
    else
        %-define as default-%
        xey = - xar;
        if xey>0
            xfac = -0.2;
        else
            xfac = 0.2;
        end
        yey = - yar;
        if yey>0
            yfac = -0.2;
        else
            yfac = 0.2;
        end
        if zar>0
            zfac = 0.2;
        else
            zfac = -0.2;
        end

        obj.layout.scene.camera.eye.x = xey + xfac*xey;
        obj.layout.scene.camera.eye.y = yey + yfac*yey;
        obj.layout.scene.camera.eye.z = zar + zfac*zar;
    end

    %-zerolines hidden-%
    obj.layout.scene.xaxis.zeroline = false;
    obj.layout.scene.yaxis.zeroline = false;
    obj.layout.scene.zaxis.zeroline = false;

    data.visible = strcmp(get(contour_data, 'Visible'), "on");
    data.showscale = false;
    data.reversescale = false;

    data.showlegend = getShowLegend(contour_data);
end

function data = updateContour3Shadow(contourData, axisData, figureData, xSource)
    cMat = get(contourData, 'ContourMatrix');
    zmin = get(axisData, 'ZLim');
    zmin = zmin(1);
    tmpCLim = get(axisData, 'CLim');
    cMap = get(figureData, 'Colormap');

    xData = [];
    yData = [];
    zData = [];
    colorData = [];
    len = size(cMat, 2);
    n = 1;
    while n < len
        m = cMat(2, n);
        level = cMat(1, n);
        xData = [xData, cMat(1, n+1:n+m), NaN];
        yData = [yData, cMat(2, n+1:n+m), NaN];
        zData = [zData, zmin * ones(1, m), NaN];
        colorData = [colorData, level * ones(1, m), NaN];
        n = n + m + 1;
    end

    data.scene = sprintf('scene%d', xSource);
    data.type = 'scatter3d';
    data.mode = 'lines';
    data.x = xData;
    data.y = yData;
    data.z = zData;
    data.name = get(contourData, 'DisplayName');
    data.visible = strcmp(get(contourData, 'Visible'), 'on');
    data.showscale = false;
    data.showlegend = false;
    data.line.color = colorData;
    data.line.colorscale = getColorScale(cMap);
    data.line.cmin = tmpCLim(1);
    data.line.cmax = tmpCLim(2);
    data.line.width = 2*get(contourData, 'LineWidth');
end

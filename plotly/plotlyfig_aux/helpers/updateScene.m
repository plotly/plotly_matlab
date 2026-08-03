function updateScene(obj, dataIndex, opts)
    arguments
        obj
        dataIndex
        opts.normFacScale double = NaN
        opts.aspectMultiplier (1,3) double = [1 1 1]
        opts.setTitleFont logical = true
        opts.handleDatetimeTicks logical = true
        opts.useQuiverCamera logical = false
    end

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = get(plotData, 'Parent');
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.("scene" + xSource);

    aspectRatio = get(axisData, 'PlotBoxAspectRatio');
    cameraPosition = get(axisData, 'CameraPosition');
    dataAspectRatio = get(axisData, 'DataAspectRatio');
    cameraUpVector = get(axisData, 'CameraUpVector');
    cameraEye = cameraPosition ./ dataAspectRatio;

    %-camera normalization-%
    if opts.useQuiverCamera
        normFac = abs(min(cameraEye));
        if isprop(axisData, "Layout") ...
                && isprop(get(axisData, 'Layout'), "TileSpan")
            fac = size(get(get(axisData, 'Layout'), 'TileSpan'), 2);
        else
            fac = 1;
        end
        r1 = rangeLength([1, prod(aspectRatio([1,2]))]);
        r2 = rangeLength([1, prod(aspectRatio([1,3]))]);
        r3 = rangeLength([1, prod(aspectRatio([2,3]))]);
        r = max([r1, r2, r3]);
        eyeScale = (1.4 + r * fac) / normFac;
    elseif isnan(opts.normFacScale)
        cameraOffset = 0.5;
        normFac = abs(min(cameraEye));
        normFac = normFac ...
            / (max(aspectRatio)/min(aspectRatio) + cameraOffset);
        eyeScale = 1 / normFac;
    else
        normFac = opts.normFacScale * abs(min(cameraEye));
        eyeScale = 1 / normFac;
    end

    %-aspect ratio-%
    scene.aspectratio.x = opts.aspectMultiplier(1) * aspectRatio(1);
    scene.aspectratio.y = opts.aspectMultiplier(2) * aspectRatio(2);
    scene.aspectratio.z = opts.aspectMultiplier(3) * aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1) * eyeScale;
    scene.camera.eye.y = cameraEye(2) * eyeScale;
    scene.camera.eye.z = cameraEye(3) * eyeScale;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-scene axis configuration-%
    scene.xaxis.range = get(axisData, 'XLim');
    scene.yaxis.range = get(axisData, 'YLim');
    scene.zaxis.range = get(axisData, 'ZLim');

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.ticklabelposition = "outside";
    scene.yaxis.ticklabelposition = "outside";
    scene.zaxis.ticklabelposition = "outside";

    scene.xaxis.title = get(get(axisData, 'XLabel'), 'String');
    scene.yaxis.title = get(get(axisData, 'YLabel'), 'String');
    scene.zaxis.title = get(get(axisData, 'ZLabel'), 'String');

    if opts.setTitleFont
        scene.xaxis.titlefont.color = "rgba(0,0,0,1)";
        scene.yaxis.titlefont.color = "rgba(0,0,0,1)";
        scene.zaxis.titlefont.color = "rgba(0,0,0,1)";
        scene.xaxis.titlefont.size = get(get(axisData, 'XLabel'), 'FontSize');
        scene.yaxis.titlefont.size = get(get(axisData, 'YLabel'), 'FontSize');
        scene.zaxis.titlefont.size = get(get(axisData, 'ZLabel'), 'FontSize');
        scene.xaxis.titlefont.family = ...
            matlab2plotlyfont(get(get(axisData, 'XLabel'), 'FontName'));
        scene.yaxis.titlefont.family = ...
            matlab2plotlyfont(get(get(axisData, 'YLabel'), 'FontName'));
        scene.zaxis.titlefont.family = ...
            matlab2plotlyfont(get(get(axisData, 'ZLabel'), 'FontName'));
    end

    %-tick labels-%
    if opts.handleDatetimeTicks
        xTick = resolveDatetimeTicks(get(axisData, 'XTick'), get(axisData, 'XTickLabel'));
        yTick = resolveDatetimeTicks(get(axisData, 'YTick'), get(axisData, 'YTickLabel'));
        zTick = resolveDatetimeTicks(get(axisData, 'ZTick'), get(axisData, 'ZTickLabel'));
    else
        xTick = get(axisData, 'XTick');
        yTick = get(axisData, 'YTick');
        zTick = get(axisData, 'ZTick');
    end

    scene.xaxis.tickvals = xTick;
    scene.xaxis.ticktext = get(axisData, 'XTickLabel');
    scene.yaxis.tickvals = yTick;
    scene.yaxis.ticktext = get(axisData, 'YTickLabel');
    scene.zaxis.tickvals = zTick;
    scene.zaxis.ticktext = get(axisData, 'ZTickLabel');

    scene.xaxis.tickcolor = "rgba(0,0,0,1)";
    scene.yaxis.tickcolor = "rgba(0,0,0,1)";
    scene.zaxis.tickcolor = "rgba(0,0,0,1)";
    scene.xaxis.tickfont.size = get(axisData, 'FontSize');
    scene.yaxis.tickfont.size = get(axisData, 'FontSize');
    scene.zaxis.tickfont.size = get(axisData, 'FontSize');
    scene.xaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));
    scene.yaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));
    scene.zaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));

    %-grid-%
    if strcmp(get(axisData, 'XGrid'), "off")
        scene.xaxis.showgrid = false;
    end
    if strcmp(get(axisData, 'YGrid'), "off")
        scene.yaxis.showgrid = false;
    end
    if strcmp(get(axisData, 'ZGrid'), "off")
        scene.zaxis.showgrid = false;
    end

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xSource) = scene;
end

function tickVals = resolveDatetimeTicks(tick, tickLabel)
    tickVals = tick;
    if isduration(tick) || isdatetime(tick)
        tickChar = char(tick);
        idx = zeros(1, length(tickLabel));
        for n = 1:length(tickLabel)
            for m = 1:size(tickChar, 1)
                if contains(tickChar(m, :), tickLabel{n})
                    idx(n) = m;
                end
            end
        end
        tickVals = datenum(tick(idx));
    end
end

function updateScene(obj, dataIndex, varargin)
    opts.normFacScale = NaN;
    opts.aspectMultiplier = [1 1 1];
    opts.setTitleFont = true;
    opts.handleDatetimeTicks = true;
    opts.useQuiverCamera = false;
    nargs = numel(varargin);
    if mod(nargs, 2) ~= 0
        error("updateScene:options", "Arguments must be provided as Name, Value pairs.");
    end
    for k = 1:2:nargs
        opts.(varargin{k}) = varargin{k+1};
    end

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    % Octave groups some plot types (stem3, quiver3...) into hggroup
    % objects; the plot handle passed here may be a child of the
    % group, so climb up to the axes
    axisData = ancestor(plotData, 'axes');
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.(sprintf("scene%d", xSource));

    %-axes geometry-%
    xlim = get(axisData, 'XLim');
    ylim = get(axisData, 'YLim');
    zlim = get(axisData, 'ZLim');
    pb = get(axisData, 'PlotBoxAspectRatio');
    view = get(axisData, 'View');
    az = view(1);
    el = view(2);
    if isprop(axisData, 'CameraProjection')
        camProj = get(axisData, 'CameraProjection');
    else
        camProj = 'perspective';
    end
    %-replicate Octave/MATLAB's camera computation (axes::properties::update_camera)-%
    xr = xlim(2) - xlim(1);
    yr = ylim(2) - ylim(1);
    zr = zlim(2) - zlim(1);

    d = 5 * sqrt(sum(pb .^ 2));
    azr = az * pi / 180;
    elr = el * pi / 180;

    if el == 90 || el == -90
        dir = [0 0 sign(el)];
    else
        dir = [cos(elr) * sin(azr), -cos(elr) * cos(azr), sin(elr)];
    end

    % camera eye in data units
    eye = [0 0 0];
    eye(1) = dir(1) * xr / pb(1);
    eye(2) = dir(2) * yr / pb(2);
    eye(3) = dir(3) * zr / pb(3);
    eye = d * eye + [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2, ...
        (zlim(1) + zlim(2)) / 2];

    % camera up vector in data units
    if el == 90 || el == -90
        up = [sign(el) * sin(azr), sign(el) * cos(azr), 0];
        up(1) = up(1) * xr / pb(1);
        up(2) = up(2) * yr / pb(2);
    else
        up = [0 0 1];
    end

    %-projected extents of the plot box in view space (unit cube)-%
    % the plot box spans [0 1]^3 in the "unit cube" space used by the
    % viewport fit; transform its corners into view space and measure
    % the projected width and height
    [~, ~, ~, ~, upView] = projectedBoxExtents(eye, up, ...
        xlim, ylim, zlim, pb);

    %-scene aspect ratio-%
    % the plot box proportions; plotly's scene box is centered at the
    % origin and spans [aspectratio] in scene units
    scene.aspectratio.x = pb(1) * opts.aspectMultiplier(1);
    scene.aspectratio.y = pb(2) * opts.aspectMultiplier(2);
    scene.aspectratio.z = pb(3) * opts.aspectMultiplier(3);

    if strcmpi(camProj, 'orthographic')
        scene.camera.projection.type = 'orthographic';
    else
        scene.camera.projection.type = 'perspective';
    end

    %-camera center and eye-%
    % the eye direction follows the view angle; the distance keeps the
    % original normalization so the plot box is not magnified
    center = [0 0 0];
    eyeDir = dir / norm(dir);

    cameraPosition = get(axisData, 'CameraPosition');
    dataAspectRatio = get(axisData, 'DataAspectRatio');
    cameraEye = cameraPosition ./ dataAspectRatio;

    %-camera normalization-%
    if opts.useQuiverCamera
        normFac = abs(min(cameraEye));
        if isprop(axisData, "Layout") ...
                && all(isprop(get(axisData, 'Layout'), "TileSpan"))
            fac = size(get(get(axisData, 'Layout'), 'TileSpan'), 2);
        else
            fac = 1;
        end
        r1 = rangeLength([1, prod(pb([1, 2]))]);
        r2 = rangeLength([1, prod(pb([1, 3]))]);
        r3 = rangeLength([1, prod(pb([2, 3]))]);
        r = max([r1, r2, r3]);
        eyeScale = (1.4 + r * fac) / normFac;
    elseif isnan(opts.normFacScale)
        % the eye distance scales with the plot box so every scene
        % fits the viewport the same way (Octave places the camera at
        % a distance proportional to the box diagonal); the constant
        % keeps the 1:1:1 box at its original distance
        boxDiag = sqrt(sum(pb .^ 2));
        eyeScale = 1.2586 * boxDiag / norm(cameraEye);
    else
        normFac = opts.normFacScale * abs(min(cameraEye));
        eyeScale = 1 / normFac;
    end

    eyeDist = norm(cameraEye) * eyeScale;

    scene.camera.eye.x = center(1) + eyeDist * eyeDir(1);
    scene.camera.eye.y = center(2) + eyeDist * eyeDir(2);
    scene.camera.eye.z = center(3) + eyeDist * eyeDir(3);

    scene.camera.center.x = center(1);
    scene.camera.center.y = center(2);
    scene.camera.center.z = center(3);

    %-camera up (direction only, unit length is fine)-%
    upDir = upView;
    if norm(upDir) > 0
        upDir = upDir / norm(upDir);
    else
        upDir = [0 0 1];
    end
    scene.camera.up.x = upDir(1);
    scene.camera.up.y = upDir(2);
    scene.camera.up.z = upDir(3);

    %-scene axis configuration-%
    scene.xaxis.range = xlim;
    scene.yaxis.range = ylim;
    scene.zaxis.range = zlim;

    %-reversed axes (bar3/bar3h mirror the y axis)-%
    if isprop(axisData, 'XDir') && strcmp(get(axisData, 'XDir'), 'reverse')
        scene.xaxis.range = fliplr(scene.xaxis.range);
    end
    if isprop(axisData, 'YDir') && strcmp(get(axisData, 'YDir'), 'reverse')
        scene.yaxis.range = fliplr(scene.yaxis.range);
    end
    if isprop(axisData, 'ZDir') && strcmp(get(axisData, 'ZDir'), 'reverse')
        scene.zaxis.range = fliplr(scene.zaxis.range);
    end

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

    %-invisible axes (pie3, hidden frames) draw no axis furniture-%
    if isprop(axisData, 'Visible') && strcmp(get(axisData, 'Visible'), 'off')
        scene.xaxis.showline = false;
        scene.yaxis.showline = false;
        scene.zaxis.showline = false;
        scene.xaxis.showticklabels = false;
        scene.yaxis.showticklabels = false;
        scene.zaxis.showticklabels = false;
        scene.xaxis.ticks = '';
        scene.yaxis.ticks = '';
        scene.zaxis.ticks = '';
        scene.xaxis.showgrid = false;
        scene.yaxis.showgrid = false;
        scene.zaxis.showgrid = false;
        scene.xaxis.title = '';
        scene.yaxis.title = '';
        scene.zaxis.title = '';
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
    obj.layout.(sprintf("scene%d", xSource)) = scene;
end

function [xM, yM, fView, normF, UP] = projectedBoxExtents(eye, up, xlim, ylim, zlim, pb)
    % transform the plot box corners into view space and measure the
    % projected width and height, replicating Octave's
    % axes::properties::update_camera
    xr = xlim(2) - xlim(1);
    yr = ylim(2) - ylim(1);
    zr = zlim(2) - zlim(1);

    % data -> unit cube [0 1]^3
    eyeU = (eye - [xlim(1) ylim(1) zlim(1)]) ./ [xr yr zr];
    centerU = 0.5 * ones(1, 3);
    upU = up .* [pb(1) / xr, pb(2) / yr, pb(3) / zr];

    F = centerU - eyeU;
    normF = norm(F);
    f = F / normF;
    if norm(upU) > 0
        UP = upU / norm(upU);
    else
        UP = [0 0 1];
    end
    if abs(dot(f, UP)) > 1e-15
        fa = 1 / sqrt(1 - f(3) * f(3));
        UP = UP * fa;
    end

    s = cross(f, UP);
    u = cross(s, f);
    l = [s; u; -f];

    % unit cube corners in view space
    corners = zeros(8, 3);
    idx = 0;
    for i = 0:1
        for j = 0:1
            for k = 0:1
                idx = idx + 1;
                c = [i j k];
                v = l * (c - eyeU)';
                v(3) = -v(3);
                corners(idx, :) = v';
            end
        end
    end

    xM = max(corners(:, 1)) - min(corners(:, 1));
    yM = max(corners(:, 2)) - min(corners(:, 2));
    fView = -f;
end

function tickVals = resolveDatetimeTicks(tick, tickLabel)
    tickVals = tick;
    if isa(tick, "duration") || isa(tick, "datetime")
        tickChar = char(tick);
        idx = zeros(1, length(tickLabel));
        for n = 1:length(tickLabel)
            for m = 1:size(tickChar, 1)
                if isempty(tickLabel{n}) || ~isempty(strfind(tickChar(m, :), tickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        tickVals = datenum(tick(idx));
    end
end

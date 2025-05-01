function obj = updateQuiver(obj, dataIndex)
    %-INITIALIZATIONS-%

    %-get structures-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    xSource = findSourceAxis(obj,axIndex);

    %-get trace data-%
    xData = plotData.XData;
    yData = plotData.YData;
    zData = plotData.ZData;

    if isvector(xData)
        [xData, yData] = meshgrid(xData, yData);
    end

    if strcmpi(plotData.AutoScale, 'on')
        scaleFactor = getScaleFactor(xData, plotData.UData, 45);
    else
        scaleFactor = 1;
    end

    uData = plotData.UData * scaleFactor;
    vData = plotData.VData * scaleFactor;
    wData = plotData.WData * scaleFactor;

    %-check if is 3D quiver-%
    isQuiver3D = ~isempty(zData);

    %-update axis-%
    if isQuiver3D
        updateScene(obj, dataIndex);
    end

    %-set trace-%
    if isQuiver3D
        obj.data{dataIndex}.type = 'scatter3d';
        obj.data{dataIndex}.scene = sprintf('scene%d', xSource);
    else
        obj.data{dataIndex}.type = 'scatter';
        obj.data{dataIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{dataIndex}.yaxis = sprintf('y%d', xSource);
    end

    obj.data{dataIndex}.mode = 'lines';
    obj.data{dataIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{dataIndex}.name = plotData.DisplayName;

    %-quiver line color-%
    lineColor = round(255*plotData.Color);
    obj.data{dataIndex}.line.color = getStringColor(lineColor);

    %-quiver line width-%
    obj.data{dataIndex}.line.width = 2.5 * plotData.LineWidth;

    %-set trace data for quiver line only-%
    m = 1;

    for n = 1:numel(xData)
        obj.data{dataIndex}.x(m) = xData(n);
        obj.data{dataIndex}.x(m+1) = xData(n) + uData(n);
        obj.data{dataIndex}.x(m+2) = nan;

        obj.data{dataIndex}.y(m) = yData(n);
        obj.data{dataIndex}.y(m+1) = yData(n) + vData(n);
        obj.data{dataIndex}.y(m+2) = nan;

        if isQuiver3D
            obj.data{dataIndex}.z(m) = zData(n);
            obj.data{dataIndex}.z(m+1) = zData(n) + wData(n);
            obj.data{dataIndex}.z(m+2) = nan;
        end
        m = m + 3;
    end

    %-set trace data for quiver barb-%
    if isHG2() && strcmp(plotData.ShowArrowHead, 'on')
        maxHeadSize = plotData.MaxHeadSize * 1.5;
        headWidth = 20;
        for n = 1:numel(xData)
            if isQuiver3D
                quiverBarb = getQuiverBarb3D(...
                    xData(n), yData(n), zData(n), ...
                    uData(n), vData(n), wData(n), ...
                    maxHeadSize, headWidth, 'simple' ...
                );
            else
                quiverBarb = getQuiverBarb2D(...
                    xData(n), yData(n), ...
                    uData(n), vData(n), ...
                    maxHeadSize, headWidth ...
                );
            end
            for m = 1:size(quiverBarb, 2)
                obj.data{dataIndex}.x(end+1) = quiverBarb(1, m);
                obj.data{dataIndex}.y(end+1) = quiverBarb(2, m);
                if isQuiver3D
                    obj.data{dataIndex}.z(end+1) = quiverBarb(3, m);
                end
            end
        end
    end

    %-set trace legend-%
    switch plotData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{dataIndex}.showlegend = true;
        case "off"
            obj.data{dataIndex}.showlegend = false;
    end
end

function updateScene(obj, dataIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.("scene" + xSource);

    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    dataAspectRatio = axisData.DataAspectRatio;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition./dataAspectRatio;
    normFac = abs(min(cameraEye));

    if isprop(axisData, "Layout") && isprop(axisData.Layout, "TileSpan")
        fac = size(axisData.Layout.TileSpan, 2);
    else
        fac = 1;
    end

    r1 = rangeLength([ 1, prod(aspectRatio([1,2])) ]);
    r2 = rangeLength([ 1, prod(aspectRatio([1,3])) ]);
    r3 = rangeLength([ 1, prod(aspectRatio([2,3])) ]);
    r = max([r1, r2, r3]);

    %-aspect ratio-%
    scene.aspectratio.x = 1.0*aspectRatio(1);
    scene.aspectratio.y = 1.0*aspectRatio(2);
    scene.aspectratio.z = 1.0*aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1) / normFac * (1.4 + r * fac);
    scene.camera.eye.y = cameraEye(2) / normFac * (1.4 + r * fac);
    scene.camera.eye.z = cameraEye(3) / normFac * (1.4 + r * fac);

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-camera projection-%
    % scene.camera.projection.type = axisData.Projection;

    %-scene axis configuration-%
    rangeFac = 0.0;

    xRange = rangeLength(axisData.XLim);
    scene.xaxis.range(1) = axisData.XLim(1) - rangeFac * xRange;
    scene.xaxis.range(2) = axisData.XLim(2) + rangeFac * xRange;

    yRange = rangeLength(axisData.YLim);
    scene.yaxis.range(1) = axisData.YLim(1) - rangeFac * yRange;
    scene.yaxis.range(2) = axisData.YLim(2) + rangeFac * yRange;

    zRange = rangeLength(axisData.ZLim);
    scene.zaxis.range(1) = axisData.ZLim(1) - rangeFac * zRange;
    scene.zaxis.range(2) = axisData.ZLim(2) + rangeFac * zRange;

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.ticklabelposition = 'outside';
    scene.yaxis.ticklabelposition = 'outside';
    scene.zaxis.ticklabelposition = 'outside';

    scene.xaxis.title = axisData.XLabel.String;
    scene.yaxis.title = axisData.YLabel.String;
    scene.zaxis.title = axisData.ZLabel.String;

    %-tick labels-%
    scene.xaxis.tickvals = axisData.XTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.yaxis.tickvals = axisData.YTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.zaxis.tickvals = axisData.ZTick;
    scene.zaxis.ticktext = axisData.ZTickLabel;

    scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.zaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.size = axisData.FontSize;
    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    %-grid-%
    if strcmp(axisData.XGrid, 'off')
        scene.xaxis.showgrid = false;
    end
    if strcmp(axisData.YGrid, 'off')
        scene.yaxis.showgrid = false;
    end
    if strcmp(axisData.ZGrid, 'off')
        scene.zaxis.showgrid = false;
    end

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xsource) = scene;
end

function quiverBarb = getQuiverBarb2D(...
        xData, yData, ...
        uData, vData, ...
        maxHeadSize, headWidth ...
    )
    %-initializations-%

    refVector = [uData; vData];
    refLen = norm(refVector);
    invRefLen = 1/refLen;

    xRefAngle = acos( ([1,0]*refVector) * invRefLen );
    yRefAngle = acos( ([0,1]*refVector) * invRefLen );
    refAngle = [xRefAngle; yRefAngle];

    xHead = xData + uData;
    yHead = yData + vData;
    head = [xHead; yHead];

    quiverBarb = getBarb2D(head, refAngle, refLen, maxHeadSize, headWidth);
end

function barb = getBarb2D(head, refAngle, refLen, maxHeadSize, headWidth)
    refPoint = -maxHeadSize * refLen * cos(refAngle');
    rotPoint1 = rotation2D(refPoint, deg2rad(headWidth));
    rotPoint2 = rotation2D(refPoint, deg2rad(-headWidth));

    barbPoint1 = translation2D(rotPoint1, head);
    barbPoint2 = translation2D(rotPoint2, head);

    barb = [barbPoint1', head, barbPoint2', NaN(2,1)];
end

function outPoint = translation2D(inPoint, offsetPoint)
    xt = offsetPoint(1); yt = offsetPoint(2);
    T = affine2d(...
        [...
            1 , 0 , 0; ...
            0 , 1 , 0; ...
            xt, yt, 1  ...
        ]...
    );
    outPoint = transformPointsForward(T, inPoint);
end

function outPoint = rotation2D(inPoint, phi)
    T = affine2d(...
        [...
            cos(phi) , sin(phi), 0; ...
            -sin(phi), cos(phi), 0; ...
            0        , 0       , 1; ...
        ]...
    );
    outPoint = transformPointsForward(T, inPoint);
end

function quiverBarb = getQuiverBarb3D(...
        xData, yData, zData, ...
        uData, vData, wData, ...
        maxHeadSize, headWidth, barbMode ...
    )
    %-initializations-%

    refVector = [uData; vData; wData];
    refLen = norm(refVector);
    invRefLen = 1/refLen;

    xRefAngle = acos( ([1,0,0]*refVector) * invRefLen );
    yRefAngle = acos( ([0,1,0]*refVector) * invRefLen );
    zRefAngle = acos( ([0,0,1]*refVector) * invRefLen );
    refAngle = [xRefAngle; yRefAngle; zRefAngle];

    xHead = xData + uData;
    yHead = yData + vData;
    zHead = zData + wData;
    head = [xHead; yHead; zHead];

    xBarb = getBarb3D(head, refAngle, refLen, maxHeadSize, headWidth, 'x');
    yBarb = getBarb3D(head, refAngle, refLen, maxHeadSize, headWidth, 'y');
    zBarb = getBarb3D(head, refAngle, refLen, maxHeadSize, headWidth, 'z');

    if strcmp(barbMode, 'extend')
        quiverBarb = [xBarb, yBarb, zBarb];
    elseif strcmp(barbMode, 'simple')
        quiverBarb1 = mean([xBarb(:,1), yBarb(:,1), zBarb(:,1)], 2);
        quiverBarb2 = mean([xBarb(:,3), yBarb(:,3), zBarb(:,3)], 2);
        quiverBarb = [quiverBarb1, xBarb(:,2), quiverBarb2, xBarb(:,4)];
    end
end

function barb = getBarb3D(head, refAngle, refLen, maxHeadSize, headWidth, ...
        refAxis)
    refPoint = -maxHeadSize * refLen * cos(refAngle');
    rotPoint1 = rotation3D(refPoint, deg2rad(headWidth), refAxis);
    rotPoint2 = rotation3D(refPoint, deg2rad(-headWidth), refAxis);

    barbPoint1 = translation3D(rotPoint1, head);
    barbPoint2 = translation3D(rotPoint2, head);

    barb = [barbPoint1', head, barbPoint2', NaN(3,1)];
end

function outPoint = translation3D(inPoint, offsetPoint)
    xt = offsetPoint(1); yt = offsetPoint(2); zt = offsetPoint(3);
    T = affine3d(...
        [...
            1 , 0 , 0 , 0; ...
            0 , 1 , 0 , 0; ...
            0 , 0 , 1 , 0; ...
            xt, yt, zt, 1  ...
        ]...
    );
    outPoint = transformPointsForward(T, inPoint);
end

function outPoint = rotation3D(inPoint, phi, refAxis)
    switch refAxis
        case 'x'
            T = affine3d(...
                [...
                    1, 0        , 0        , 0; ...
                    0, cos(phi) , sin(phi) , 0; ...
                    0, -sin(phi), cos(phi) , 0; ...
                    0, 0        , 0        , 1  ...

                ]...
            );

        case 'y'
            T = affine3d(...
                [...
                    cos(phi), 0, -sin(phi), 0; ...
                    0       , 1, 0        , 0; ...
                    sin(phi), 0, cos(phi) , 0; ...
                    0       , 0, 0        , 1  ...
                ]...
            );

        case 'z'
            T = affine3d(...
                [...
                    cos(phi) , sin(phi), 0, 0; ...
                    -sin(phi), cos(phi), 0, 0; ...
                    0        , 0       , 1, 0; ...
                    0        , 0       , 0, 1  ...
                ]...
            );
    end
    outPoint = transformPointsForward(T, inPoint);
end

function scaleFactor = getScaleFactor(xData, uData, nSteps)
    xStep = max( abs(diff( mean(xData(:,:,1), 1) )) );
    uStep = max(abs(uData(:)));

    scaleFactor = 0.8 * xStep/uStep;
end

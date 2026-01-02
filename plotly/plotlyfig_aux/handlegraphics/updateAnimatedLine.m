function updateAnimatedLine(obj,plotIndex)
    axisData = obj.State.Plot(plotIndex).AssociatedAxis;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(axisData);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    animObjs = obj.State.Plot(plotIndex).AssociatedAxis.Children;

    for i=1:numel(animObjs)
        if isequaln(animObjs(i),plotData)
            animObj = animObjs(i);
        end
    end

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-if polar plot or not-%
    treatas = obj.PlotOptions.TreatAs;
    ispolar = strcmpi(treatas, 'compass') || strcmpi(treatas, 'ezpolar');

    %-getting data-%
    try
        [x,y,z] = getpoints(animObj);
    catch
        x = plotData.XData;
        y = plotData.YData;
        z = plotData.ZData;
    end

    obj.data{plotIndex}.xaxis = "x" + xsource;
    obj.data{plotIndex}.yaxis = "y" + ysource;

    %-scatter type-%
    obj.data{plotIndex}.type = 'scatter';
    if ispolar
        obj.data{plotIndex}.type = 'scatterpolar';
    end

    %-scatter visible-%
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');

    %-scatter x-%
    if ispolar
        r = sqrt(x.^2 + y.^2);
        obj.data{plotIndex}.r = r;
    else
        obj.data{plotIndex}.x = [x(1) x(1)];
    end

    %-scatter y-%
    if ispolar
        theta = atan2(x,y);
        obj.data{plotIndex}.theta = -(rad2deg(theta) - 90);
    else
        obj.data{plotIndex}.y = [y(1) y(1)];
    end

    %-For 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    numbset = unique(z);
    if numel(numbset)>1
        if any(z)
            %-scatter z-%
            obj.data{plotIndex}.z = [z(1) z(1)];
            %-overwrite type-%
            obj.data{plotIndex}.type = 'scatter3d';
            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    %-scatter name-%
    obj.data{plotIndex}.name = plotData.DisplayName;

    %-scatter mode-%
    if ~strcmpi('none', plotData.Marker) ...
            && ~strcmpi('none', plotData.LineStyle)
        mode = 'lines+markers';
    elseif ~strcmpi('none', plotData.Marker)
        mode = 'markers';
    elseif ~strcmpi('none', plotData.LineStyle)
        mode = 'lines';
    else
        mode = 'none';
    end

    obj.data{plotIndex}.mode = mode;
    obj.data{plotIndex}.line = extractLineLine(plotData);
    obj.data{plotIndex}.marker = extractLineMarker(plotData);

    %-scatter showlegend-%
    switch plotData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{plotIndex}.showlegend = true;
        case "off"
            obj.data{plotIndex}.showlegend = false;
    end

    %-SCENE CONFIGURATION-% for 3D animations, like comet3
    if obj.PlotOptions.is3d
        %-aspect ratio-%
        asr = obj.PlotOptions.AspectRatio;
        if ~isempty(asr)
            if ischar(asr)
                scene.aspectmode = asr;
            elseif isvector(ar) && length(asr) == 3
                zar = asr(3);
            end
        else
            %-define as default-%
            xar = max(x(:));
            yar = max(y(:));
            xyar = max([xar, yar]);
            zar = 0.75*xyar;
        end

        scene.aspectratio.x = 1.1*xyar;
        scene.aspectratio.y = 1.0*xyar;
        scene.aspectratio.z = zar;

        %-camera eye-%
        ey = obj.PlotOptions.CameraEye;

        if ~isempty(ey)
            if isvector(ey) && length(ey) == 3
                scene.camera.eye.x = ey(1);
                scene.camera.eye.y = ey(2);
                scene.camera.eye.z = ey(3);
            end
        else
            %-define as default-%
            xey = - xyar;
            if xey>0
                xfac = -0.0;
            else
                xfac = 0.0;
            end
            yey = - xyar;
            if yey>0
                yfac = -0.3;
            else
                yfac = 0.3;
            end
            if zar>0
                zfac = -0.1;
            else
                zfac = 0.1;
            end

            scene.camera.eye.x = xey + xfac*xey;
            scene.camera.eye.y = yey + yfac*yey;
            scene.camera.eye.z = zar + zfac*zar;
        end

        %-scene axis configuration-%
        scene.xaxis.range = axisData.XLim;
        scene.yaxis.range = axisData.YLim;
        scene.zaxis.range = axisData.ZLim;

        scene.xaxis.tickvals = axisData.XTick;
        scene.xaxis.ticktext = axisData.XTickLabel;

        scene.yaxis.tickvals = axisData.YTick;
        scene.yaxis.ticktext = axisData.YTickLabel;

        scene.zaxis.tickvals = axisData.ZTick;
        scene.zaxis.ticktext = axisData.ZTickLabel;

        scene.xaxis.zeroline = false;
        scene.yaxis.zeroline = false;
        scene.zaxis.zeroline = false;

        scene.xaxis.showgrid = strcmpi(axisData.XGrid,'on');
        scene.yaxis.showgrid = strcmpi(axisData.YGrid,'on');
        scene.zaxis.showgrid = strcmpi(axisData.ZGrid,'on');

        scene.xaxis.showline = true;
        scene.yaxis.showline = true;
        scene.zaxis.showline = true;

        scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
        scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
        scene.zaxis.tickcolor = 'rgba(0,0,0,1)';

        scene.xaxis.ticklabelposition = 'outside';
        scene.yaxis.ticklabelposition = 'outside';
        scene.zaxis.ticklabelposition = 'outside';

        scene.xaxis.title = axisData.XLabel.String;
        scene.yaxis.title = axisData.YLabel.String;
        scene.zaxis.title = axisData.ZLabel.String;

        scene.xaxis.tickfont.size = axisData.FontSize;
        scene.yaxis.tickfont.size = axisData.FontSize;
        scene.zaxis.tickfont.size = axisData.FontSize;

        scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
        scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
        scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

        %-SET SCENE TO LAYOUT-%
        obj.layout.("scene" + xsource) = scene;
    end

    %-Add a temporary tag-%
    obj.layout.isAnimation = true;

    %-Create Frames-%
    frameData = obj.data{plotIndex};

    for i = 1:length(x)
        sIdx = i - plotData.MaximumNumPoints;
        if sIdx < 0
            sIdx=0;
        end
        frameData.x=x(sIdx+1:i);
        frameData.y=y(sIdx+1:i);
        if obj.PlotOptions.is3d
            frameData.z=z(sIdx+1:i);
        end
        obj.frames{i}.name = ['f',num2str(i)];
        obj.frames{i}.data{plotIndex} = frameData;
    end
end

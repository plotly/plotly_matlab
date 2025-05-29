function updateComet(obj,plotIndex)
    %----SCATTER FIELDS----%
    % x - [DONE]
    % y - [DONE]
    % r - [HANDLED BY SCATTER]
    % t - [HANDLED BY SCATTER]
    % mode - [DONE]
    % name - [NOT SUPPORTED IN MATLAB]
    % text - [DONE]
    % error_y - [HANDLED BY ERRORBAR]
    % error_x - [NOT SUPPORTED IN MATLAB]
    % connectgaps - [NOT SUPPORTED IN MATLAB]
    % fill - [HANDLED BY AREA]
    % fillcolor - [HANDLED BY AREA]
    % opacity --- [TODO]
    % textfont - [NOT SUPPORTED IN MATLAB]
    % textposition - [NOT SUPPORTED IN MATLAB]
    % xaxis [DONE]
    % yaxis [DONE]
    % showlegend [DONE]
    % stream - [HANDLED BY PLOTLYSTREAM]
    % visible [DONE]
    % type [DONE]

    % MARKER
    % marler.color - [DONE]
    % marker.size - [DONE]
    % marker.line.color - [DONE]
    % marker.line.width - [DONE]
    % marker.line.dash - [NOT SUPPORTED IN MATLAB]
    % marker.line.opacity - [NOT SUPPORTED IN MATLAB]
    % marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
    % marker.line.shape - [NOT SUPPORTED IN MATLAB]
    % marker.opacity --- [TODO]
    % marker.colorscale - [NOT SUPPORTED IN MATLAB]
    % marker.sizemode - [NOT SUPPORTED IN MATLAB]
    % marker.sizeref - [NOT SUPPORTED IN MATLAB]
    % marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]

    % LINE
    % line.color - [DONE]
    % line.width - [DONE]
    % line.dash - [DONE]
    % line.opacity --- [TODO]
    % line.smoothing - [NOT SUPPORTED IN MATLAB]
    % line.shape - [NOT SUPPORTED IN MATLAB]
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
        if strcmpi(animObjs(i).Tag,'tail')
            tail = animObjs(i);
        end
        if strcmpi(animObjs(i).Tag,'body')
            body = animObjs(i);
        end
    end

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-getting data-%
    [x,y,z] = getpoints(tail);

    obj.data{plotIndex}.xaxis = "x" + xsource;
    obj.data{plotIndex}.yaxis = "y" + ysource;
    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{plotIndex}.x = x(1);
    obj.data{plotIndex}.y = y(1);

    %-For 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    nSet = unique(z);
    if numel(nSet)>1
        if any(z)
            %-scatter z-%
            obj.data{plotIndex}.z = z(1);

            %-overwrite type-%
            obj.data{plotIndex}.type = 'scatter3d';

            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    %-scatter name-%
    obj.data{plotIndex}.name = plotData.Tag;

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

    switch(plotData.Tag)
        case 'head'
            for i = 1:length(x)
                frameData.x=[x(i) x(i)];
                frameData.y=[y(i) y(i)];
                if obj.PlotOptions.is3d
                    frameData.z=[z(i) z(i)];
                end
                obj.frames{i}.data{plotIndex} = frameData;
                obj.frames{i}.name=['f',num2str(i)];
            end
        case 'body'
            for i = 1:length(x)
                sIdx = i-animObj.MaximumNumPoints;
                if sIdx < 0
                    sIdx=0;
                end
                frameData.x=x(sIdx+1:i);
                frameData.y=y(sIdx+1:i);
                if obj.PlotOptions.is3d
                    frameData.z=z(sIdx+1:i);
                end
                if i==length(x)
                    frameData.x=nan;
                    frameData.y=nan;
                    if obj.PlotOptions.is3d
                        frameData.z=nan;
                    end
                end
                obj.frames{i}.data{plotIndex} = frameData;
            end
        case 'tail'
            for i = 1:length(x)
                frameData.x=x(1:i);
                frameData.y=y(1:i);
                if obj.PlotOptions.is3d
                    frameData.z=z(1:i);
                end
                if i < body.MaximumNumPoints
                    rIdx = i;
                else
                    rIdx = body.MaximumNumPoints;
                end
                if i ~= length(x)
                    val = nan(rIdx,1);
                    frameData.x(end-rIdx+1:end)=val;
                    frameData.y(end-rIdx+1:end)=val;
                    if obj.PlotOptions.is3d
                        frameData.z(end-rIdx+1:end)=val;
                    end
                end
                obj.frames{i}.data{plotIndex} = frameData;
            end
    end
end

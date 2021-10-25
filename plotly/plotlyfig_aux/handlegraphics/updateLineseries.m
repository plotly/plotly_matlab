function updateLineseries(obj, plotIndex)

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

    %-------------------------------------------------------------------------%

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = get(obj.State.Plot(plotIndex).Handle);

    %-CHECK FOR MULTIPLE AXES-%
    try
        for yax = 1:2
            yaxIndex(yax) = sum(plotData.Parent.YAxis(yax).Color == plotData.Color);
        end

        [~, yaxIndex] = max(yaxIndex);
        [xsource, ysource] = findSourceAxis(obj, axIndex, yaxIndex);

    catch
        [xsource, ysource] = findSourceAxis(obj,axIndex);
    end

    %-AXIS DATA-%
    eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
    eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

    %-------------------------------------------------------------------------%

    %-if polar plot or not-%
    treatAs = obj.PlotOptions.TreatAs;
    isPolar = ismember('compass', lower(treatAs)) || ismember('ezpolar', lower(treatAs));

    %-------------------------------------------------------------------------%

    %-getting data-%
    xData = plotData.XData;
    yData = plotData.YData;

    if isduration(xData) || isdatetime(xData), xData = datenum(xData); end
    if isduration(yData) || isdatetime(yData), yData = datenum(yData); end

    %-------------------------------------------------------------------------%

    %-scatter xaxis-%
    obj.data{plotIndex}.xaxis = ['x' num2str(xsource)];

    %-------------------------------------------------------------------------%

    %-scatter yaxis-%
    obj.data{plotIndex}.yaxis = ['y' num2str(ysource)];

    %-------------------------------------------------------------------------%

    %-scatter type-%
    obj.data{plotIndex}.type = 'scatter';

    if isPolar
        obj.data{plotIndex}.type = 'scatterpolar';
    end

    %-------------------------------------------------------------------------%

    %-scatter visible-%
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');

    %-------------------------------------------------------------------------%

    %-scatter x-%

    if isPolar
        rData = sqrt(x.^2 + y.^2);
        obj.data{plotIndex}.r = rData;
    else
        obj.data{plotIndex}.x = xData;
    end

    %-------------------------------------------------------------------------%

    %-scatter y-%
    if isPolar
        thetaData = atan2(xData,yData);
        obj.data{plotIndex}.theta = -(rad2deg(thetaData) - 90);
    else
        obj.data{plotIndex}.y = yData;
    end

    %-------------------------------------------------------------------------%

    %-Fro 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    if isfield(plotData,'ZData')
        zData = plotData.ZData;
        if isduration(zData) || isdatetime(zData), zData = datenum(zData); end

        numbset = unique(zData);
        
        if any(zData) && length(numbset)>1
            %-scatter z-%
            obj.data{plotIndex}.z = zData;
            
            %-overwrite type-%
            obj.data{plotIndex}.type = 'scatter3d';
            obj.data{plotIndex}.scene = sprintf('scene%d', xsource);

            updateScene(obj, plotIndex);
            
            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    %-------------------------------------------------------------------------%

    %-scatter name-%
    obj.data{plotIndex}.name = plotData.DisplayName;

    %-------------------------------------------------------------------------%

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

    %-------------------------------------------------------------------------%

    %-scatter line-%
    obj.data{plotIndex}.line = extractLineLine(plotData);

    %-------------------------------------------------------------------------%

    %-scatter marker-%
    obj.data{plotIndex}.marker = extractLineMarker(plotData);

    %-------------------------------------------------------------------------%

    %-scatter showlegend-%
    leg = get(plotData.Annotation);
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case 'on'
            showLeg = true;
        case 'off'
            showLeg = false;
    end

    obj.data{plotIndex}.showlegend = showLeg;

    if isempty(obj.data{plotIndex}.name)
        obj.data{plotIndex}.showlegend = false;
    end

    %-------------------------------------------------------------------------%
end

function updateScene(obj, dataIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(dataIndex).Handle);
    axisData = get(plotData.Parent);
    [xSource, ~] = findSourceAxis(obj, axIndex);
    scene = eval( sprintf('obj.layout.scene%d', xSource) );

    cameraTarget = axisData.CameraTarget;
    position = axisData.Position;
    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    dataAspectRatio = axisData.DataAspectRatio;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition./dataAspectRatio;
    normFac = 0.7 * abs(min(cameraEye));

    %-------------------------------------------------------------------------%

    %-aspect ratio-%
    scene.aspectratio.x = 1.0*aspectRatio(1);
    scene.aspectratio.y = 1.0*aspectRatio(2);
    scene.aspectratio.z = 1.0*aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1) / normFac;
    scene.camera.eye.y = cameraEye(2) / normFac;
    scene.camera.eye.z = cameraEye(3) / normFac;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1); 
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-------------------------------------------------------------------------%

    %-scene axis configuration-%
    xRange = axisData.XLim;
    if isduration(xRange) || isdatetime(xRange), xRange = datenum(xRange); end
    scene.xaxis.range = xRange;

    yRange = axisData.YLim;
    if isduration(yRange) || isdatetime(yRange), yRange = datenum(yRange); end
    scene.yaxis.range = yRange;

    zRange = axisData.ZLim;
    if isduration(zRange) || isdatetime(zRange), zRange = datenum(zRange); end
    scene.zaxis.range = zRange;

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

    scene.xaxis.titlefont.color = 'rgba(0,0,0,1)';
    scene.yaxis.titlefont.color = 'rgba(0,0,0,1)';
    scene.zaxis.titlefont.color = 'rgba(0,0,0,1)';
    scene.xaxis.titlefont.size = axisData.XLabel.FontSize;
    scene.yaxis.titlefont.size = axisData.YLabel.FontSize;
    scene.zaxis.titlefont.size = axisData.ZLabel.FontSize;
    scene.xaxis.titlefont.family = matlab2plotlyfont(axisData.XLabel.FontName);
    scene.yaxis.titlefont.family = matlab2plotlyfont(axisData.YLabel.FontName);
    scene.zaxis.titlefont.family = matlab2plotlyfont(axisData.ZLabel.FontName);

    %-tick labels-%
    xTick = axisData.XTick;
    if isduration(xTick) || isdatetime(xTick)
        xTickChar = char(xTick);
        xTickLabel = axisData.XTickLabel;

        for n = 1:length(xTickLabel)
            for m = 1:size(xTickChar, 1)
                if ~isempty(strfind(string(xTickChar(m, :)), xTickLabel{n}))
                    idx(n) = m;
                end
            end
        end

        xTick = datenum(xTick(idx));
    end

    yTick = axisData.YTick;
    if isduration(yTick) || isdatetime(yTick)
        yTickChar = char(yTick);
        yTickLabel = axisData.YTickLabel;

        for n = 1:length(yTickLabel)
            for m = 1:size(yTickChar, 1)
                if ~isempty(strfind(string(yTickChar(m, :)), yTickLabel{n}))
                    idx(n) = m;
                end
            end
        end

        yTick = datenum(yTick(idx));
    end


    zTick = axisData.ZTick;
    if isduration(zTick) || isdatetime(zTick)
        zTickChar = char(zTick);
        zTickLabel = axisData.ZTickLabel;

        for n = 1:length(zTickLabel)
            for m = 1:size(zTickChar, 1)
                if ~isempty(strfind(string(zTickChar(m, :)), zTickLabel{n}))
                    idx(n) = m;
                end
            end
        end

        zTick = datenum(zTick(idx));
    end

    scene.xaxis.tickvals = xTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.yaxis.tickvals = yTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.zaxis.tickvals = zTick;
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
    if strcmp(axisData.XGrid, 'off'), scene.xaxis.showgrid = false; end
    if strcmp(axisData.YGrid, 'off'), scene.yaxis.showgrid = false; end
    if strcmp(axisData.ZGrid, 'off'), scene.zaxis.showgrid = false; end

    %-------------------------------------------------------------------------%

    %-SET SCENE TO LAYOUT-%
    obj.layout = setfield(obj.layout, sprintf('scene%d', xSource), scene);

    %-------------------------------------------------------------------------%
end
function data = updateStem(obj, dataIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    stem_data = obj.State.Plot(dataIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-get coordinate x,y,z data-%
    xdata = get(stem_data, 'XData');
    ydata = get(stem_data, 'YData');
    zdata = get(stem_data, 'ZData');
    npoints = length(xdata);

    %-check if stem-%
    isstem = ~isempty(zdata);

    %-SCENE-%
    if isstem
        scene = obj.layout.(sprintf("scene%d", xsource));
    else
        xaxis = obj.layout.(sprintf("xaxis%d", xsource));
        yaxis = obj.layout.(sprintf("yaxis%d", xsource));
    end

    %-scatter3d scene-%
    if isstem
        data.scene = sprintf("scene%d", xsource);
    else
        data.xaxis = sprintf("x%d", xsource);
        data.yaxis = sprintf("y%d", xsource);
    end

    %-scatter3d type-%
    if isstem
        data.type = "scatter3d";
    else
        data.type = "scatter";
    end

    data.visible = strcmp(get(stem_data, 'Visible'), "on");
    data.name = get(stem_data, 'DisplayName');
    data.mode = "lines+markers";

    if isa(xdata, "datetime")
        xdata = datenum(xdata);
    end
    if isa(ydata, "datetime")
        ydata = datenum(ydata);
    end

    %-allocated space for extended data-%
    xdata_extended = NaN(3*npoints, 1);
    ydata_extended = NaN(3*npoints, 1);

    % Create indices for extended data
    idx1 = 3*(1:npoints) - 2; % 3n-2 positions
    idx2 = 3*(1:npoints) - 1; % 3n-1 positions
    idx3 = 3*(1:npoints); % 3n positions

    xdata_extended(idx1) = xdata;
    xdata_extended(idx2) = xdata;

    if isstem
        ydata_extended(idx1) = ydata;
    else
        ydata_extended(idx1) = 0;
    end
    ydata_extended(idx2) = ydata;

    if isstem
        zdata_extended = NaN(3*npoints, 1);
        zdata_extended(idx1) = 0;
        zdata_extended(idx2) = zdata;
    end


    data.line = extractLineLine(stem_data);
    data.marker = extractLineMarker(stem_data);

    if isstem
        %-fix marker symbol-%
        symbol = data.marker.symbol;

        if any(cellfun(@(p) ~isempty(strfind(lower(symbol), p)), {'asterisk-open', 'cross-thin-open'}))
            data.marker.symbol = "cross";
        end

        data.marker.size = data.marker.size * 0.6;

        %-fix dash line-%
        if strcmpi(data.line.dash, "dash")
            data.line.dash = "dot";
        end
    end

    %-hide every other marker-%
    markercolor = cell(3*npoints,1);
    linecolor = cell(3*npoints,1);
    hidecolor = "rgba(0,0,0,0)";

    linecolor(idx1) = {hidecolor};
    markercolor(idx1) = {hidecolor};

    try
        linecolor(idx2) = {data.marker.line.color};
        markercolor(idx2) = {data.marker.color};
    catch
        linecolor(idx2) = {data.marker.color};
        markercolor(idx2) = {hidecolor};
    end

    linecolor(idx3) = {hidecolor};
    markercolor(idx3) = {hidecolor};

    %-add new marker/line colors-%
    data.marker.color = markercolor;
    data.marker.line.color = linecolor;

    data.marker.line.width = data.marker.line.width * 2;
    data.line.width = data.line.width * 2;

    %-set x y z data-%
    data.x = xdata_extended;
    data.y = ydata_extended;

    if isstem
        data.z = zdata_extended;
    end

    %-SETTING SCENE-%
    if isstem
        asr = obj.PlotOptions.AspectRatio;

        if ~isempty(asr)
            if ischar(asr)
                scene.aspectmode = asr;
            elseif isvector(asr) && length(asr) == 3
                xar = asr(1);
                yar = asr(2);
                zar = asr(3);
            end
        else
            %-define as default-%
            xyar = max([max(xdata(:)), max(ydata(:))]);
            xar = xyar;
            yar = xyar;
            zar = 0.7*xyar;
        end

        scene.aspectratio.x = xar;
        scene.aspectratio.y = yar;
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
            xey = -xar;
            if xey > 0
                xfac = 0.2;
            else
                xfac = -0.2;
            end
            yey = -yar;
            if yey > 0
                yfac = -0.2;
            else
                yfac = 0.2;
            end

            if zar > 0
                zfac = 0.2;
            else
                zfac = -0.2;
            end

            scene.camera.eye.x = xey + xfac*xey;
            scene.camera.eye.y = yey + yfac*yey;
            scene.camera.eye.z = zar + zfac*zar;
        end

        %-zerolines hidden-%
        scene.xaxis.zeroline = false;
        scene.yaxis.zeroline = false;
        scene.zaxis.zeroline = false;

        scene.xaxis.linecolor = "rgba(0,0,0,0.8)";
        scene.yaxis.linecolor = "rgba(0,0,0,0.8)";
        scene.zaxis.linecolor = "rgba(0,0,0,0.5)";

        scene.xaxis.ticklen = 5;
        scene.yaxis.ticklen = 5;
        scene.zaxis.ticklen = 5;

        scene.xaxis.tickcolor = "rgba(0,0,0,0.8)";
        scene.yaxis.tickcolor = "rgba(0,0,0,0.8)";
        scene.zaxis.tickcolor = "rgba(0,0,0,0.8)";

        scene.xaxis.range = get(get(stem_data, 'Parent'), 'XLim');
        scene.yaxis.range = get(get(stem_data, 'Parent'), 'YLim');
        scene.zaxis.range = get(get(stem_data, 'Parent'), 'ZLim');

        scene.xaxis.tickvals = get(get(stem_data, 'Parent'), 'XTick');
        scene.yaxis.tickvals = get(get(stem_data, 'Parent'), 'YTick');
        scene.zaxis.tickvals = get(get(stem_data, 'Parent'), 'ZTick');

        scene.xaxis.title = get(get(get(stem_data, 'Parent'), 'XLabel'), 'String');
        scene.yaxis.title = get(get(get(stem_data, 'Parent'), 'YLabel'), 'String');
        scene.zaxis.title = get(get(get(stem_data, 'Parent'), 'ZLabel'), 'String');

        obj.layout.(sprintf("scene%d", xsource)) = scene;
    else
        yaxis.zeroline = true;

        xaxis.linecolor = "rgba(0,0,0,0.4)";
        yaxis.linecolor = "rgba(0,0,0,0.4)";

        xaxis.tickcolor = "rgba(0,0,0,0.4)";
        yaxis.tickcolor = "rgba(0,0,0,0.4)";

        xaxis.tickvals = get(get(stem_data, 'Parent'), 'XTick');
        yaxis.tickvals = get(get(stem_data, 'Parent'), 'YTick');

        xaxis.title = get(get(get(stem_data, 'Parent'), 'XLabel'), 'String');
        yaxis.title = get(get(get(stem_data, 'Parent'), 'YLabel'), 'String');

        obj.layout.(sprintf("xaxis%d", xsource)) = xaxis;
        obj.layout.(sprintf("yaxis%d", ysource)) = yaxis;
    end
end

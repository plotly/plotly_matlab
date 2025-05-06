function obj = updateConeplot(obj, coneIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(coneIndex).AssociatedAxis);

    %-CONE DATA STRUCTURE- %
    cone_data = obj.State.Plot(coneIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SCENE DATA-%
    scene = obj.layout.("scene" + xsource);

    %-cone type-%
    obj.data{coneIndex}.type = 'cone';

    %-get plot data-%
    xdata = cone_data.XData;
    ydata = cone_data.YData;
    zdata = cone_data.ZData;

    %-reformat data-%
    nfaces = size(xdata, 2);
    ref = xdata(end,1);

    for n=1:nfaces
        if ref ~= xdata(end, n)
            step1 = n-1;
            break
        end
    end

    ref = xdata(1,step1);

    for n=step1:nfaces
        if ref ~= xdata(1, n)
            step2 = n-1;
            break
        end
    end

    x = []; y = []; z = [];
    u = []; v = []; w = [];

    for c = 1:step2:nfaces
        xhead = xdata(end,c);
        yhead = ydata(end,c);
        zhead = zdata(end,c);

        xtail = mean(xdata(2,c:c+step1-1));
        ytail = mean(ydata(2,c:c+step1-1));
        ztail = mean(zdata(2,c:c+step1-1));

        u = [u; xhead - xtail];
        v = [v; yhead - ytail];
        w = [w; zhead - ztail];

        x = [x; 0.5*(xtail+xhead)];
        y = [y; 0.5*(ytail+yhead)];
        z = [z; 0.5*(ztail+zhead)];
    end

    %-set plot data-%
    obj.data{coneIndex}.x = x;
    obj.data{coneIndex}.y = y;
    obj.data{coneIndex}.z = z;
    obj.data{coneIndex}.u = u;
    obj.data{coneIndex}.v = v;
    obj.data{coneIndex}.w = w;

    %-set cone color-%
    obj.data{coneIndex}.colorscale{1} = ...
            {0, getStringColor(round(255*cone_data.EdgeColor))};
    obj.data{coneIndex}.colorscale{2} = ...
            {1, getStringColor(round(255*cone_data.EdgeColor))};

    %-plot setting-%
    obj.data{coneIndex}.showscale = false;
    obj.data{coneIndex}.sizemode = 'scaled';
    obj.data{coneIndex}.sizeref = 1.5;

    %-scene axis-%
    scene.xaxis.tickvals = cone_data.Parent.XTick;
    scene.xaxis.ticktext = cone_data.Parent.XTickLabel;
    scene.yaxis.tickvals = cone_data.Parent.YTick;
    scene.yaxis.ticktext = cone_data.Parent.YTickLabel;
    scene.zaxis.range = cone_data.Parent.ZLim;
    scene.zaxis.nticks = 10;

    %-aspect ratio-%
    ar = obj.PlotOptions.AspectRatio;

    if ~isempty(ar)
        if ischar(ar)
            scene.aspectmode = ar;
        elseif isvector(ar) && length(ar) == 3
            xar = ar(1);
            yar = ar(2);
            zar = ar(3);
        end
    else
        %-define as default-%
        xar = max(xdata(:));
        yar = max(ydata(:));
        xyar = min([xar, yar]);
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

        scene.camera.eye.x = xey + xfac*xey;
        scene.camera.eye.y = yey + yfac*yey;
        scene.camera.eye.z = zar + zfac*zar;
    end

    %-set scene to layout-%
    obj.layout.("scene" + xsource) = scene;
    obj.data{coneIndex}.scene = "scene" + xsource;
end

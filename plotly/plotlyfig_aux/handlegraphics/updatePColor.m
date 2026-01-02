function obj = updatePColor(obj, patchIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

    %-PCOLOR DATA STRUCTURE- %
    pcolor_data = obj.State.Plot(patchIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-pcolor xaxis and yaxis-%
    obj.data{patchIndex}.xaxis = "x" + xsource;
    obj.data{patchIndex}.yaxis = "y" + ysource;

    %-plot type: surface-%
    obj.data{patchIndex}.type = 'surface';

    %-format data-%
    XData = pcolor_data.XData;
    YData = pcolor_data.YData;
    ZData = pcolor_data.ZData;
    CData = pcolor_data.CData;
    usegrid = false;

    if isvector(XData)
        usegrid = true;
        [XData, YData] = meshgrid(XData, YData);
    end

    sizes = [(size(XData, 1)-1)*2, (size(XData, 2)-1)*2];
    xdata = zeros(sizes);
    ydata = zeros(sizes);
    zdata = zeros(sizes);
    cdata = zeros(sizes);

    for n = 1:size(XData, 2)-1
        for m = 1:size(XData, 1)-1
            % get indices
            n1 = 2*(n-1)+1; m1 = 2*(m-1)+1;

            % get surface mesh
            xdata(m1:m1+1,n1:n1+1) = XData(m:m+1, n:n+1);
            ydata(m1:m1+1,n1:n1+1) = YData(m:m+1, n:n+1);
            zdata(m1:m1+1,n1:n1+1) = ZData(m:m+1, n:n+1);
            cdata(m1:m1+1,n1:n1+1) = ones(2,2)*CData(m, n);
        end
    end

    %-x,y,z-data-%
    obj.data{patchIndex}.x = xdata;
    obj.data{patchIndex}.y = ydata;
    obj.data{patchIndex}.z = zdata;

    %-coloring-%
    cmap = figure_data.Colormap;
    len = length(cmap)-1;

    for c = 1:length(cmap)
        col = round(255 * cmap(c, :));
        obj.data{patchIndex}.colorscale{c} = ...
                {(c-1)/len, getStringColor(col)};
    end

    obj.data{patchIndex}.surfacecolor = cdata;
    obj.data{patchIndex}.showscale = false;
    obj.data{patchIndex}.cmin = min(CData(:));
    obj.data{patchIndex}.cmax = max(CData(:));

    %-setting grid mesh-%
    if usegrid
        % x-direction
        xmin = min(XData(:));
        xmax = max(XData(:));
        xsize = (xmax - xmin) / (size(XData, 2) - 1);
        obj.data{patchIndex}.contours.x.start = xmin;
        obj.data{patchIndex}.contours.x.end = xmax;
        obj.data{patchIndex}.contours.x.size = xsize;
        obj.data{patchIndex}.contours.x.show = true;
        obj.data{patchIndex}.contours.x.color = 'black';
        % y-direction
        ymin = min(YData(:));
        ymax = max(YData(:));
        ysize = (ymax - ymin) / (size(YData, 2)-1);
        obj.data{patchIndex}.contours.y.start = ymin;
        obj.data{patchIndex}.contours.y.end = ymax;
        obj.data{patchIndex}.contours.y.size = ysize;
        obj.data{patchIndex}.contours.y.show = true;
        obj.data{patchIndex}.contours.y.color = 'black';
    end

    %-aspectratio-%
    obj.layout.scene.aspectratio.x = 12;
    obj.layout.scene.aspectratio.y = 10;
    obj.layout.scene.aspectratio.z = 0.0001;

    %-camera.eye-%
    obj.layout.scene.camera.eye.x = 0;
    obj.layout.scene.camera.eye.y = -0.5;
    obj.layout.scene.camera.eye.z = 14;

    %-hide axis-x-%
    obj.layout.scene.xaxis.showticklabels = true;
    obj.layout.scene.xaxis.zeroline = false;
    obj.layout.scene.xaxis.showgrid = false;
    obj.layout.scene.xaxis.title = '';

    %-hide axis-y-%
    obj.layout.scene.yaxis.zeroline = false;
    obj.layout.scene.yaxis.showgrid = false;
    obj.layout.scene.yaxis.showticklabels = true;
    obj.layout.scene.yaxis.title = '';

    %-hide axis-z-%
    obj.layout.scene.zaxis.title = '';
    obj.layout.scene.zaxis.autotick = false;
    obj.layout.scene.zaxis.zeroline = false;
    obj.layout.scene.zaxis.showline = false;
    obj.layout.scene.zaxis.showticklabels = false;
    obj.layout.scene.zaxis.showgrid = false;

    switch pcolor_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{patchIndex}.showlegend = true;
        case "off"
            obj.data{patchIndex}.showlegend = false;
    end
end

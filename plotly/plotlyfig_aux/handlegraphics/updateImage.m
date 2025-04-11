function data = updateImage(obj, imageIndex)
    % HEATMAPS
    % z: ...[DONE]
    % x: ...[DONE]
    % y: ...[DONE]
    % name: ...[DONE]
    % zauto: ...[DONE]
    % zmin: ...[DONE]
    % zmax: ...[DONE]
    % colorscale: ...[DONE]
    % reversescale: ...[DONE]
    % showscale: ...[DONE]
    % colorbar: ...[HANDLED BY COLORBAR]
    % zsmooth: ...[NOT SUPPORTED BY MATLAB]
    % opacity: ---[TODO]
    % xaxis: ...[DONE]
    % yaxis: ...[DONE]
    % showlegend: ...[DONE]
    % stream: ...[HANDLED BY PLOTLYSTREAM]
    % visible: ...[DONE]
    % x0: ...[NOT SUPPORTED IN MATLAB]
    % dx: ...[NOT SUPPORTED IN MATLAB]
    % y0: ...[NOT SUPPORTED IN MATLAB]
    % dy: ...[NOT SUPPORTED IN MATLAB]
    % xtype: ...[NOT SUPPORTED IN MATLAB]
    % ytype: ...[NOT SUPPORTED IN MATLAB]
    % type: ...[DONE]

    %-FIGURE STRUCTURE-%
    figure_data = obj.State.Figure.Handle;

    %-AXIS STRUCTURE-%
    axis_data = obj.State.Plot(imageIndex).AssociatedAxis;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(axis_data);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-IMAGE DATA STRUCTURE- %
    image_data = obj.State.Plot(imageIndex).Handle;

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;
    data.type = 'heatmap';

    x = image_data.XData;
    cdata = image_data.CData;
    if (size(image_data.XData,2) == 2)
        data.x = linspace(x(1), x(2), size(cdata,2));
    else
        data.x = image_data.XData;
    end

    y = image_data.YData;
    if (size(image_data.YData,2) == 2)
        data.y = linspace(y(1), y(2), size(cdata,1));
    else
        data.y = y;
    end

    isrgbimg = (size(image_data.CData,3) > 1);
    if isrgbimg
        [IND,colormap] = rgb2ind(cdata, 256);
        data.z = IND;
    else
        data.z = cdata;
    end

    if isprop(image_data, "DisplayName")
        data.name = image_data.DisplayName;
    else
        data.name = '';
    end

    data.opacity = image_data.AlphaData;
    data.visible = image_data.Visible == "on";
    data.showscale = false;
    data.zauto = false;
    data.zmin = axis_data.CLim(1);

    if lower(image_data.CDataMapping) ~= "direct"
        data.zmax = axis_data.CLim(2);
    else
        data.zmax = 255;
    end

    %-COLORSCALE (ASSUMES IMAGE CDATAMAP IS 'SCALED')-%

    if ~isrgbimg
        colormap = figure_data.Colormap;
    end

    len = length(colormap) - 1;

    for c = 1:size(colormap, 1)
        col = round(255*(colormap(c,:)));
        data.colorscale{c} = {(c-1)/len, getStringColor(col)};
    end

    try
        switch image_data.Annotation.LegendInformation.IconDisplayStyle
            case "on"
                data.showlegend = true;
            case "off"
                data.showlegend = false;
        end
    catch
        %TODO to future
    end
end

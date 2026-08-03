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

    data.xaxis = sprintf("x%d", xsource);
    data.yaxis = sprintf("y%d", ysource);
    data.type = 'heatmap';

    x = get(image_data, 'XData');
    cdata = get(image_data, 'CData');
    if (size(get(image_data, 'XData'),2) == 2)
        data.x = linspace(x(1), x(2), size(cdata,2));
    else
        data.x = get(image_data, 'XData');
    end

    y = get(image_data, 'YData');
    if (size(get(image_data, 'YData'),2) == 2)
        data.y = linspace(y(1), y(2), size(cdata,1));
    else
        data.y = y;
    end

    isrgbimg = (size(get(image_data, 'CData'),3) > 1);
    if isrgbimg
        [IND,colormap] = rgb2ind(cdata, 256);
        data.z = IND;
    else
        data.z = cdata;
    end

    if isprop(image_data, "DisplayName")
        data.name = get(image_data, 'DisplayName');
    else
        data.name = '';
    end

    data.opacity = get(image_data, 'AlphaData');
    data.visible = strcmp(get(image_data, 'Visible'), "on");
    data.showscale = false;
    data.zauto = false;
    tmpCLim = get(axis_data, 'CLim');
    data.zmin = tmpCLim(1);

    if ~strcmpi(get(image_data, 'CDataMapping'), "direct")
        data.zmax = tmpCLim(2);
    else
        data.zmax = 255;
    end

    %-COLORSCALE (ASSUMES IMAGE CDATAMAP IS 'SCALED')-%

    if ~isrgbimg
        colormap = get(figure_data, 'Colormap');
    end

    len = length(colormap) - 1;

    for c = 1:size(colormap, 1)
        col = round(255*(colormap(c,:)));
        data.colorscale{c} = {(c-1)/len, getStringColor(col)};
    end

    data.showlegend = getShowLegend(image_data);
end

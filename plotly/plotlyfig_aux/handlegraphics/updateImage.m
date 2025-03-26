function obj = updateImage(obj, imageIndex)
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
    axIndex = obj.getAxisIndex(obj.State.Plot(imageIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-IMAGE DATA STRUCTURE- %
    image_data = obj.State.Plot(imageIndex).Handle;

    %-AXIS DATA-%
    xaxis = obj.layout.("xaxis" + xsource);
    yaxis = obj.layout.("yaxis" + ysource);

    %---------------------------------------------------------------------%

    obj.data{imageIndex}.xaxis = "x" + xsource;
    obj.data{imageIndex}.yaxis = "y" + ysource;
    obj.data{imageIndex}.type = 'heatmap';

    %---------------------------------------------------------------------%

    %-image x-%
    x = image_data.XData;
    cdata = image_data.CData;

    if (size(image_data.XData,2) == 2)
        obj.data{imageIndex}.x = linspace(x(1), x(2), size(cdata,2));
    else
        obj.data{imageIndex}.x = image_data.XData;
    end

    %---------------------------------------------------------------------%

    %-image y-%
    y = image_data.YData;

    if (size(image_data.YData,2) == 2)
        obj.data{imageIndex}.y = linspace(y(1), y(2), size(cdata,1));
    else
        obj.data{imageIndex}.y = y;
    end

    %---------------------------------------------------------------------%

    %-image z-%
    isrgbimg = (size(image_data.CData,3) > 1);

    if isrgbimg
        [IND,colormap] = rgb2ind(cdata, 256);
        obj.data{imageIndex}.z = IND;
    else
        obj.data{imageIndex}.z = cdata;
    end

    %---------------------------------------------------------------------%

    %-image name-%
    try
        obj.data{imageIndex}.name = image_data.DisplayName;
    catch
        obj.data{imageIndex}.name = '';
    end

    %---------------------------------------------------------------------%

    obj.data{imageIndex}.opacity = image_data.AlphaData;
    obj.data{imageIndex}.visible = strcmp(image_data.Visible, 'on');
    obj.data{imageIndex}.showscale = false;
    obj.data{imageIndex}.zauto = false;
    obj.data{imageIndex}.zmin = axis_data.CLim(1);

    %---------------------------------------------------------------------%

    %-image zmax-%
    if ~strcmpi(image_data.CDataMapping, 'direct')
        obj.data{imageIndex}.zmax = axis_data.CLim(2);
    else
        obj.data{imageIndex}.zmax = 255;
    end

    %---------------------------------------------------------------------%

    %-COLORSCALE (ASSUMES IMAGE CDATAMAP IS 'SCALED')-%

    %-image colorscale-%

    if ~isrgbimg
        colormap = figure_data.Colormap;
    end

    len = length(colormap) - 1;

    for c = 1:size(colormap, 1)
        col = round(255*(colormap(c,:)));
        obj.data{imageIndex}.colorscale{c} = ...
                {(c-1)/len, sprintf("rgb(%d,%d,%d)", col)};
    end

    %---------------------------------------------------------------------%

    %-image showlegend-%
    try
        leg = image_data.Annotation;
        legInfo = leg.LegendInformation;
        switch legInfo.IconDisplayStyle
            case 'on'
                showleg = true;
            case 'off'
                showleg = false;
        end
        obj.data{imageIndex}.showlegend = showleg;
    catch
        %TODO to future
    end
end

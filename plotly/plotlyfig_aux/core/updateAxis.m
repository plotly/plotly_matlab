function obj = updateAxis(obj,axIndex)
    %----UPDATE AXIS DATA/LAYOUT----%

    % title: ...[DONE]
    % titlefont:...[DONE]
    % range:...[DONE]
    % domain:...[DONE]
    % type:...[DONE]
    % rangemode:...[NOT SUPPORTED IN MATLAB]
    % autorange:...[DONE]
    % showgrid:...[DONE]
    % zeroline:...[DONE]
    % showline:...[DONE
    % autotick:...[DONE]
    % nticks:...[DONE]
    % ticks:...[DONE]
    % showticklabels:...[DONE]
    % tick0:...[DONE]
    % dtick:...[DONE]
    % ticklen:...[DONE]
    % tickwidth:...[DONE]
    % tickcolor:...[DONE]
    % tickangle:...[NOT SUPPORTED IN MATLAB]
    % tickfont:...[DONE]
    % tickfont.family...[DONE]
    % tickfont.size...[DONE]
    % tickfont.color...[DONE]
    % tickfont.outlinecolor...[NOT SUPPORTED IN MATLAB]
    % exponentformat:...[DONE]
    % showexponent:...[NOT SUPPORTED IN MATLAB]
    % mirror:...[DONE]
    % gridcolor:...[DONE]
    % gridwidth:...[DONE]
    % zerolinecolor:...[NOT SUPPORTED IN MATLAB]
    % zerolinewidth:...[NOT SUPPORTED IN MATLAB]
    % linecolor:...[DONE]
    % linewidth:...[DONE]
    % anchor:...[DONE]
    % overlaying:...[DONE]
    % side:...[DONE]
    % position:...[NOT SUPPORTED IN MATLAB]

    %-AXIS DATA STRUCTURE-%
    axisData = obj.State.Axis(axIndex).Handle;

    %-STANDARDIZE UNITS-%
    axisUnits = axisData.Units;
    axisData.Units = 'normalized';

    if isprop(axisData, "FontUnits")
        fontUnits = axisData.FontUnits;
        axisData.FontUnits = 'points';
    end

    %-check if headmap axis-%
    isHeatmapAxis = axisData.Type == "heatmap";
    obj.PlotOptions.is_headmap_axis = isHeatmapAxis;

    %-check if geo-axis-%
    isGeoaxis = isfield(axisData, 'Type') ...
            && strcmpi(axisData.Type, 'geoaxes');
    obj.PlotlyDefaults.isGeoaxis = isGeoaxis;

    if isHeatmapAxis
        xaxis = extractHeatmapAxisData(obj,axisData, 'X');
        xExponentFormat = 0;
    else
        [xaxis, xExponentFormat] = extractAxisData(obj,axisData, 'X');
    end
    if isHeatmapAxis
        yaxis = extractHeatmapAxisData(obj,axisData, 'Y');
        yExponentFormat = 0;
    else
        [yaxis, yExponentFormat] = extractAxisData(obj,axisData, 'Y');
    end

    axisPos = axisData.Position .* obj.PlotOptions.DomainFactor;
    if obj.PlotOptions.AxisEqual
        axisPos(3:4) = min(axisPos(3:4));
    end

    xaxis.domain = min([axisPos(1) sum(axisPos([1,3]))], 1);
    scene.domain.x = xaxis.domain;
    yaxis.domain = min([axisPos(2) sum(axisPos([2,4]))], 1);
    scene.domain.y = yaxis.domain;

    %-get source axis-%
    [xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj,axIndex);

    %-set exponent format-%
    anIndex = obj.State.Figure.NumTexts;

    if yExponentFormat ~= 0
        anIndex = anIndex + 1;
        exponentText = sprintf('x10^%d', yExponentFormat);

        obj.layout.annotations{anIndex}.text = exponentText;
        obj.layout.annotations{anIndex}.xref = "x" + xsource;
        obj.layout.annotations{anIndex}.yref = "y" + ysource;
        obj.layout.annotations{anIndex}.xanchor = 'left';
        obj.layout.annotations{anIndex}.yanchor = 'bottom';
        obj.layout.annotations{anIndex}.font.size = yaxis.tickfont.size;
        obj.layout.annotations{anIndex}.font.color = yaxis.tickfont.color;
        obj.layout.annotations{anIndex}.font.family = yaxis.tickfont.family;
        obj.layout.annotations{anIndex}.showarrow = false;

        if isfield(xaxis, 'range') && isfield(yaxis, 'range')
            obj.layout.annotations{anIndex}.x = min(xaxis.range);
            obj.layout.annotations{anIndex}.y = max(yaxis.range);
        end
    end

    if xExponentFormat ~= 0
        anIndex = anIndex + 1;
        exponentText = sprintf('x10^%d', xExponentFormat);

        obj.layout.annotations{anIndex}.text = exponentText;
        obj.layout.annotations{anIndex}.xref = "x" + xsource;
        obj.layout.annotations{anIndex}.yref = "y" + ysource;
        obj.layout.annotations{anIndex}.xanchor = 'left';
        obj.layout.annotations{anIndex}.yanchor = 'bottom';
        obj.layout.annotations{anIndex}.font.size = xaxis.tickfont.size;
        obj.layout.annotations{anIndex}.font.color = xaxis.tickfont.color;
        obj.layout.annotations{anIndex}.font.family = xaxis.tickfont.family;
        obj.layout.annotations{anIndex}.showarrow = false;

        if isfield(xaxis, 'range') && isfield(yaxis, 'range')
            obj.layout.annotations{anIndex}.x = max(xaxis.range);
            obj.layout.annotations{anIndex}.y = min(yaxis.range);
        end
    end

    xaxis.anchor = "y" + ysource;
    yaxis.anchor = "x" + xsource;

    if xoverlay
        xaxis.overlaying = "x" + xoverlay;
    end
    if yoverlay
        yaxis.overlaying = "y" + yoverlay;
    end

    % update the layout field (do not overwrite source)
    if xsource == axIndex
        obj.layout.("xaxis" + xsource) = xaxis;
        obj.layout.("scene" + xsource) = scene;
    end

    % update the layout field (do not overwrite source)
    if ysource == axIndex
        obj.layout.("yaxis" + ysource) = yaxis;
    end

    %-REVERT UNITS-%
    axisData.Units = axisUnits;

    if isprop(axisData, "FontUnits")
        axisData.FontUnits = fontUnits;
    end
end

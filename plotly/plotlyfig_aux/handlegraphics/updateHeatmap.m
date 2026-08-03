function data = updateHeatmap(obj,heatIndex)
    %-HEATMAP DATA STRUCTURE- %
    heat_data = obj.State.Plot(heatIndex).Handle;
    axIndex = obj.getAxisIndex(obj.State.Plot(heatIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    data.xaxis = sprintf("x%d", xSource);
    data.yaxis = sprintf("y%d", ySource);

    data.type = "heatmap";

    tmpColorDisplayData = get(heat_data, 'ColorDisplayData');
    cdata = tmpColorDisplayData(end:-1:1, :);

    data.x = get(heat_data, 'XDisplayData');
    tmpYDisplayData = get(heat_data, 'YDisplayData');
    data.y = tmpYDisplayData(end:-1:1, :);
    data.z = mat2nestCell(cdata);
    tmpColorLimits = get(heat_data, 'ColorLimits');
    data.zmin = tmpColorLimits(1);
    data.zmax = tmpColorLimits(2);
    data.connectgaps = false;
    data.hoverongaps = false;

    cmap = get(heat_data, 'Colormap');
    len = length(cmap)-1;
    for c = 1:length(cmap)
        col = round(255*cmap(c, :));
        data.colorscale{c} = {(c-1)/len, getStringColor(col)};
    end

    data.hoverinfo = "text";
    tmpColorData = get(heat_data, 'ColorData');
    data.text = mat2nestCell(tmpColorData(end:-1:1, :));
    data.hoverlabel.bgcolor = "white";

    data.showscale = false;
    if strcmpi(get(heat_data, 'ColorbarVisible'), "on")
        xaxis = obj.layout.(sprintf("xaxis%d", xSource));
        yaxis = obj.layout.(sprintf("yaxis%d", ySource));
        data.showscale = true;
        data.colorbar = struct( ...
            "x", xaxis.domain(2), ...
            "y", yaxis.domain(1), ...
            "xanchor", "left", ...
            "yanchor", "bottom", ...
            "thicknessmode", "fraction", ...
            "thickness", rangeLength(xaxis.domain)/10, ...
            "lenmode", "fraction", ...
            "len", rangeLength(yaxis.domain), ...
            "ypad", obj.PlotlyDefaults.MarginPad, ...
            "xpad", 10, ...
            "outlinecolor", "rgb(150,150,150)" ...
        );
    end

    data.visible = strcmp(get(heat_data, 'Visible'), "on");
    data.opacity = 0.95;

    %-setting annotation text-%
    m = size(cdata, 2);
    n = size(cdata, 1);
    annotations = cell(1,m*n);

    % Set font properties once for all annotations
    obj.layout.font = struct( ...
        size = get(heat_data, 'FontSize')*1.15, ...
        family = matlab2plotlyfont(get(heat_data, 'FontName')) ...
    );

    for i = 1:m
        for j = 1:n
            ann.text = num2str(round(cdata(j,i), 2));
            ann.x = i-1;
            ann.y = j-1;
            ann.showarrow = false;
            col = [255 255 255];
            if isfinite(cdata(j,i))
                ratio = (cdata(j,i) - data.zmin) / (data.zmax - data.zmin);
                colorIndex = 1 + clip(round(ratio*len), 0, len);
                c = 255*cmap(colorIndex,:);
                luminance = [0.299 0.587 0.114] * c'; % ITU-R BT.601 luminance standard
                if luminance > 128
                    col = [0 0 0];
                end
            end
            ann.font.color = getStringColor(col);
            annotations{(i-1)*n+j} = ann;
        end
    end

    obj.layout.annotations = annotations;

    %-set background color if any NaN in cdata-%
    if any(isnan(cdata(:)))
        obj.layout.plot_bgcolor = "rgb(40,40,40)";
        data.opacity = 1;
    end
end

function out = mat2nestCell(mat)
    % Convert a numeric matrix to a nested cell array (one cell per row)
    % so that m2json serializes it as a 2D JSON array regardless of size.
    %   mat2nestCell([1 2; 3 4]) => {{1,2}, {3,4}} => [[1,2],[3,4]]
    %   mat2nestCell([5])         => {{5}}          => [[5]]
    nRows = size(mat,1);
    out = cell(1,nRows);
    for r = 1:nRows
        out{r} = num2cell(mat(r,:));
    end
end

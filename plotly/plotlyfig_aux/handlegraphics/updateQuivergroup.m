function obj = updateQuivergroup(obj, quiverIndex)
    %-store original stair handle-%
    quiver_group = obj.State.Plot(quiverIndex).Handle;

    %-get children-%
    quiver_child = get(quiver_group, 'Children');

    xdata = [];
    ydata = [];
    zdata = [];
    barbX = [];
    barbY = [];
    barbZ = [];
    hasBarb = false;
    %-process visible children (shafts + heads), skipping data-holder
    %-children that have no line or marker style-%
    for n = 1:numel(quiver_child)
        qt = quiver_child(n);
        if strcmp(get(qt, 'LineStyle'), 'none') ...
                && strcmp(get(qt, 'Marker'), 'none')
            continue
        end
        %-update line -%
        obj.State.Plot(quiverIndex).Handle = qt;
        obj.data{quiverIndex} = updateLineseries(obj,quiverIndex);

        xd = obj.data{quiverIndex}.x;
        nans = isnan(xd);
        if numel(xd) > 1 && any(nans)
            seglen = max(diff([0 find(nans) numel(xd)+1]) - 1);
        else
            seglen = numel(xd);
        end

        if seglen == 2
            xdata = [xdata xd];
            ydata = [ydata obj.data{quiverIndex}.y];
            if isfield(obj.data{quiverIndex}, 'z')
                zdata = [zdata obj.data{quiverIndex}.z];
            end
        else
            hasBarb = true;
            barbX = [barbX xd];
            barbY = [barbY obj.data{quiverIndex}.y];
            if isfield(obj.data{quiverIndex}, 'z')
                barbZ = [barbZ obj.data{quiverIndex}.z];
            end
        end
    end

    % store the final data vector
    obj.data{quiverIndex}.x = xdata;
    obj.data{quiverIndex}.y = ydata;
    if ~isempty(zdata)
        obj.data{quiverIndex}.z = zdata;
    end

    if ~isempty(zdata) && isfield(obj.data{quiverIndex}, 'scene')
        scn = obj.data{quiverIndex}.scene;
        obj.layout.(scn).xaxis.showspikes = false;
        obj.layout.(scn).yaxis.showspikes = false;
        obj.layout.(scn).zaxis.showspikes = false;
    end

    %-collect tail positions and hovertext-%
    is3d = ~isempty(zdata);
    nPts = numel(xdata);
    tailX = [];
    tailY = [];
    tailZ = [];
    tailHt = {};
    m = 1;
    while m <= nPts
        if isnan(xdata(m))
            m = m + 1;
        elseif m + 1 <= nPts && ~isnan(xdata(m+1))
            tailX(end+1) = xdata(m);
            tailY(end+1) = ydata(m);
            if is3d
                tailZ(end+1) = zdata(m);
                label = sprintf("(%.2f, %.2f, %.2f)<br>(%.2f, %.2f, %.2f)", ...
                    xdata(m), ydata(m), zdata(m), ...
                    xdata(m+1)-xdata(m), ydata(m+1)-ydata(m), zdata(m+1)-zdata(m));
            else
                label = sprintf("(%.2f, %.2f)<br>(%.2f, %.2f)", ...
                    xdata(m), ydata(m), ...
                    xdata(m+1)-xdata(m), ydata(m+1)-ydata(m));
            end
            tailHt{end+1} = label;
            m = m + 2;
        else
            m = m + 1;
        end
    end

    obj.data{quiverIndex}.hoverinfo = 'skip';

    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    tailIndex = obj.PlotOptions.nPlots;

    obj.data{tailIndex}.type = obj.data{quiverIndex}.type;
    if isfield(obj.data{quiverIndex}, 'scene')
        obj.data{tailIndex}.scene = obj.data{quiverIndex}.scene;
    end
    if isfield(obj.data{quiverIndex}, 'xaxis')
        obj.data{tailIndex}.xaxis = obj.data{quiverIndex}.xaxis;
        obj.data{tailIndex}.yaxis = obj.data{quiverIndex}.yaxis;
    end
    obj.data{tailIndex}.mode = 'markers';
    obj.data{tailIndex}.visible = obj.data{quiverIndex}.visible;
    obj.data{tailIndex}.x = tailX;
    obj.data{tailIndex}.y = tailY;
    if is3d
        obj.data{tailIndex}.z = tailZ;
    end
    obj.data{tailIndex}.hovertext = tailHt;
    obj.data{tailIndex}.hoverinfo = 'text';
    obj.data{tailIndex}.marker.color = 'rgba(0,0,0,0)';
    obj.data{tailIndex}.marker.size = 6;
    obj.data{tailIndex}.showlegend = false;

    if hasBarb
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        barbIndex = obj.PlotOptions.nPlots;

        obj.data{barbIndex}.type = obj.data{quiverIndex}.type;
        if isfield(obj.data{quiverIndex}, 'scene')
            obj.data{barbIndex}.scene = obj.data{quiverIndex}.scene;
        end
        if isfield(obj.data{quiverIndex}, 'xaxis')
            obj.data{barbIndex}.xaxis = obj.data{quiverIndex}.xaxis;
            obj.data{barbIndex}.yaxis = obj.data{quiverIndex}.yaxis;
        end
        obj.data{barbIndex}.mode = 'lines';
        obj.data{barbIndex}.visible = obj.data{quiverIndex}.visible;
        if isfield(obj.data{quiverIndex}, 'line')
            obj.data{barbIndex}.line = obj.data{quiverIndex}.line;
        else
            obj.data{barbIndex}.marker = obj.data{quiverIndex}.marker;
        end
        obj.data{barbIndex}.hoverinfo = 'skip';
        obj.data{barbIndex}.showlegend = false;
        obj.data{barbIndex}.x = barbX;
        obj.data{barbIndex}.y = barbY;
        if ~isempty(barbZ)
            obj.data{barbIndex}.z = barbZ;
        end
    end

    %-revert handle-%
    obj.State.Plot(quiverIndex).Handle = quiver_group;
end

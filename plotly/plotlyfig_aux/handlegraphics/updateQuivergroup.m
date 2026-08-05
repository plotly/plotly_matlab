function obj = updateQuivergroup(obj, quiverIndex)
    %-store original stair handle-%
    quiver_group = obj.State.Plot(quiverIndex).Handle;

    %-get children-%
    quiver_child = get(quiver_group, 'Children');

    xdata = [];
    ydata = [];
    zdata = [];
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

        %update xdata and ydata
        xdata = [xdata obj.data{quiverIndex}.x];
        ydata = [ydata obj.data{quiverIndex}.y];
        if isfield(obj.data{quiverIndex}, 'z')
            zdata = [zdata obj.data{quiverIndex}.z];
        end
    end

    % store the final data vector
    obj.data{quiverIndex}.x = xdata;
    obj.data{quiverIndex}.y = ydata;
    if ~isempty(zdata)
        obj.data{quiverIndex}.z = zdata;
    end

    %-revert handle-%
    obj.State.Plot(quiverIndex).Handle = quiver_group;
end

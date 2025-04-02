function obj = updateQuivergroup(obj, quiverIndex)
    %-store original stair handle-%
    quiver_group = obj.State.Plot(quiverIndex).Handle;

    %-get children-%
    quiver_child = quiver_group.Children;

    xdata = [];
    ydata = [];
    %iterate through first two children (the vector line + arrow head)
    for n = 1:2;
        %-update line -%
        obj.State.Plot(quiverIndex).Handle = quiver_child(n);
        obj.data{quiverIndex} = updateLineseries(obj,quiverIndex);

        %update xdata and ydata
        xdata = [xdata obj.data{quiverIndex}.x];
        ydata = [ydata obj.data{quiverIndex}.y];
    end

    % store the final data vector
    obj.data{quiverIndex}.x = xdata;
    obj.data{quiverIndex}.y = ydata;

    %-revert handle-%
    obj.State.Plot(quiverIndex).Handle = quiver_group;
end

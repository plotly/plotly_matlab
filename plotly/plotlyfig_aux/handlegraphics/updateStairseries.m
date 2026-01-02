function obj = updateStairseries(obj, dataIndex)
    %-store original stair handle-%
    stair_group = obj.State.Plot(dataIndex).Handle;

    %-update line -%
    obj.State.Plot(dataIndex).Handle = stair_group.Children(1);
    obj.data{dataIndex} = updateLineseries(obj,dataIndex);

    %-revert handle-%
    obj.State.Plot(dataIndex).Handle = stair_group;
end

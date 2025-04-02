function obj = updateStair(obj, dataIndex)
    obj.data{dataIndex} = updateLineseries(obj, dataIndex);
    obj.data{dataIndex}.line.shape = "hv";
end

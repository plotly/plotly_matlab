function legendAxis = findLegendAxis(obj,legendHandle)
legendAxisIndex = find(arrayfun(@(x)(isequal(handle(getappdata(x.Handle,'LegendPeerHandle')),legendHandle)),obj.State.Axis), 1);
legendAxis = obj.State.Axis(legendAxisIndex).Handle; 
end
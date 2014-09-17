function legendAxis = findLegendAxis(obj,legendHandle)
legendAxisIndex = find(arrayfun(@(x)(eq(getappdata(x.Handle,'LegendPeerHandle'),legendHandle)),obj.State.Axis));
legendAxis = obj.State.Axis(legendAxisIndex).Handle; 
end
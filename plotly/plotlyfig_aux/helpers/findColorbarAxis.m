function colorbarAxis = findColorbarAxis(obj,colorbarHandle)
colorbarAxisIndex = find(arrayfun(@(x)(isequal(getappdata(x.Handle,'LegendColorbarInnerList'),colorbarHandle) + ...
                    isequal(getappdata(x.Handle,'LegendColorbarOuterList'),colorbarHandle)),obj.State.Axis));
colorbarAxis = obj.State.Axis(colorbarAxisIndex).Handle; 
end
function [multipleaxis, overlap] = isOverlapping(obj, axIndex)
% check axis overlap
overlap = find(arrayfun(@(x)(isequal(get(x.Handle,'Position'),get(obj.State.Axis(axIndex).Handle,'Position'))),obj.State.Axis(1:axIndex)));
multipleaxis = length(overlap) > 1;
end

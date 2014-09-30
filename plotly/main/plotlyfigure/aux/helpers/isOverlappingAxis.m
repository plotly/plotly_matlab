function [multipleaxis, overlap] = isOverlappingAxis(obj, axIndex)
% check axis overlap
overlap = find(arrayfun(@(x)(isequal(get(x.Handle,'Position'),get(obj.State.Axis(axIndex).Handle,'Position'))),obj.State.Axis(1:axIndex)));
multipleaxis = length(overlap) > 1; %greater than 1 because obj.State.Axis(1:axIndex) will always match 
end

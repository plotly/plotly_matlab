function [xsource, ysource] = findSourceAxis(obj, axIndex)

% initialize output
xsource = axIndex; 
ysource = axIndex; 

%-STANDARDIZE UNITS-%
axis_units = cell(1,axIndex);
for a = 1:axIndex
    axis_units{a} = get(obj.State.Axis(a).Handle,'Units');
    set(obj.State.Axis(a).Handle,'Units','normalized');
end

% check axis overlap
[multipleaxis, overlap] = isOverlappingAxis(obj, axIndex); 

% find x/y source axis
if multipleaxis
    for v = 1:length(overlap) - 1 % minus 1 because overlap(end) = axIndex
        if isequal(get(obj.State.Axis(axIndex).Handle, 'XAxisLocation'), get(obj.State.Axis(overlap(v)).Handle,'XAxisLocation'))
            xsource = overlap(v);
        end
        if isequal(get(obj.State.Axis(axIndex).Handle, 'YAxisLocation'), get(obj.State.Axis(overlap(v)).Handle,'YAxisLocation'))
            ysource = overlap(v);
        end
    end
end

%-REVERT UNITS-%
for a = 1:axIndex
    set(obj.State.Axis(a).Handle,'Units',axis_units{a});
end
end
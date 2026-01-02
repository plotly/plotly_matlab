function [overlapping, overlapaxes] = isOverlappingAxis(obj, axIndex)
    %-STANDARDIZE UNITS-%
    axis_units = cell(1,axIndex);
    for a = 1:axIndex
        axis_units{a} = obj.State.Axis(a).Handle.Units;
        obj.State.Axis(a).Handle.Units = "normalized";
    end

    % check axis overlap
    if axIndex == 1 % redundant to check this case
        overlapaxes = 1;
    else
        overlapaxes = find(arrayfun(@(x) isequal(x.Handle.Position, ...
                obj.State.Axis(axIndex).Handle.Position), ...
                obj.State.Axis(1:axIndex)));
    end
    % greater than 1 because obj.State.Axis(axIndex) will always be an
    % overlapping axis
    overlapping = length(overlapaxes) > 1;

    %-REVERT UNITS-%
    for a = 1:axIndex
        obj.State.Axis(a).Handle.Units = axis_units{a};
    end
end

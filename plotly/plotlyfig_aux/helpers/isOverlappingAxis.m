function [overlapping, overlapaxes] = isOverlappingAxis(obj, axIndex)
    % NOTE: This function assumes all axis Units have already been set to
    % "normalized" by the caller (the update cycle in plotlyfig.update).

    % check axis overlap
    if axIndex == 1 % redundant to check this case
        overlapaxes = 1;
    else
        overlapaxes = find(arrayfun(@(x) isequal(get(x.Handle, 'Position'), ...
                get(obj.State.Axis(axIndex).Handle, 'Position')), ...
                obj.State.Axis(1:axIndex)));
    end
    % greater than 1 because obj.State.Axis(axIndex) will always be an
    % overlapping axis
    overlapping = length(overlapaxes) > 1;
end

function check = isMultipleBaseline(obj, baselineIndex)
    % check for multiple baselines up to baselineIndex
    baselines = find(arrayfun(@(x) strcmp(x.Class,'baseline') ...
            && eq(x.AssociatedAxis, ...
            obj.State.Plot(baselineIndex).AssociatedAxis), ...
            obj.State.Plot(1:baselineIndex)));
    % greater than 1 because obj.State.Plot(baselineIndex).AssociatedAxis
    % will always match
    check = length(baselines) > 1;
end

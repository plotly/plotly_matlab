function legendAxis = findLegendAxis(obj,legendHandle)
    if ~is_octave() && verLessThan('matlab','9.0.0')
        legendAxisIndex = find(arrayfun(@(x) isequal( ...
                getappdata(x.Handle, 'LegendPeerHandle'), ...
                legendHandle), obj.State.Axis), 1);
    else
        legendAxisIndex = find(arrayfun( ...
                @(x) isprop(x.Handle, "Legend") ...
                     && isequal(get(x.Handle, 'Legend'), legendHandle), ...
                obj.State.Axis ...
        ),1);
    end

    if isempty(legendAxisIndex)
        % No associated axis found (e.g. Octave legends are not linked
        % to their axes)
        legendAxis = [];
    else
        legendAxis = obj.State.Axis(legendAxisIndex).Handle;
    end
end

function colorbarAxis = findColorbarAxis(obj,colorbarHandle)
    colorbarAxisIndex = find(arrayfun(@(x) isequal( ...
            getappdata(x.Handle,'ColorbarPeerHandle'), ...
            colorbarHandle),obj.State.Axis));
    % If the above returns empty then we are on a more recent Matlab
    % release where the appdata entry is called LayoutPeers
    if isempty(colorbarAxisIndex)
        colorbarAxisIndex = find(arrayfun(@(x) isequal( ...
                getappdata(x.Handle,'LayoutPeers'), ...
                colorbarHandle), obj.State.Axis));
    end

    try
        colorbarAxis = obj.State.Axis(colorbarAxisIndex).Handle;
    catch
        colorbarAxis = 1;
    end
end

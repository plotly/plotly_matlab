function orientation = histogramOrientation(hist_data)
    %initialize output
    orientation = [];

    try
        tmpXData = get(hist_data, 'XData');
        tmpYData = get(hist_data, 'YData');
        % Octave's bar3/bar3h create 3D patches that also have four
        % rows of data; a histogram patch is always flat in z
        tmpZData = [];
        if isprop(hist_data, 'ZData')
            tmpZData = get(hist_data, 'ZData');
        end
        if ~isempty(tmpZData) && any(nonzeros(tmpZData))
            return
        end
        % check to see if patch is in the shape of "vertical" rectangles :)
        if size(get(hist_data, 'XData'),1) == 4 ...
                && size(get(hist_data, 'XData'), 2) > 1 ...
                && all(tmpXData(1,:) == tmpXData(2,:)) ...
                && all(tmpXData(3,:) == tmpXData(4,:)) ...
                && all(tmpYData(1,:) == tmpYData(4,:)) ...
                && all(tmpYData(2,:) == tmpYData(3,:))
            orientation = 'v';
            % check to see if patch is in the shape of "horizontal" rectangles :)
        elseif size(get(hist_data, 'YData'),1) == 4 ...
                && size(get(hist_data, 'YData'), 2) > 1 ...
                && all(tmpYData(1,:) == tmpYData(2,:)) ...
                && all(tmpYData(3,:) == tmpYData(4,:)) ...
                && all(tmpXData(1,:) == tmpXData(4,:)) ...
                && all(tmpXData(2,:) == tmpXData(3,:))
            orientation = 'h';
        end
    end
end

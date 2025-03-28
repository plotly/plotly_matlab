function orientation = histogramOrientation(hist_data)
    %initialize output
    orientation = [];

    try
        % check to see if patch is in the shape of "vertical" rectangles :)
        if size(hist_data.XData,1) == 4 ...
                && size(hist_data.XData, 2) > 1 ...
                && all(hist_data.XData(1,:) == hist_data.XData(2,:)) ...
                && all(hist_data.XData(3,:) == hist_data.XData(4,:)) ...
                && all(hist_data.YData(1,:) == hist_data.YData(4,:)) ...
                && all(hist_data.YData(2,:) == hist_data.YData(3,:))
            orientation = 'v';
            % check to see if patch is in the shape of "horizontal" rectangles :)
        elseif size(hist_data.YData,1) == 4 ...
                && size(hist_data.YData, 2) > 1 ...
                && all(hist_data.YData(1,:) == hist_data.YData(2,:)) ...
                && all(hist_data.YData(3,:) == hist_data.YData(4,:)) ...
                && all(hist_data.XData(1,:) == hist_data.XData(4,:)) ...
                && all(hist_data.XData(2,:) == hist_data.XData(3,:))
            orientation = 'h';
        end
    end
end

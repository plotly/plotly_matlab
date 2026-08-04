function [idx, cmap] = quantizeColors(rgbData)
    % Octave's rgb2ind does not accept a target number of colors like
    % MATLAB's; build the colormap from the unique colors instead
    if is_octave()
        sz = size(rgbData);
        flat = reshape(double(rgbData), [], 3);
        [cmap, ~, idx] = unique(flat, 'rows');
        idx = reshape(idx, sz(1), sz(2));
    else
        [idx, cmap] = rgb2ind(rgbData, 256);
    end
end

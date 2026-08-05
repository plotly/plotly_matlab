function isPie = isPieSlice(patch_data)
    %-a pie slice polygon starts at the origin and arcs out to the
    %-circle (the closing vertex sits on the circle too)-%
    isPie = false;
    try
        x = get(patch_data, 'XData');
        y = get(patch_data, 'YData');
        if numel(x) >= 4 && x(1) == 0 && y(1) == 0
            r = sqrt(x(2:end).^2 + y(2:end).^2);
            isPie = mean(r) > 0.5 && std(r) / mean(r) < 0.2;
        end
    catch
    end
end

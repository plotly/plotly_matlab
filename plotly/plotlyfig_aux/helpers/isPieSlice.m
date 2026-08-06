function isPie = isPieSlice(patch_data)
    %-a pie slice polygon starts at the origin and arcs out to the
    %-circle. MATLAB closes the polygon explicitly by repeating the
    %-center vertex at the end; drop it so the radius check isn't
    %-skewed (small slices have few vertices, and a single stray
    %-(0,0) would inflate std(r)/mean(r) past the threshold)-%
    isPie = false;
    try
        x = get(patch_data, 'XData');
        y = get(patch_data, 'YData');
        if numel(x) >= 4 && x(1) == 0 && y(1) == 0
            arcLast = numel(x);
            if x(arcLast) == 0 && y(arcLast) == 0
                arcLast = arcLast - 1;
            end
            r = sqrt(x(2:arcLast).^2 + y(2:arcLast).^2);
            isPie = mean(r) > 0.5 && std(r) / mean(r) < 0.2;
        end
    catch
    end
end

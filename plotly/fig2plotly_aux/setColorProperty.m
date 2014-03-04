function color = setColorProperty(prop, color_ref, limits, colormap)

color = {};
%if one direct color
if isa(prop, 'double')
    if numel(prop)==3
        color{1} = parseColor(prop);
    end
end

%if no color
if strcmp(prop, 'none')
    color{1} = 'rgba(0,0,0,0)';
end

%if color defined by map
if strcmp(prop, 'flat') || strcmp(prop, 'auto')
    %if direct color mapping
    if size(color_ref,2)==3
        color = cell(1, size(color_ref,1));
        for i=1:size(color_ref,1)
            color{i} = parseColor(color_ref(i,:));
        end
    else %if indirect color mapping
        color = mapColors(color_ref, limits, colormap);
        
    end
end


end
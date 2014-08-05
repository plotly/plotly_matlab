function color = setColorProperty(prop, color_ref, limits, colormap,mh)

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
if (strcmp(prop, 'flat') || (strcmpi(prop, 'auto')))
    if size(color_ref,2)==3
        color = cell(1, size(color_ref,1));
        for i=1:size(color_ref,1)
            color{i} = parseColor(color_ref(i,:));
        end
    else %if indirect color mapping
        color = mapColors(color_ref, limits, colormap);
    end
end

%if color defined by axes (or figure) (only used with scattergroup)
%using isfield(get(mh),'CData') to determine if scattergroup
try
    if (strcmpi(prop, 'auto') && isfield(mh,'CData'))
        ah = ancestor(mh.Parent,'axes');
        axCol = get(ah,'Color');
        if(isa(axCol,'double'))
            color = {};
            color{1} = parseColor(axCol);
        else
            fh = ancestor(mh.Parent,'figure');
            figCol = get(fh,'Color');
            color = {};
            color{1}  = parseColor(figCol);
        end
    end
end

end
function color_cell = mapColors(c, limits, colormap)

%normalize
range = limits(2)-limits(1);
cn = 1+floor(((c-limits(1))/range)*(size(colormap,1)-1));

color_cell=cell(1,numel(c));

for i=1:numel(c)
    if cn(i)>size(colormap,1)
        cn(i)=size(colormap,1);
    end
    if cn(i)<1
        cn(i)=1;
    end
    color_cell{i} = parseColor(colormap(cn(i),:));
end

end
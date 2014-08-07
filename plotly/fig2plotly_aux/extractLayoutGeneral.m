function layout = extractLayoutGeneral(f, layout, strip_style)

%General attributes of the layout.


if strip_style
    layout.autosize = true;
    layout.margin.l=40;
    layout.margin.r=40;
    layout.margin.t=50;
    layout.margin.b=40;
    layout.margin.pad=0;
    
else
    
    try
        fhan = get(f.Children(1),'Parent');
        units = get(fhan,'Units');
        set(fhan,'Units','pixels');
       
        %update f to reflect units
        f = get(fhan);
        
        %extract the margins (extreme plot margins if subplots)
        [l, r, b, t] = extractMargins(fhan);
        
        %title margin adjust
        titleMinMar = 80; 
        
        layout.margin.l=l;
        layout.margin.r=l; %add symmetry to avoid title misalignment
        layout.margin.t=max(t,titleMinMar);
        layout.margin.b=b;
        layout.margin.pad=0;
        layout.autosize = false;
        
        %reset the units 
        set(fhan,'Units',units);
        
    catch 
        layout.margin.l=40;
        layout.margin.r=40;
        layout.margin.t=80;
        layout.margin.b=40;
        layout.margin.pad=0;
        layout.autosize = false;   
    end
end

%size increase (percentage); 
perSizeInc = 0.50; 

try
    fhan = get(f.Children(1),'Parent');
    units = get(fhan,'Units');
    set(fhan,'Units','pixels');
    %update f to reflect units
    f = get(fhan);
    layout.width = f.Position(3)*(1 + perSizeInc); 
    layout.height = f.Position(4)*(1 + perSizeInc);
    set(fhan,'Units',units);
catch
    layout.width = f.Position(3)*(1 + perSizeInc);
    layout.height = f.Position(4)*(1 + perSizeInc);
end

end
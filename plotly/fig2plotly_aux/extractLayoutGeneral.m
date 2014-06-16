function layout = extractLayoutGeneral(f, layout, strip_style)

%General attributes of the layout.
%TODO - incorporate JSON GRAPH REF
if strip_style
    layout.autosize = true;
    layout.margin.l=40;
    layout.margin.r=40;
    layout.margin.t=50;
    layout.margin.b=40;
    layout.margin.pad=2;
    
else
    layout.margin.l=0;
    layout.margin.r=0;
    layout.margin.t=5;
    layout.margin.b=0;
    layout.margin.pad=0;
    layout.autosize = false;
end

layout.width = f.Position(3);
layout.height = f.Position(4)+layout.margin.t;

if(~strip_style)
    %page color
    try
        layout.paper_bgcolor = parseColor(f.Color);
    end
    
    %plot colour
    for c = 1:length(f.Children)
        g = get(f.Children(c));
        try
            if(~strcmp(parseColor(g.Color),'rgb(255,255,255)'))
                layout.plot_bgcolor = parseColor(g.Color);
            end
        end
    end
end

end
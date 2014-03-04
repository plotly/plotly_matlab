function layout = extractLayoutGeneral(f, layout)

%General attributes of the layout.

layout.margin.l=0;
layout.margin.r=0;
layout.margin.t=5;
layout.margin.b=0;
layout.margin.pad=0;

layout.width = f.Position(3);
layout.height = f.Position(4)+5;
layout.autosize = false;



end
function obj = updateImplicitFunctionSurface(obj, surfaceIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
image_data = get(obj.State.Plot(surfaceIndex).Handle);
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-surface xaxis-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-surface yaxis-%
obj.data{surfaceIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%
    
%-surface type-%
obj.data{surfaceIndex}.type = 'surface';

%---------------------------------------------------------------------%

%-getting x,y,z surface data-%

strf = func2str(image_data.Function);
ind1 = strfind(strf, '('); ind1 = ind1(1)+1;
ind2 = strfind(strf, ')'); ind2 = ind2(1)-1;
vars = split(strf(ind1:ind2), ',');

strf = [strf(ind2+2:end) '==0'];
strf = replace(strf, vars{1}, 'Xx');
strf = replace(strf, vars{2}, 'Yy');
strf = replace(strf, vars{3}, 'Zz');

syms Xx Yy Zz;
f = eval(strf);
s = solve(f, Zz);

x = image_data.XRange;
y = image_data.YRange;
z = image_data.ZRange;
N = 400;

[Xx,Yy] = meshgrid(linspace(x(1),x(2),N), linspace(y(1),y(2),N));
X = []; Y = []; Z = [];

for n = 1:length(s)
    X = [X; Xx];
    Y = [Y; Yy];
    Z = [Z; eval(s(n))];
end

clear Xx Yy Zz;
Z(Z < z(1)) = nan; Z(Z > z(2)) = nan;
X(Z < z(1)) = nan; X(Z > z(2)) = nan;
Y(Z < z(1)) = nan; Y(Z > z(2)) = nan;

%---------------------------------------------------------------------%

%-surface x-%
obj.data{surfaceIndex}.x = X;

%---------------------------------------------------------------------%

%-surface y-%
obj.data{surfaceIndex}.y = Y;

%---------------------------------------------------------------------%

%-surface z-%
obj.data{surfaceIndex}.z = Z;

%---------------------------------------------------------------------%

%- setting grid mesh by default -%
% x-direction
mden = image_data.MeshDensity;
xsize = (x(2) - x(1)) / mden; 
obj.data{surfaceIndex}.contours.x.start = x(1);
obj.data{surfaceIndex}.contours.x.end = x(2);
obj.data{surfaceIndex}.contours.x.size = xsize;
obj.data{surfaceIndex}.contours.x.show = true;
obj.data{surfaceIndex}.contours.x.color = 'black';
% y-direction
ysize = (y(2) - y(1)) / mden;
obj.data{surfaceIndex}.contours.y.start = y(1);
obj.data{surfaceIndex}.contours.y.end = y(2);
obj.data{surfaceIndex}.contours.y.size = ysize;
obj.data{surfaceIndex}.contours.y.show = true;
obj.data{surfaceIndex}.contours.y.color = 'black';
% z-direction
zsize = (z(2) - z(1)) / mden;
obj.data{surfaceIndex}.contours.z.start = z(1);
obj.data{surfaceIndex}.contours.z.end = z(2);
obj.data{surfaceIndex}.contours.z.size = zsize;
obj.data{surfaceIndex}.contours.z.show = true;
obj.data{surfaceIndex}.contours.z.color = 'black';

%-------------------------------------------------------------------------%

%-image colorscale-%

cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{surfaceIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

%-------------------------------------------------------------------------%

%-image surfacescale-%
obj.data{surfaceIndex}.surfacecolor = Z;

%-------------------------------------------------------------------------%

%-surface name-%
obj.data{surfaceIndex}.name = image_data.DisplayName;

%-------------------------------------------------------------------------%

%-surface showscale-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-surface visible-%
obj.data{surfaceIndex}.visible = strcmp(image_data.Visible,'on');

%-------------------------------------------------------------------------%

leg = get(image_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{surfaceIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end

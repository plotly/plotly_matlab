function obj = updateHeatmap(obj,heatIndex)

%-------------------------------------------------------------------------%

%-HEATMAP DATA STRUCTURE- %
heat_data = get(obj.State.Plot(heatIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,heatIndex);

%-------------------------------------------------------------------------%

%-heatmap type-%
obj.data{heatIndex}.type = 'heatmap';

%-------------------------------------------------------------------------%

%-format data-%
xdata = heat_data.XDisplayData;
ydata = heat_data.YDisplayData(end:-1:1, :);
cdata = heat_data.ColorDisplayData(end:-1:1, :);

obj.data{heatIndex}.x = xdata;
obj.data{heatIndex}.y = ydata;
obj.data{heatIndex}.z = cdata;
obj.data{heatIndex}.connectgaps = false;
obj.data{heatIndex}.hoverongaps = false;

%-------------------------------------------------------------------------%

%-heatmap colorscale-%
cmap = heat_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{heatIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

%-------------------------------------------------------------------------%

%-setting plot-%
obj.data{heatIndex}.hoverinfo = 'text';
obj.data{heatIndex}.text = heat_data.ColorData(end:-1:1, :);
obj.data{heatIndex}.hoverlabel.bgcolor = 'white';

%-------------------------------------------------------------------------%

%-show colorbar-%
obj.data{heatIndex}.showscale = false;
if strcmpi(heat_data.ColorbarVisible, 'on')
    obj.data{heatIndex}.showscale = true;
    obj.data{heatIndex}.colorbar.x = 0.87;
    obj.data{heatIndex}.colorbar.y = 0.52; 
    obj.data{heatIndex}.colorbar.ypad = 55;
    obj.data{heatIndex}.colorbar.xpad = obj.PlotlyDefaults.MarginPad;
    obj.data{heatIndex}.colorbar.outlinecolor = 'rgb(150,150,150)';
end

%-------------------------------------------------------------------------%

%-hist visible-%
obj.data{heatIndex}.visible = strcmp(heat_data.Visible,'on');
obj.data{heatIndex}.opacity = 0.95;

%-------------------------------------------------------------------------%

%-setting annotation text-%
c = 1;
maxcol = max(cdata(:));

for n = 1:size(cdata, 2)
    for m = 1:size(cdata, 1)

        %-text-%
        ann{c}.text = num2str(round(cdata(m,n), 2));
        ann{c}.x = n-1;
        ann{c}.y = m-1;
        ann{c}.showarrow = false;

        %-font-%
        ann{c}.font.size = heat_data.FontSize*1.15;
        ann{c}.font.family = matlab2plotlyfont(heat_data.FontName);

        if cdata(m,n) < 0.925*maxcol
            col = [0,0,0];
        else
            col = [255,255,255];
        end

        ann{c}.font.color = sprintf('rgb(%f,%f,%f)', col);

        c = c+1;
    end
end

%-------------------------------------------------------------------------%

%-set annotations to layout-%
obj.layout = setfield(obj.layout, 'annotations', ann);

%-------------------------------------------------------------------------%

%-set backgroud color if any NaN in cdata-%
if any(isnan(cdata(:)))
    obj.layout.plot_bgcolor = 'rgb(40,40,40)';
    obj.data{heatIndex}.opacity = 1;
end

%-------------------------------------------------------------------------%
end

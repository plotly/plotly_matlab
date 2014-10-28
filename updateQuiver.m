function obj = updateQuiver(obj, quiverIndex)

%-------------------------------------------------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(quiverIndex).AssociatedAxis);

%-QUIVER DATA STRUCTURE- %
quiver_data = get(obj.State.Plot(quiverIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-quiver xaxis-%
obj.data{quiverIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-quiver yaxis-%
obj.data{quiverIndex}.yaxis = ['y' num2str(ysource)];

%------------------------------------------------------------------------%

%-quiver type-%
obj.data{quiverIndex}.type = 'scatter'; 

%-------------------------------------------------------------------------%

%-quiver visible-%
obj.data{quiverIndex}.visible = strcmp(quiver_data.Visible,'on');

%------------------------------------------------------------------------%

%-quiver mode-%
obj.data{quiverIndex}.mode = 'lines'; 

%-------------------------------------------------------------------------%

%-scatter name-%
obj.data{quiverIndex}.name = quiver_data.DisplayName;

%------------------------------------------------------------------------%

%-quiver line color-%
col = 255*quiver_data.Color; 
obj.data{quiverIndex}.line.color = ['rgb(' col(1) ',' col(2) ',' col(3) ')']; 

%------------------------------------------------------------------------%

% check for x/y vectors
if isvector(quiver_data.XData)
    [quiver_data.XData, quiver_data.YData] = meshgrid(quiver_data.XData,quiver_data.YData); 
end

%-format data-%
xdata = reshape(quiver_data.XData,1,size(quiver_data.XData,1)*size(quiver_data.XData,1)); 
ydata = reshape(quiver_data.YData,1,size(quiver_data.YData,1)*size(quiver_data.YData,1)); 
udata = reshape(quiver_data.UData,1,size(quiver_data.UData,1)*size(quiver_data.UData,1)); 
vdata = reshape(quiver_data.VData,1,size(quiver_data.VData,1)*size(quiver_data.VData,1)); 

%------------------------------------------------------------------------%

%-quiver x-%
m = 1; 
for n = 1:length(xdata)
obj.data{quiverIndex}.x(m) = xdata(n); 
obj.data{quiverIndex}.x(m+1) = xdata(n) + 0.1*udata(n);
obj.data{quiverIndex}.x(m+2) = nan; 
m = m + 3; 
end

%------------------------------------------------------------------------%

%-quiver y-%
m = 1; 
for n = 1:length(ydata)
obj.data{quiverIndex}.y(m) = ydata(n); 
obj.data{quiverIndex}.y(m+1) = ydata(n) + 0.1*vdata(n);
obj.data{quiverIndex}.y(m+2) = nan; 
m = m + 3; 
end

%-------------------------------------------------------------------------%

%-scatter showlegend-%
leg = get(quiver_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{quiverIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
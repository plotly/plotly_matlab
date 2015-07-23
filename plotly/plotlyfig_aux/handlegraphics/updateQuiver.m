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

%-quiver barbs-%
max_head_size = 0.3; % 'MaxHeadSize' scalar, matlab clips to 0.2
head_width = deg2rad(17); % barb width, not supported by matlab
for n = 1:length(xdata) % xdata and ydata had better be the same length... throw an exception if this isn't true?
    % length of arrow
    l = norm([0.1*udata(n), 0.1*vdata(n)]);
    
    % angle of arrow
    phi = atan2(vdata(n),udata(n));
    
    % make barb with specified angular width and length prop. to arrow
    barb = [...
    [-max_head_size*l*cos(head_width), max_head_size*l*sin(head_width)]; ... 
    [0, 0]; ...  
    [-max_head_size*l*cos(head_width), -max_head_size*l*sin(head_width)];
    ]';
    
    % affine matrix: rotate by arrow angle and translate to end of arrow
    barb_transformation = affine2d([...
        [cos(phi), sin(phi), 0]; ...
        [-sin(phi), cos(phi), 0]; ...
        [xdata(n) + 0.1*udata(n), ydata(n) + 0.1*vdata(n), 1];
        ]);
    
    % apply transformation to barb
    barb = transformPointsForward(barb_transformation, barb')';
    
    % add barb to plot data
    obj.data{quiverIndex}.x(end+1) = barb(1,1); % point 1
    obj.data{quiverIndex}.y(end+1) = barb(2,1);
    obj.data{quiverIndex}.x(end+1) = barb(1,2); % point 2
    obj.data{quiverIndex}.y(end+1) = barb(2,2);
    obj.data{quiverIndex}.x(end+1) = barb(1,3); % point 3
    obj.data{quiverIndex}.y(end+1) = barb(2,3);
    obj.data{quiverIndex}.x(end+1) = nan; % insert blank line between successive barbs
    obj.data{quiverIndex}.y(end+1) = nan;
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
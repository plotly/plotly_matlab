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
obj.data{quiverIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

%-quiver line width-%
obj.data{quiverIndex}.line.width = 2 * quiver_data.LineWidth;

%------------------------------------------------------------------------%

% check for x/y vectors
if isvector(quiver_data.XData)
    [quiver_data.XData, quiver_data.YData] = meshgrid(quiver_data.XData,quiver_data.YData); 
end

%-get scale factor-%
if strcmpi(quiver_data.AutoScale, 'on')
    xdata = quiver_data.XData; 
    udata = quiver_data.UData;

    nsteps = 45;
    steps = linspace(1e-3, 1, nsteps);
    steps = steps(end:-1:1);

    for n = 1:nsteps
        scalefactor = steps(n);

        x = xdata(:, 2:end, :);
        u = xdata(:, 1:end-1,:) + scalefactor * udata(:, 1:end-1,:);
        xflag = x>u;

        if all(xflag(:))
            break
        end
    end
else
    scalefactor = 1;
end

%------------------------------------------------------------------------%

%-format data-%
xdata = quiver_data.XData(:);
ydata = quiver_data.YData(:); 
udata = quiver_data.UData(:)*scalefactor;
vdata = quiver_data.VData(:)*scalefactor; 

%------------------------------------------------------------------------%

%-quiver x-%
m = 1; 
for n = 1:length(xdata)
obj.data{quiverIndex}.x(m) = xdata(n); 
obj.data{quiverIndex}.x(m+1) = xdata(n) + udata(n);
obj.data{quiverIndex}.x(m+2) = nan; 
m = m + 3; 
end

%------------------------------------------------------------------------%

%-quiver y-%
m = 1; 
for n = 1:length(ydata)
obj.data{quiverIndex}.y(m) = ydata(n); 
obj.data{quiverIndex}.y(m+1) = ydata(n) + vdata(n);
obj.data{quiverIndex}.y(m+2) = nan; 
m = m + 3; 
end

%-------------------------------------------------------------------------%

%-quiver barbs-%
if isHG2() && strcmp(quiver_data.ShowArrowHead, 'on')
 
    % 'MaxHeadSize' scalar, matlab clips to 0.2 in r2014b
    maxheadsize = quiver_data.MaxHeadSize;
    % barb angular width, not supported by matlab
    head_width = deg2rad(17.5);
    
    for n = 1:length(xdata)
        % length of arrow
        l = norm([udata(n), vdata(n)]);
        
        % angle of arrow
        phi = atan2(vdata(n),udata(n));
        
        % make barb with specified angular width, length is prop. to arrow
        barb = [...
            [-maxheadsize*l*cos(head_width), maxheadsize*l*sin(head_width)]; ...
            [0, 0]; ...
            [-maxheadsize*l*cos(head_width), -maxheadsize*l*sin(head_width)]; ...
            [nan, nan]; ...
            ]';
        
        % affine matrix: rotate by arrow angle and translate to end of arrow
        barb_transformation = affine2d([...
            [cos(phi), sin(phi), 0]; ...
            [-sin(phi), cos(phi), 0]; ...
            [xdata(n) + udata(n), ydata(n) + vdata(n), 1];
            ]);
        
        % place barb at end of arrow
        barb = transformPointsForward(barb_transformation, barb')';
        
        % add barb to plot data, inserting is optimized in matlab >2010
        for col = 1:4
            obj.data{quiverIndex}.x(end+1) = barb(1,col); % point 1
            obj.data{quiverIndex}.y(end+1) = barb(2,col);
        end
    end
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
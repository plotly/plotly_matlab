    function updateBubblecloud(obj,bcIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(bcIndex).AssociatedAxis);

%-BubbleCloud (bc) DATA STRUCTURE- %
bcData = get(obj.State.Plot(bcIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

% %-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

obj.layout.xaxis1.showline = true;
obj.layout.xaxis1.zeroline = false;
obj.layout.xaxis1.autorange = false;
obj.layout.xaxis1.mirror = true;

obj.layout.yaxis1.showline = true;
obj.layout.yaxis1.zeroline = false;
obj.layout.yaxis1.autorange = false;
obj.layout.yaxis1.mirror = true;

%%%%%%%%%%%%%%%
%Useful for debugging!!!
% obj.layout.xaxis1.tickmode='auto';
% obj.layout.xaxis1.nticks=11;
% obj.layout.xaxis1.showticklabels=0;
% obj.layout.yaxis1.tickmode='auto';
% obj.layout.yaxis1.nticks=11;
% obj.layout.yaxis1.showticklabels=0;
%%%%%%%%%%%%%%%

% obj.layout.title.text='<b><b></b></b>';
obj.layout.margin.t=80;
obj.layout.annotations{1}.text='';

%-------------------------------------------------------------------------%

%-bc xaxis-%
obj.data{bcIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-bc yaxis-%
obj.data{bcIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-bc type-%
obj.data{bcIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-bc mode-%
obj.data{bcIndex}.mode = 'markers+text';

%-------------------------------------------------------------------------%

%-bc visible-%
obj.data{bcIndex}.visible = strcmp(bcData.Visible,'on');

%-------------------------------------------------------------------------%

%-bc name-%
obj.data{bcIndex}.name = bcData.LegendTitle;

%-------------------------------------------------------------------------%

[sortedradii,RadiusIndex]=sort(sqrt(bcData.SizeData),'descend');

sortedradii=sortedradii/max(sortedradii);

ar = obj.layout.width/obj.layout.height;

xIN = xaxis.domain(2) - xaxis.domain(1);
yIN = yaxis.domain(2) - yaxis.domain(1);
axAR =  ar*xIN/yIN;

xy = matlab.graphics.internal.layoutBubbleCloud(sortedradii,ar);

xR = [min(xy(1,:)-sortedradii), max(xy(1,:)+sortedradii)];
yR = [min(xy(2,:)-sortedradii), max(xy(2,:)+sortedradii)];

xR = xR + [-0.125, 0.125]*abs(diff(xR));
yR = yR + [-0.125, 0.125]*abs(diff(yR));

dataAR = abs(diff(xR))/abs(diff(yR));

if dataAR > axAR
    amounttopad = abs(diff(yR)) * dataAR/axAR - abs(diff(yR));
    yR = yR + [-amounttopad/2, amounttopad/2];
else
    amounttopad = abs(diff(xR)) * axAR/dataAR - abs(diff(xR));
    xR = xR + [-amounttopad/2, amounttopad/2];
end

radX = (2*sortedradii * (xIN*obj.layout.width) / abs(diff(xR)));

obj.layout.xaxis1.range=xR;
obj.layout.yaxis1.range=yR + [0.38, -0.38];
rads=radX;

%-------------------------------------------------------------------------%

labels = bcData.LabelData(RadiusIndex);
obj.data{bcIndex}.text = arrayfun(@(x) {char(x)}, labels);
obj.data{bcIndex}.textfont.family = matlab2plotlyfont(bcData.FontName);
obj.data{bcIndex}.textfont.color = sprintf('rgb(%i,%i,%i)',255*bcData.FontColor);
obj.data{bcIndex}.textfont.size = bcData.FontSize*1.5;

%-------------------------------------------------------------------------%

obj.data{bcIndex}.hovertemplate = 'Size: %{hovertext}<br>Label: %{text}';
obj.data{bcIndex}.hovertext = arrayfun(@(x) {num2str(x)}, bcData.SizeData(RadiusIndex));

%-------------------------------------------------------------------------%

%-bc x-%
% if length(bcData) > 1
%     obj.data{bcIndex}.x(m) = bcData(n).XData;
% else
    obj.data{bcIndex}.x = xy(1,:);
% end

%---------------------------------------------------------------------%

%-bc y-%
% if length(bcData) > 1
%     obj.data{bcIndex}.y(m) = bcData(n).YData;
% else
    obj.data{bcIndex}.y = xy(2,:);
% end

%---------------------------------------------------------------------%

%-bc z-%
% if isHG2()
%     if isfield(bcData,'ZData')
%         if any(bcData.ZData)
%             if length(bcData) > 1
%                 obj.data{bcIndex}.z(m) = bcData(n).ZData;
%             else
%                 obj.data{bcIndex}.z = bcData.ZData;
%             end
%             % overwrite type
%             obj.data{bcIndex}.type = 'scatter3d';
%         end
%     end
% end

%---------------------------------------------------------------------%

%-bc showlegend-%
try
    leg = get(bcData.Annotation);
catch
    leg=[];
end
if ~isempty(leg)
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end
end

if isfield(bcData,'ZData')
    if isempty(bcData.ZData)
        obj.data{bcIndex}.showlegend = showleg;
    end
end

%---------------------------------------------------------------------%

%-line color-%
if length(bcData) > 1
    obj.data{bcIndex}.marker.line.color{m} = childmarker.line.color{1};
else
    col=uint8(bcData.EdgeColor*255);
    obj.data{bcIndex}.marker.line.color = sprintf('rgb(%i,%i,%i)',col);
end

%---------------------------------------------------------------------%

%-marker color-%
col=uint8(bcData.ColorOrder(1,:)*255);
obj.data{bcIndex}.marker.color = sprintf('rgb(%i,%i,%i)',col);

%---------------------------------------------------------------------%

%-sizeref-%
obj.data{bcIndex}.marker.sizeref = 1;

%---------------------------------------------------------------------%

%-sizemode-%
obj.data{bcIndex}.marker.sizemode = 'diameter';

%---------------------------------------------------------------------%

%-symbol-%
obj.data{bcIndex}.marker.symbol = 'circle';

%---------------------------------------------------------------------%

%-size-%
obj.data{bcIndex}.marker.size = rads;

%---------------------------------------------------------------------%

%-line width-%
obj.data{bcIndex}.marker.line.width = 1.5;

%---------------------------------------------------------------------%

end


function updateBubblecloud(obj,bcIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(bcIndex).AssociatedAxis);

%-BubbleCloud (bc) DATA STRUCTURE- %
bcData = get(obj.State.Plot(bcIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

% %-AXIS DATA-%
% eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
% eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

% obj.layout.xaxis.side = 'bottom';
obj.layout.xaxis1.showline = false;
obj.layout.xaxis1.zeroline = false;
% obj.layout.xaxis.autorange = false;
% % obj.layout.xaxis.linecolor='rgb(0,0,0)';
% obj.layout.xaxis.showgrid = true;
% obj.layout.xaxis.linewidth = 1;
% obj.layout.xaxis.type = 'linear';
% obj.layout.xaxis.anchor = 'y1';
obj.layout.xaxis1.mirror = true;
% 
% 
% obj.layout.yaxis.side = 'left';
obj.layout.yaxis1.showline = false;
obj.layout.yaxis1.zeroline = false;
% obj.layout.yaxis.autorange = false;
% % obj.layout.yaxis.linecolor='rgb(0,0,0)';
% obj.layout.yaxis.showgrid = true;
% obj.layout.yaxis.linewidth = 1;
% obj.layout.yaxis.type = 'linear';
% obj.layout.yaxis.anchor = 'x1';
obj.layout.yaxis1.mirror = true;

obj.layout.title.text='<b><b></b></b>';
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

[sortedradii,sortind]=sort(sqrt(real(bcData.SizeData)),'descend');
validind=isfinite(sortedradii) & sortedradii>0;
sortind=sortind(validind);
sortedradii=sortedradii(validind);

if bcData.MaxDisplayBubbles < numel(sortind)
    sortind=sortind(1:bcData.MaxDisplayBubbles);
    sortedradii=sortedradii(1:bcData.MaxDisplayBubbles);
end
RadiusIndex=sortind;

% Normalize radii so that the largest bubble has a radius of 1
if ~isempty(sortedradii)
    sortedradii=sortedradii/max(sortedradii);
end

ar = 840/630;
xy = matlab.graphics.internal.layoutBubbleCloud(sortedradii,ar);
fac=2*ar;
rads = 2*sortedradii * (840 / ( fac*max(xy(1,:)) - fac*min(xy(1,:))));
% xy = matlab.graphics.internal.layoutBubbleCloud(rads,ar);

obj.layout.xaxis1.range=[fac*min(xy(1,:)), fac*max(xy(1,:))];
obj.layout.yaxis1.range=[(fac/ar)*min(xy(2,:)), (fac/ar)*max(xy(2,:))];

% rads = 2*rads * (840 / ( fac*max(xy(1,:)) - fac*min(xy(1,:))));

%-------------------------------------------------------------------------%

labels = bcData.LabelData(RadiusIndex);
obj.data{bcIndex}.text = arrayfun(@(x) {char(x)}, labels);

obj.data{bcIndex}.textfont = matlab2plotlyfont(bcData.FontName);

%-------------------------------------------------------------------------%

% obj.data{bcIndex}.hoverinfo = '';
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


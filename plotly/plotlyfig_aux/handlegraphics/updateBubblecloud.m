function updateBubblecloud(obj,~)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(1).AssociatedAxis);

%-BubbleCloud (bc) DATA STRUCTURE- %
bcData = get(obj.State.Plot(1).Handle);

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
obj.layout.xaxis1.tickmode='auto';
obj.layout.xaxis1.nticks=11;
obj.layout.xaxis1.showticklabels=0;
obj.layout.yaxis1.tickmode='auto';
obj.layout.yaxis1.nticks=11;
obj.layout.yaxis1.showticklabels=0;
%%%%%%%%%%%%%%%

% obj.layout.title.text='<b><b></b></b>';
obj.layout.margin.t=80;
obj.layout.annotations{1}.text='';


[sortedradii,RadiusIndex]=sort(sqrt(bcData.SizeData),'descend');

sortedradii=sortedradii/max(sortedradii);

ar = obj.layout.width/obj.layout.height;

xIN = xaxis.domain(2) - xaxis.domain(1);
yIN = yaxis.domain(2) - yaxis.domain(1);
axAR =  ar*xIN/yIN;

if isempty(bcData.GroupData) || all(bcData.GroupData==bcData.GroupData(1))
    XY = matlab.graphics.internal.layoutBubbleCloud(sortedradii,ar);
    nGrps=1;
    myIdx{1} = true(size(sortedradii));
else
    groups=bcData.GroupData(RadiusIndex);
    undefined_ind=ismissing(groups);
    grplist=unique(groups(~undefined_ind));
    groupradius=nan(numel(grplist),1);
    for g=1:numel(grplist)
        gp_ind=groups==grplist(g);
        if any(gp_ind)
            r=sortedradii(gp_ind);
            xy=matlab.graphics.internal.layoutBubbleCloud(r,1);
            groupradius(g)=max(sqrt(sum(xy.^2))+r);
            XY(1:2,gp_ind)=xy;
        end
    end

    % Layout any nan/undefined as a separate group
    if any(undefined_ind)
        r=sortedradii(undefined_ind);
        xy=matlab.graphics.internal.layoutBubbleCloud(r,1);
        groupradius(end+1)=max(sqrt(sum(xy.^2))+r);
        XY(1:2,undefined_ind)=xy;
    end

    % Layout the circles that contain the groups
    groupxyr=nan(3,numel(groupradius));
    groupxyr(3,:)=groupradius;
    [gp_sortr,gp_sortind]=sort(groupradius,'descend');
    groupxyr(1:2,gp_sortind)=matlab.graphics.internal.layoutBubbleCloud(gp_sortr,ar);

    % Apply the group bubble position as an offset
    for g=1:numel(grplist)
        gp_ind=groups==grplist(g);
        XY(1:2,gp_ind)=XY(1:2,gp_ind)+groupxyr(1:2,g);
    end

    % Offset undefined group if it exists
    if any(undefined_ind)
        XY(1:2,undefined_ind)=XY(1:2,undefined_ind)+groupxyr(1:2,end);
    end
    
    gps=unique(groups);
    nGrps = numel(gps);
    for i = 1:nGrps
        gp_ind = groups == gps(i);
        myIdx{i} = gp_ind;
    end
    
end

xR = [min(XY(1,:)-sortedradii), max(XY(1,:)+sortedradii)];
yR = [min(XY(2,:)-sortedradii), max(XY(2,:)+sortedradii)];

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

hei = obj.layout.height;
yCorr = -7.107E-13*hei^4 + 3.145E-09*hei^3 - 5.275E-06*hei^2 + 0.004197*hei - 1.602;

% yCorr = -0.235;
if nGrps==1
    obj.layout.yaxis1.range = yR + [-yCorr, yCorr];
else
    obj.layout.yaxis1.range = yR + [0.16, -0.16];
end
rads=radX;

for bcIndex = 1:nGrps
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

    labels = bcData.LabelData(RadiusIndex(myIdx{bcIndex}));
    obj.data{bcIndex}.text = arrayfun(@(x) {char(x)}, labels);
    obj.data{bcIndex}.textfont.family = matlab2plotlyfont(bcData.FontName);
    obj.data{bcIndex}.textfont.color = sprintf('rgb(%i,%i,%i)',255*bcData.FontColor);
    obj.data{bcIndex}.textfont.size = bcData.FontSize*1.5;

    %-------------------------------------------------------------------------%
    
    if isempty(bcData.SizeVariable)
        bcData.SizeVariable='Size';
    end
    if isempty(bcData.LabelVariable)
        bcData.LabelVariable='Label';
    end
    if isempty(bcData.GroupVariable)
        bcData.GroupVariable='Group';
    end
    
    if nGrps>1
        obj.data{bcIndex}.hovertemplate = sprintf('%s: %%{hovertext}<br>%s: %%{text}',bcData.SizeVariable,bcData.LabelVariable);
        j = find(myIdx{bcIndex});
        obj.data{bcIndex}.name = char(bcData.GroupData(RadiusIndex(j(1))));
        obj.data{bcIndex}.hovertext = arrayfun(@(x,y) {num2str(x)}, bcData.SizeData(RadiusIndex(myIdx{bcIndex})), 'UniformOutput',false);
    else
        obj.data{bcIndex}.hovertemplate = sprintf('%s: %%{hovertext}<br>%s: %%{text}',bcData.SizeVariable,bcData.LabelVariable);
        obj.data{bcIndex}.hovertext = arrayfun(@(x) {num2str(x)}, bcData.SizeData(RadiusIndex(myIdx{bcIndex})));
    end

    %-------------------------------------------------------------------------%

    obj.data{bcIndex}.x = XY(1,myIdx{bcIndex});
    
    %---------------------------------------------------------------------%

    obj.data{bcIndex}.y = XY(2,myIdx{bcIndex});
    
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
    col=uint8(bcData.ColorOrder(bcIndex,:)*255);
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
    obj.data{bcIndex}.marker.size = rads(myIdx{bcIndex});

    %---------------------------------------------------------------------%

    %-line width-%
    obj.data{bcIndex}.marker.line.width = 1.5;

    %---------------------------------------------------------------------%

end

end


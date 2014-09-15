function obj = updateBarseries(obj,dataIndex)

% x: ...[DONE]
% y: ...[DONE]
% name: ...[DONE]
% orientation: ...[DONE]
% text: ...[NOT SUPPORTED IN MATLAB]
% error_y: ...[HANDLED BY ERRORBAR]
% error_x: ...[HANDLED BY ERRORBAR]
% opacity: ------------------------------------------> [TODO]
% xaxis: ...[DONE]
% yaxis: ...[DONE]
% showlegend: ...[DONE]
% stream: ...[HANDLED BY PLOTLY STREAM]
% visible: ...[DONE]
% type: ...[DONE]
% r: ...[NA]
% t: ...[NA]
% textfont: ...[NA]

% MARKER:
% color: ...DONE]
% size: ...[NA]
% symbol: ...[NA]
% opacity: ...[NA]
% sizeref: ...[NA]
% sizemode: ...[NA]
% colorscale: ...[NA]
% cauto: ...[NA]
% cmin: ...[NA]
% cmax: ...[NA]
% outliercolor: ...[NA]
% maxdisplayed: ...[NA]

% MARKER LINE:
% color: ........[TODO]
% width: ...[DONE]
% dash: ...[NA]
% opacity: ------------------------------------------> [TODO]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]

% LINE:
% color: ........[N/A]
% width: ...[NA]
% dash: ...[NA]
% opacity: ...[NA]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]


%-------------------------------------------------------------------------%

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-BAR DATA STRUCTURE- %
bar_data = get(obj.State.Plot(dataIndex).Handle);

%-BAR CHILD (PATCH) DATA STRUCTURE- %
bar_child_data = get(bar_data.Children(1));

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-BAR XAXIS-%
obj.data{dataIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-BAR YAXIS-%
obj.data{dataIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-BAR TYPE-%
obj.data{dataIndex}.type = 'bar';

%-------------------------------------------------------------------------%

%-bar name-%
obj.data{dataIndex}.name = bar_data.DisplayName;

%-------------------------------------------------------------------------%

%-layout barmode-%
switch bar_data.BarLayout
    case 'grouped'
        obj.layout.barmode = 'group';
    case 'stacked'
        obj.layout.barmode = 'stack';
end

%-------------------------------------------------------------------------%

%-bar orientation-%
switch bar_data.Horizontal
   
    case 'off'
        
        obj.data{dataIndex}.orientation = 'v';
        
        %-bar x data-%
        obj.data{dataIndex}.x = bar_data.XData;
       
        %-bar y data-%
        obj.data{dataIndex}.y = bar_data.YData;
        
        
    case 'on'
        
        obj.data{dataIndex}.orientation = 'h';
        
        %-bar x data-%
        obj.data{dataIndex}.x = bar_data.YData;
       
        %-bar y data-%
        obj.data{dataIndex}.y = bar_data.XData;
end

%-------------------------------------------------------------------------%

%-layout bargap-%
obj.layout.bargap = 1-bar_data.BarWidth;

%-------------------------------------------------------------------------%

%-bar line width-%
obj.data{dataIndex}.marker.line.width = bar_child_data.LineWidth;

%-------------------------------------------------------------------------%

%-BAR SHOWLEGEND-%
leg = get(bar_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{dataIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-bar visible-%
obj.data{dataIndex}.visible = strcmp(bar_data.Visible,'on');

%-------------------------------------------------------------------------%

%-bar opacity-%
if ~ischar(bar_child_data.FaceAlpha)
    obj.data{dataIndex}.opacity = bar_child_data.FaceAlpha;
end

%-------------------------------------------------------------------------%

%-bar face color-%

colormap = figure_data.Colormap;

if ~ischar(bar_child_data.FaceColor)
    
    %-paper_bgcolor-%
    col = 255*bar_child_data.FaceColor;
    obj.data{dataIndex}.marker.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch bar_child_data.FaceColor
        case 'none'
            obj.data{dataIndex}.marker.color = 'rgba(0,0,0,0,)';
        case 'flat'
            switch bar_child_data.CDataMapping
                case 'scaled'
                    capCD = max(min(bar_child_data.FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                    scalefactor = (capCD -axis_data.CLim(1))/diff(axis_data.CLim);
                    col =  255*(colormap(1+ floor(scalefactor*(length(colormap)-1)),:));
                case 'direct'
                    col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
            end
            obj.data{dataIndex}.marker.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

%-------------------------------------------------------------------------%

%-bar edge color-%

if ~ischar(bar_child_data.EdgeColor)
    
    %-paper_bgcolor-%
    col = 255*bar_child_data.EdgeColor;
    obj.data{dataIndex}.marker.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch bar_child_data.EdgeColor
        case 'none'
            obj.data{dataIndex}.marker.line.color = 'rgba(0,0,0,0,)';
        case 'flat'
            switch bar_child_data.CDataMapping
                case 'scaled'
                    capCD = max(min(bar_child_data.FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                    scalefactor = (capCD -axis_data.CLim(1))/diff(axis_data.CLim);
                    col =  255*(colormap(1+floor(scalefactor*(length(colormap)-1)),:));
                case 'direct'
                    col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
            end
            obj.data{dataIndex}.marker.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

end



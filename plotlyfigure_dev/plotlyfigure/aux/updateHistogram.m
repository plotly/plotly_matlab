function obj = updateHistogram(obj,histIndex)

% x:...[DONE]
% y:...[DONE]
% histnorm:...[DONE]
% name:...[DONE]
% autobinx:...[DONE]
% nbinsx:...[DONE]
% xbins:...[NA]
% autobiny:...[DONE]
% nbinsy:...[DONE]
% ybins:...[NA]
% text:...[NOT SUPPORTED IN MATLAB]
% error_y:...[HANDLED BY ERRORBARSERIES]
% error_x:...[HANDLED BY ERRORBARSERIES]
% opacity: -----------------------------------> TODO
% xaxis:...[DONE]
% yaxis:...[DONE]
% showlegend:...[DONE]
% stream:...[HANDLED BY PLOTLYSTREAM]
% visible:...[DONE]
% type:...[DONE]
% orientation:...[DONE]

% MARKER:
% color: .............[TODO]
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
% opacity: ...[NA]
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
axis_data = get(obj.State.Plot(histIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);

%-HIST DATA STRUCTURE- %
hist_data = get(obj.State.Plot(histIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-HIST XAXIS-%
obj.data{histIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-HIST YAXIS-%
obj.data{histIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-HIST TYPE-%
obj.data{histIndex}.type = 'histogram';

%-------------------------------------------------------------------------%

%-HIST XAXIS-%
obj.data{histIndex}.histnorm = 'count';

%-------------------------------------------------------------------------%

obj.data{histIndex}.orientation = histogramOrientation(hist_data);

switch obj.data{histIndex}.orientation
    case 'v'
        
        %-hist x data-%
        xdata = mean(hist_data.XData(2:3,:));
        
        %-------------------------------------------------------------------------%
        
        %-hist y data-%
        xlength = 0;
        for d = 1:length(xdata)
            obj.data{histIndex}.x(xlength + 1: xlength + hist_data.YData(2,d)) = repmat(xdata(d),1,hist_data.YData(2,d));
            xlength = length(obj.data{histIndex}.x);
        end
        
        %-------------------------------------------------------------------------%
        
        %-HIST AUTOBINX-%
        obj.data{histIndex}.autobinx = true;
        
        %-------------------------------------------------------------------------%
        
        %-HIST NBINSX-%
        obj.data{histIndex}.nbinsx = length(xdata);
       
        %-------------------------------------------------------------------------%
        
        
    case 'h'
        
        %-hist y data-%
        ydata = mean(hist_data.YData(2:3,:));
        
        %-------------------------------------------------------------------------%
        
        %-hist y data-%
        ylength = 0;
        for d = 1:length(ydata)
            obj.data{histIndex}.y(ylength + 1: ylength + hist_data.XData(2,d)) = repmat(ydata(d),1,hist_data.XData(2,d));
            ylength = length(obj.data{histIndex}.y);
        end
        
        %-------------------------------------------------------------------------%
        
        %-HIST AUTOBINX-%
        obj.data{histIndex}.autobiny = true;
        
        %-------------------------------------------------------------------------%
        
        %-HIST NBINSX-%
        obj.data{histIndex}.nbinsy = length(ydata);
       
        %-------------------------------------------------------------------------%
             
end

%-------------------------------------------------------------------------%

%-hist name-%
obj.data{histIndex}.name = hist_data.DisplayName;

%-------------------------------------------------------------------------%

%-layout barmode-%
obj.layout.barmode = 'group';

%-------------------------------------------------------------------------%

%-layout bargap-%
obj.layout.bargap = (hist_data.XData(3,1)-hist_data.XData(2,2))/(hist_data.XData(3,1)-hist_data.XData(2,1));

%-------------------------------------------------------------------------%

%-hist line width-%
obj.data{histIndex}.marker.line.width = hist_data.LineWidth;

%-------------------------------------------------------------------------%

%-hist opacity-%
if ~ischar(hist_data.FaceAlpha)
    obj.data{histIndex}.opacity = hist_data.FaceAlpha;
end

%-------------------------------------------------------------------------%

%-hist face color-%

colormap = figure_data.Colormap;

if ~ischar(hist_data.FaceColor)
    
    %-paper_bgcolor-%
    col = 255*hist_data.FaceColor;
    obj.data{histIndex}.marker.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch hist_data.FaceColor
        case 'none'
            obj.data{histIndex}.marker.color = 'rgba(0,0,0,0,)';
        case 'flat'
            switch hist_data.CDataMapping
                case 'scaled'
                    capCD = max(min(hist_data.FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                    scalefactor = (capCD -axis_data.CLim(1))/diff(axis_data.CLim);
                    col =  255*(colormap(1+ floor(scalefactor*(length(colormap)-1)),:));
                case 'direct'
                    col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
            end
            obj.data{histIndex}.marker.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

%-------------------------------------------------------------------------%

%-hist edge color-%

if ~ischar(hist_data.EdgeColor)
    
    %-paper_bgcolor-%
    col = 255*hist_data.EdgeColor;
    obj.data{histIndex}.marker.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch hist_data.EdgeColor
        case 'none'
            obj.data{histIndex}.marker.line.color = 'rgba(0,0,0,0,)';
        case 'flat'
            switch hist_data.CDataMapping
                case 'scaled'
                    capCD = max(min(hist_data.FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                    scalefactor = (capCD -axis_data.CLim(1))/diff(axis_data.CLim);
                    col =  255*(colormap(1+floor(scalefactor*(length(colormap)-1)),:));
                case 'direct'
                    col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
            end
            obj.data{histIndex}.marker.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

%-------------------------------------------------------------------------%

%-hist visible-%
obj.data{histIndex}.visible = strcmp(hist_data.Visible,'on');

%-------------------------------------------------------------------------%

%-HIST SHOWLEGEND-%
leg = get(hist_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{histIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end

function obj = updateImage(obj, dataIndex)

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-IMAGE DATA STRUCTURE- %
image_data = get(obj.State.Plot(dataIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

% HEATMAPS
% z: ....................[TODO]
% x: ....................[TODO]
% y: ....................[TODO]
% name: ....................[TODO]
% zauto: ....................[TODO]
% zmin: ....................[TODO]
% zmax: ....................[TODO]
% colorscale: ....................[TODO]
% reversescale: ....................[TODO]
% showscale: ....................[TODO]
% colorbar: ....................[TODO]
% zsmooth: ....................[TODO]
% opacity: ....................[TODO]
% xaxis: ....................[TODO]
% yaxis: ....................[TODO]
% showlegend: ....................[TODO]
% stream: ....................[TODO]
% visible: ....................[TODO]
% x0: ....................[TODO]
% dx: ....................[TODO]
% y0: ....................[TODO]
% dy: ....................[TODO]
% xtype: ....................[TODO]
% ytype: ....................[TODO]
% type: ....................[TODO]


%
% function data = extractDataHeatMap(d, xid, yid, CLim, colormap, strip_style)
% % extractDataHeatMap - create a data struct for heat maps
% %   data = extractDataHeatMap(d, xid, yid, CLim, colormap)
% %       d - a data struct from matlab describing a scatter plot
% %       xid,yid - reference axis indices
% %       CLim - a 1x2 vector of extents of the color map
% %       colormap - a kx3 matrix representing the colormap
% %
% % For full documentation and examples, see https://plot.ly/api
%
% data = {};
%
% % copy general
% if strcmp('on', d.Visible)
%     data.visible = true;
% else
%     data.visible = false;
% end
%
% if numel(d.DisplayName)>0
%     data.name = parseText(d.DisplayName);
% else
%     data.showlegend = false;
% end
%
% % copy in data type and values
% data.type = 'heatmap';
% data.showscale = false;
%
% % set reference axis
% if xid==1
%     xid=[];
% end
% if yid==1
%     yid=[];
% end
% data.xaxis = ['x' num2str(xid)];
% data.yaxis = ['y' num2str(yid)];
%
%
% %other attributes
%
% data.z = d.CData;
% if(size(d.XData,2) == 2)
%     data.x = d.XData(1):d.XData(2);
% else
%     data.x = d.XData;
% end
% if(size(d.YData,2) == 2)
%     data.y = d.YData(1):d.YData(2);
% else
%     data.y = d.YData;
% end
% data.zmin = CLim(1);
% data.zmax = CLim(2);
% data.zauto = false;
%
% if ~strip_style
%
%     data.scl = {};
%     for i=1:size(colormap,1)
%         data.scl{i} = {(i-1)/(size(colormap,1)-1), parseColor(colormap(i,:))};
%     end
%
% end
%
% end
%
%
%





% AlphaData = [1]
% AlphaDataMapping = none
% Annotation = [ (1 by 1) hg.Annotation array]
% CData = [ (50 by 50) double array]
% CDataMapping = scaled
% DisplayName =
% XData = [1 50]
% YData = [1 50]
%
% BeingDeleted = off
% ButtonDownFcn =
% Children = []
% Clipping = on
% CreateFcn =
% DeleteFcn =
% BusyAction = queue
% HandleVisibility = on
% HitTest = on
% Interruptible = on
% Parent = [0.0107422]
% Selected = off
% SelectionHighlight = on
% Tag =
% Type = image
% UIContextMenu = []
% UserData = []
% Visible = on

end


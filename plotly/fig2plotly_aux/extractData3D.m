function data = extractData3D(m_data, xid, yid)

%-CHECK FOR MULTIPLE AXES-%
xsource = xid; 
ysource = yid; 

%-SURFACE DATA STRUCTURE- %
image_data = m_data;

%-------------------------------------------------------------------------%

%-surface xaxis-%
data.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-surface yaxis-%
data.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-surface type-%
if ~isvector(image_data.XData) || ~isvector(image_data.YData)
    data.type = 'scatter3d';
else
    data.type = 'surface';
end

%-------------------------------------------------------------------------%

%-surface x-%
data.x = image_data.XData;

if strcmp(data.type,'scatter3d')
    data.x = reshape(data.x,1,size(data.x,1)*size(data.x,2));
end
%-------------------------------------------------------------------------%

%-surface y-%
data.y = image_data.YData;

if strcmp(data.type,'scatter3d')
data.y = reshape(data.y,1,size(data.y,1)*size(data.y,2));
end
%-------------------------------------------------------------------------%

%-surface z-%
data.z = image_data.ZData;  

if strcmp(data.type,'scatter3d')
    data.z = reshape(image_data.ZData,1,size(image_data.ZData,1)*size(image_data.ZData,2));    
end

%-------------------------------------------------------------------------%

%-surface name-%
data.name = image_data.DisplayName;

%-------------------------------------------------------------------------%

%-surface showscale-%
data.showscale = false;

%-------------------------------------------------------------------------%

%-surface visible-%
data.visible = strcmp(image_data.Visible,'on');

%-------------------------------------------------------------------------%

%-surface reversescale-%
data.reversecale = false;

%-------------------------------------------------------------------------%

leg = get(image_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

data.showlegend = showleg;

%-------------------------------------------------------------------------%

end

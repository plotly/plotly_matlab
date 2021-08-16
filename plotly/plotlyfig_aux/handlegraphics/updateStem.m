function obj = updateStem(obj,dataIndex)

%------------------------------------------------------------------------%

%-update line-%
updateLineseries(obj,dataIndex);
stem_temp_data = obj.data{dataIndex};
isstem3d = obj.PlotOptions.is3d;

%------------------------------------------------------------------------%

%-scatter mode-%
stem_temp_data.mode = 'lines+markers';

%------------------------------------------------------------------------%

%-allocated space for extended data-%
xdata_extended = zeros(1,3*length(stem_temp_data.x)); 
ydata_extended = zeros(1,3*length(stem_temp_data.y));

if isstem3d
    zdata_extended = zeros(1,3*length(stem_temp_data.z));
end

%-format x data-%
m = 1; 
for n = 1:length(stem_temp_data.x)
    xdata_extended(m) = stem_temp_data.x(n); 
    xdata_extended(m+1) = stem_temp_data.x(n); 
    xdata_extended(m+2) = nan; 
    m = m + 3; 
end

%-format y data-%
m = 1; 
for n = 1:length(stem_temp_data.y)
    ydata_extended(m) = 0;
 
    if isstem3d
        ydata_extended(m) = stem_temp_data.y(n); 
    end
    
    ydata_extended(m+1) = stem_temp_data.y(n); 
    ydata_extended(m+2) = nan; 
    m = m + 3; 
end

%-format z data-%
if isstem3d
    m = 1; 
    for n = 1:length(stem_temp_data.z)
        zdata_extended(m) = 0;
        zdata_extended(m+1) = stem_temp_data.z(n); 
        zdata_extended(m+2) = nan; 
        m = m + 3; 
    end
end

%-hide every other marker-%
color_temp = cell(1,3*length(stem_temp_data.y));
line_color_temp = cell(1,3*length(stem_temp_data.y));

for n = 1:3:length(color_temp)
    color_temp{n} = 'rgba(0,0,0,0)';
    color_temp{n+1} = stem_temp_data.marker.color;
    color_temp{n+2} = 'rgba(0,0,0,0)';
    line_color_temp{n} = 'rgba(0,0,0,0)';
    line_color_temp{n+1} = stem_temp_data.marker.line.color;
    line_color_temp{n+2} = 'rgba(0,0,0,0)';
end

% add new marker/line colors
stem_temp_data.marker.color = color_temp;
stem_temp_data.marker.line.color = line_color_temp;

%------------------------------------------------------------------------%

stem_temp_data.x = xdata_extended; 
stem_temp_data.y = ydata_extended; 

if isstem3d
    stem_temp_data.z = zdata_extended; 
end

%------------------------------------------------------------------------%

obj.data{dataIndex} = stem_temp_data;

%------------------------------------------------------------------------%

%-put y-zeroline-%
[~, ysource] = findSourceAxis(obj,dataIndex);
eval(['obj.layout.yaxis' num2str(ysource) '.zeroline = true;']);

%------------------------------------------------------------------------%

end
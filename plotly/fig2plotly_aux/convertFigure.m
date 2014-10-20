function [data, layout, title] = convertFigure(f, strip_style)
% convertFigure - converts a matlab figure object into data and layout
% plotly structs.
%   [data, layout] = convertFigure(f)
%       f - root figure object in the form of a struct. Use f = get(gcf); to
%           get the current figure struct.
%       strip_style - boolean, strips all stlying to plotly defaults
%       data - a cell containing plotly data structs
%       layout - a plotly layout struct
%       title - a string with the title of the plot
%
% For full documentation and examples, see https://plot.ly/api


axis_num = numel(f.Children);

if ~strcmp('figure', f.Type)
    error('Input object is not a figure')
end

if axis_num==0
    error('Input figure object is empty!')
end

% placeholders
data = {};
data_counter = 1;
annotations = {};
annot_counter = 1;
bar_counter = 0;
layout = {};
legend={};
x_axis={};
y_axis={};
colorbar=[];
empty_axis=[];
title = '';

% copy general layout fields
layout = extractLayoutGeneral(f, layout, strip_style);

% For each axes
%TOIMPROVE: for now, reverse order of children. This works well for most
%cases, not a perfect solution.
for i=axis_num:-1:1
    
    %get figure child struct
    m_axis = get(f.Children(i));
    
    %test if axes
    if strcmp('axes',m_axis.Type)
        
        %test if legend
        if strcmp('legend',m_axis.Tag)
            legend = extractLegend(m_axis,f.Children(i));
        else
            
            %extract axis and add to axis list
            [xid, yid, x_axis,y_axis] = extractAxes(f.Children(i),m_axis, layout, x_axis, y_axis, strip_style);
            %extract title and add to annotations
            m_title = get(m_axis.Title);
            annot_tmp = extractTitle(f.Children(i),m_title, x_axis{xid}, y_axis{yid}, strip_style);
            if numel(annot_tmp)>0
                if (~onePlot(f))
                    annotations{annot_counter} = annot_tmp;
                    annot_counter = annot_counter+1;
                else
                    layout = setGlobalTitle(annot_tmp,layout);
                end
                title =  annot_tmp.text;
            end
            data_num = numel(m_axis.Children);
            if data_num>0
                % For each data object in a given axes
                for j=1:data_num
                    m_data = get(m_axis.Children(j));
                    
                    %conditions for deretmining the data type
                    data_type = findDataType(m_data, m_axis, m_axis.Children(j));
                    
                    if strcmp('box',data_type)
                        datas = extractDataBox(m_data, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        for dt=1:numel(datas)
                            data{data_counter} = datas{dt};
                            data_counter = data_counter+1;
                        end
                    end
                    
                    if strcmp('heatmap',data_type)
                        data{data_counter} = extractDataHeatMap(m_data, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data_counter = data_counter+1;
                    end
                    if strcmp('contour',data_type)
                        data{data_counter} = extractDataContourMap(m_data, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data_counter = data_counter+1;
                    end
                    if strcmp('colorbar',data_type)
                        empty_axis=[empty_axis; xid, yid];
                        colorbar = extractColorBar(m_axis, strip_style);
                    end
                    if strcmp('scatter',data_type)
                        data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data{data_counter} = dateTimeScale(m_axis, x_axis{xid}, y_axis{yid},data{data_counter});
                        data_counter = data_counter+1;
                    end
                    if strcmp('annotation',data_type)
                        annot_tmp = extractDataAnnotation(m_data, xid, yid, strip_style,m_axis.Children(j));
                        if numel(annot_tmp)>0
                            annotations{annot_counter} = annot_tmp;
                            annot_counter = annot_counter+1;
                        end
                    end
                    if strcmp('histogram',data_type)
                        [data{data_counter}, layout] = extractDataHist(m_data, layout, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data_counter = data_counter+1;
                        bar_counter = bar_counter+1;
                    end
                    if strcmp('area',data_type)
                        data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data{data_counter} = parseFill(m_data, data{data_counter}, m_axis.CLim, f.Colormap, strip_style);
                        %account for datetime
                        data{data_counter} = dateTimeScale(m_axis, x_axis{xid}, y_axis{yid},data{data_counter});
                        data_counter = data_counter+1;
                    end
                    if strcmp('bar',data_type)
                        [data{data_counter}, layout] = extractDataBar(m_data, layout, xid, yid, m_axis.CLim, f.Colormap, strip_style);
                        data_counter = data_counter+1;
                        bar_counter = bar_counter+1;
                    end
                    
                    %---3D SUPPORT---%
                    if strcmp('surfaceplot',data_type)
                        [data{data_counter}] = extractData3D(m_data, xid, yid);
                        data_counter = data_counter + 1; 
                    end
                    
                end
            end
        end
    end
end

%MODIFY WHEN MULTIPLE BARS 
if bar_counter>1 && strcmp(layout.barmode, 'group') && bar_counter > axis_num
    layout.bargroupgap = layout.bargap;
    layout.bargap = 0.3; 
end

% INSERT COLORBAR IN THE FIRST HEATMAP DATA STRUCT
ptr = 1;
while ptr<=numel(data)
    if strcmp('heatmap', data{ptr}.type) || strcmp('contour', data{ptr}.type)
        if numel(colorbar)>0
            data{ptr}.colorbar = colorbar;
            data{ptr}.showscale = true;
        end
        break;
    end
    ptr = ptr+1;
end

% ANNOTATIONS
layout.annotations =  annotations;

% LEGEND
if numel(legend)==0
    layout.showlegend = false;
else
    layout.legend = legend;
    layout.showlegend = true;
end

% ASSEMBLE AXIS
% rescale domain of after removal of empty axis (if any - for colorbar)
if numel(empty_axis)>0
    [x_axis, y_axis] = reevaluateDomains(x_axis, y_axis, empty_axis);
end

for i = 1:numel(x_axis)
    if numel(empty_axis)==0 || ~any(empty_axis(:,1)==i)
        if i==1
            eval('layout.xaxis=x_axis{1};')
        else
            eval(['layout.xaxis' num2str(i) '=x_axis{' num2str(i) '};'])
        end
    end
end

for i = 1:numel(y_axis)
    if numel(empty_axis)==0 || ~any(empty_axis(:,2)==i)
        if i==1
            eval('layout.yaxis=y_axis{1};')
        else
            eval(['layout.yaxis' num2str(i) '=y_axis{' num2str(i) '};'])
        end
    end
end

%INVERT THE ORDER OF THE FIGURES
data_temp = data;
for d = 1:length(data)
    data_temp{d} = data{end-(d-1)};
end
data = data_temp;

end
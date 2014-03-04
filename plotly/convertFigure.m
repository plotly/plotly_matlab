function [data, layout] = convertFigure(f)
% convertFigure - converts a matlab figure object into data and layout
% plotly structs.
%   [data, layout] = convertFigure(f)
%       f - root figure object in the form of a struct. Use f = get(gcf); to
%           get the current figure struct.
%       data - a cell containing plotly data structs
%       layout - a plotly layout struct
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

% copy general layout fields
layout = extractLayoutGeneral(f, layout);

% For each axes
%TEMP: reverse order of children
for i=axis_num:-1:1
    m_axis = get(f.Children(i));
    %TODO:do something about this add/replace thing...
    if strcmp('legend',m_axis.Tag)
        legend = extractLegend(m_axis);
    else
        %TODO:do something about this add/replace thing...
        if strcmp('axes',m_axis.Type) %%&& (strcmp('replace',m_axis.NextPlot) || strcmp('new',m_axis.NextPlot))
            [xid, yid, x_axis y_axis] = extractAxes(m_axis, layout, x_axis, y_axis);
            m_title = get(m_axis.Title);
            annot_tmp = extractTitle(m_title, x_axis{xid}, y_axis{yid});
            if numel(annot_tmp)>0
                annotations{annot_counter} = annot_tmp;
                annot_counter = annot_counter+1;
            end
            data_num = numel(m_axis.Children);
            if data_num>0
                % For each data object in a given axes
                for j=1:data_num
                    m_data = get(m_axis.Children(j));
                    %display(['Data child ' num2str(j) ' is of type ' m_data.Type])
                    
                    if strcmp('line',m_data.Type)
                        %line scatter plot
                        data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap);
                        data_counter = data_counter+1;
                    end
                    if strcmp('text',m_data.Type)
                        %annotation
                        annot_tmp = extractDataAnnotation(m_data, xid, yid);
                        if numel(annot_tmp)>0
                            annotations{annot_counter} = annot_tmp;
                            annot_counter = annot_counter+1;
                        end
                        
                    end
                    if strcmp('patch',m_data.Type)
                        %area plot
                        data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap);
                        data{data_counter} = parseFill(m_data, data{data_counter}, m_axis.CLim, f.Colormap);
                        data_counter = data_counter+1;
                    end
                    if strcmp('hggroup',m_data.Type)
                        
                        %TODO: improve condition to differentiate between
                        %scatter and bar chart
                        if isfield(m_data, 'BarLayout')
                            %bar plot
                            [data{data_counter} layout] = extractDataBar(m_data, layout, xid, yid, m_axis.CLim, f.Colormap);
                            data_counter = data_counter+1;
                            % copy in bar gaps
                            layout.bargap = 1-m_data.BarWidth;
                            layout.barmode = m_data.BarLayout(1:end-2);
                            bar_counter = bar_counter+1;
                        else
                            if isfield(m_data, 'Marker') && numel(m_data.Marker)>0
                                %scatter plot
                                data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap);
                                data_counter = data_counter+1;
                            end
                            if isfield(m_data, 'EdgeColor') && isfield(m_data, 'FaceColor')
                                %area plot
                                data{data_counter} = extractDataScatter(m_data, xid, yid, m_axis.CLim, f.Colormap);
                                data{data_counter} = parseFill(m_data, data{data_counter}, m_axis.CLim, f.Colormap);
                                data_counter = data_counter+1;
                            end
                        end
                        
                    end
                    
                    if strcmp('text',m_data.Type)
                        annot_tmp = extractDataAnnotation(m_data, xid, yid);
                        if numel(annot_tmp)>0
                            annotations{annot_counter} = annot_tmp;
                            annot_counter = annot_counter+1;
                        end
                        
                    end
                    
                    
                end
            end
            
            
        end
    end
end

% BAR MODIFY
if bar_counter>1 && strcmp(layout.barmode, 'group')
    layout.bargroupgap = layout.bargap;
    layout.bargap = 0.3;
end

% ANNOTATIONS
layout.annotations = annotations;


% LEGEND
if numel(legend)==0
    layout.showlegend = false;
else
    layout.legend = legend;
    layout.showlegend = true;
end


% Assemble axis
for i = 1:numel(x_axis)
    if i==1
        eval('layout.xaxis=x_axis{1};')
    else
        eval(['layout.xaxis' num2str(i) '=x_axis{' num2str(i) '};'])
    end
end

for i = 1:numel(y_axis)
    if i==1
        eval('layout.yaxis=y_axis{1};')
    else
        eval(['layout.yaxis' num2str(i) '=y_axis{' num2str(i) '};'])
    end
end


end
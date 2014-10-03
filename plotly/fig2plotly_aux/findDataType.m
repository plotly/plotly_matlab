function data_type = findDataType(m_data, m_axis, dataHan)

data_type = [];

if strcmp('image',m_data.Type)
    %heatmap plot
    %test if image plot is the colorbar
    if ~strcmp('Colorbar',m_axis.Tag)
        data_type = 'heatmap';
        
    else
        data_type = 'colorbar';
    end
end
if strcmp('surface',m_data.Type)
    %heatmap plot
    %test if image plot is the colorbar
    if ~strcmp('Colorbar',m_axis.Tag)
        data_type = 'heatmap';
    else
        data_type = 'colorbar';
    end
end
if strcmp('line',m_data.Type)
    data_type = 'scatter';
end
if strcmp('text',m_data.Type)
    data_type = 'annotation';
end

if strcmp('patch',m_data.Type)
    %TOIMPROVE: histogram appears as 'patch' as well, need
    %to differentiate!!!
    % For now, test if XData/YData are 4 by k matrices and rectangular
    % The matlab fig doesnt keep the data, only the
    % rectagle geometries (thus the 'patch' type), so
    % we can only infer from the shapes a BAR CHART
    if (size(m_data.XData,1)==4 && ...
            all(m_data.XData(1,:)==m_data.XData(2,:)) && ...
            all(m_data.XData(3,:)==m_data.XData(4,:)) && ...
            all(m_data.YData(1,:)==m_data.YData(4,:)) && ...
            all(m_data.YData(2,:)==m_data.YData(3,:)))
        data_type = 'histogram';
    else
        
        data_type = 'area';
    end
    
end
if strcmp('hggroup',m_data.Type)
    
    %TOIMPROVE: improve condition to differentiate between
    %scatter and bar chart
    if isfield(m_data, 'BarLayout')
        data_type = 'bar';
        
    else
        if isfield(m_data, 'Marker') && numel(m_data.Marker)>0
            data_type = 'scatter';
        end
        if isfield(m_data, 'EdgeColor') && isfield(m_data, 'FaceColor')
            data_type = 'area';
            
        end
    end
    
    %TOIMPORVE: condition to detect contour plot
    if isfield(m_data, 'LevelStep')
        data_type = 'contour';
    end
    
    %if none of the above, assume box plot
    if numel(data_type)==0
        data_type = 'box';
    end
    
    m_child  = m_data.Children(1);
    if (m_child > 0)
        m_child_type= get(m_child,'Type');
        if strcmpi(m_child_type,'line');
            data_type = 'scatter';
        end
    end
    
end

%----3D SUPPORT----%
if strcmp(handle(dataHan).classhandle.name,'surfaceplot')
    data_type = 'surfaceplot';
end

end
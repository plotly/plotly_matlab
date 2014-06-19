function data = parseFill(d, data, CLim, colormap, strip_style)
% parseFill - parses fill attribute for area plots
%   data = parseFill(d, data, limits, colormap)
%       d - a data struct from matlab describing an annotation
%       data - a plotly annotation struct
%       CLim - a 1x2 vector of extents of the color map
%       colormap - a kx3 matrix representing the colormap
% 
% For full documentation and examples, see https://plot.ly/api

data.fill = 'tozeroy';

%get child
if strcmp(d.Type, 'patch')
    if ~strip_style
        colors = setColorProperty(d.FaceColor,d.CData, CLim, colormap);
        data.fillcolor = colors{1};
    end
end
if strcmp(d.Type, 'hggroup')
    if ~strip_style
        m_data = get(d.Children(1));
        colors = setColorProperty(m_data.FaceColor,m_data.CData, CLim, colormap);
        if numel(colors{1})>0
            data.fillcolor = colors{1};
        end
    end
    %assume they are in right order
    %TODO: improve data ordering
    data.y = m_data.YData(2:(numel(m_data.YData)-1)/2+1);
end





end
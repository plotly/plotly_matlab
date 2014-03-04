function marker_str = parseMarker(d, CLim, colormap)

%build marker struct
    marker_str = [];
    % not supported: *, X, diamond, pentagram, hexagram
    if strcmp('o', d.Marker)
        marker_str.symbol = 'circle';
    end
    if strcmp('+', d.Marker)
        marker_str.symbol = 'cross';
    end
    if strcmp('square', d.Marker) || strcmp('s', d.Marker)
        marker_str.symbol = 'square';
    end
    if strcmp('^', d.Marker)
        marker_str.symbol = 'triangle-up';
    end
    if strcmp('V', d.Marker)
        marker_str.symbol = 'triangle-down';
    end
    if strcmp('>', d.Marker)
        marker_str.symbol = 'triangle-right';
    end
    if strcmp('<', d.Marker)
        marker_str.symbol = 'triangle-left';
    end
    
    marker_str.line.width = d.LineWidth;
    
    %SIZE
    if isfield(d, 'MarkerSize')
        marker_str.size = d.MarkerSize;
    end
    if isfield(d, 'SizeData')
        if numel(d.SizeData)==1
           marker_str.size =  2.7*sqrt(d.SizeData/3.14);
        end
        if numel(d.SizeData)==numel(d.XData)
           marker_str.size =  2.7*sqrt(d.SizeData/3.14);
        end
    end
    
    %COLOR
    if isfield(d, 'CData')
        color_ref = d.CData;
    else
        color_ref = d.Color;
    end
    
    color_field = d.MarkerEdgeColor;
    
    colors = setColorProperty(color_field, color_ref, CLim, colormap);
    if numel(colors)==1
        if numel(colors{1})>0
            marker_str.line.color = colors{1};
        end
    else
        marker_str.line.color = colors;
    end
    
    color_field = d.MarkerFaceColor;
    display(color_field)
    colors = setColorProperty(color_field, color_ref, CLim, colormap);
    if numel(colors)==1
        if numel(colors{1})>0
            marker_str.color = colors{1};
        end
    else
        marker_str.color = colors;
    end
    
%     
%     %direct colors?
%     if size(color_ref, 2)==3
%         
%         %single color
%         if size(color_ref, 1)==1
%             if strcmp('flat', d.MarkerEdgeColor) || strcmp('auto', d.MarkerEdgeColor)
%                 marker_str.line.color = parseColor(color_ref);
%             else
%                 marker_str.line.color = parseColor(d.MarkerEdgeColor);
%             end
%             if strcmp('flat', d.MarkerFaceColor) || strcmp('auto', d.MarkerFaceColor)
%                 marker_str.color = parseColor(color_ref);
%             else
%                 marker_str.color = parseColor(d.MarkerFaceColor);
%             end
%         else
%             %TODO: multiple colors
%         end
%         
%     else
%         if size(color_ref, 1)==numel(d.XData)
%             
%             if strcmp('flat', d.MarkerEdgeColor) || strcmp('auto', d.MarkerEdgeColor)
%                 marker_str.line.color = mapColors(color_ref, CLim, colormap);
%             else
%                 marker_str.line.color = parseColor(d.MarkerEdgeColor);
%             end
%             if strcmp('flat', d.MarkerFaceColor) || strcmp('auto', d.MarkerFaceColor)
%                 marker_str.color = mapColors(color_ref, CLim, colormap);
%             else
%                 marker_str.color = parseColor(d.MarkerFaceColor);
%             end
%         end
%     end
%     
%     if strcmp('none', d.MarkerEdgeColor)
%         marker_str.line.color = 'rgba(0,0,0,0)';
%     end
%     if strcmp('none', d.MarkerFaceColor)
%         marker_str.color = 'rgba(0,0,0,0)';
%     end
%     
    
end
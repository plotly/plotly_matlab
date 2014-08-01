function marker_str = parseMarker(d, CLim, colormap)

%build marker struct
marker_str = [];

if isfield(d, 'Marker')
    isClosed = false;
    switch d.Marker
        case '.'
            marker_str.symbol = 'circle';
        case 'o'
            marker_str.symbol = 'circle';
            isClosed = true;
        case 'x'
            marker_str.symbol = 'x-thin-open';
        case '+'
            marker_str.symbol = 'cross-thin-open';
        case '*'
            marker_str.symbol = 'asterisk-open';
        case {'s','square'}
            marker_str.symbol = 'square';
            isClosed = true;
        case {'d','diamond'}
            marker_str.symbol = 'diamond';
            isClosed = true;
        case 'v'
            marker_str.symbol = 'triangle-down';
            isClosed = true;
        case '^'
            marker_str.symbol = 'triangle-up';
            isClosed = true;
        case '<'
            marker_str.symbol = 'triangle-left';
            isClosed = true;
        case '>'
            marker_str.symbol = 'triangle-right';
            isClosed = true;
        case {'p','pentagram'}
            marker_str.symbol = 'star';
            isClosed = true;
        case {'h','hexagram'}
            marker_str.symbol = 'hexagram';
            isClosed = true;
    end
end

%marker line width
marker_str.line.width = d.LineWidth;

%SIZE
if isfield(d, 'MarkerSize')
    marker_str.size =  d.MarkerSize;
    if d.Marker == '.'
        marker_str.size = sqrt(d.MarkerSize);
    end
end

if isfield(d, 'SizeData')
    if numel(d.SizeData)==1
        marker_str.size =  sqrt(d.SizeData);
    end
    if numel(d.SizeData)==numel(d.XData)
        marker_str.size =  sqrt(d.SizeData);
    end
end


%%%%%%%%%%%%%%%
%COLOR HANDLING%
%%%%%%%%%%%%%%%
try
    
    if isfield(d,'CData')
        color_ref = d.CData;
    else
        color_ref = d.Color;
    end
    
    %MARKER FACE
    if isClosed
        
        color_field = d.MarkerFaceColor;
        colors = setColorProperty(color_field, color_ref, CLim, colormap,d);
        
        if numel(colors)==1
            if numel(colors{1})>0
                marker_str.color = colors{1};
            end
        else
            marker_str.color = colors;
        end
        
    end

    %MARKER EDGE
    color_field = d.MarkerEdgeColor;
    colors = setColorProperty(color_field, color_ref, CLim, colormap,d);
    
    if numel(colors)==1
        if numel(colors{1})>0
            if ~isClosed
                marker_str.color = colors{1};
            end
            marker_str.line.color = colors{1};
        end
    else
        if ~isClosed
            marker_str.color = colors;
        end
        marker_str.line.color = colors;
    end
    
end
end



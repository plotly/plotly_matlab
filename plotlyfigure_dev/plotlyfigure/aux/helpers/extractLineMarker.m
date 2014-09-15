function [line, marker] = extractLineMarker(line_data)

%-AXIS STRUCTURE-%
axis_data = get(line_data.Parent);

%-FIGURE STRUCTURE-%
figure_data = get(axis_data.Parent);

%-INITIALIZE OUTPUT-%
line = struct(); 
marker = struct(); 

%-------------------------------------------------------------------------%

%-MARKER SIZE-%
marker.size = line_data.MarkerSize;

%-------------------------------------------------------------------------%


%-MARKER SYMBOL (STYLE)-%
if ~strcmp(line_data.Marker,'none')
    
    switch line_data.Marker
        case '.'
            marksymbol = 'circle';
        case 'o'
            marksymbol = 'circle';
        case 'x'
            marksymbol = 'x-thin-open';
        case '+'
            marksymbol = 'cross-thin-open';
        case '*'
            marksymbol = 'asterisk-open';
        case {'s','square'}
            marksymbol = 'square';
        case {'d','diamond'}
            marksymbol = 'diamond';
        case 'v'
            marksymbol = 'triangle-down';
        case '^'
            marksymbol = 'triangle-up';
        case '<'
            marksymbol = 'triangle-left';
        case '>'
            marksymbol = 'triangle-right';
        case {'p','pentagram'}
            marksymbol = 'star';
        case {'h','hexagram'}
            marksymbol = 'hexagram';
    end
    
    marker.symbol = marksymbol;
end

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH (STYLE)-%
marker.line.width = line_data.LineWidth;

if(~strcmp(line_data.LineStyle,'none'))
    
    %-SCATTER LINE COLOR (STYLE)-%
    col = 255*line_data.Color;
    line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-SCATTER LINE WIDTH (STYLE)-%
    line.width = line_data.LineWidth;
    
    %-SCATTER LINE DASH (STYLE)-%
    switch line_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    line.dash = LineStyle;
end

%-------------------------------------------------------------------------%

%--MARKER FILL COLOR (STYLE)--%

MarkerColor = line_data.MarkerFaceColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(line_data.Marker,filledMarkerSet);

if filledMarker
    if isnumeric(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                if ~strcmp(axis_data.Color,'none')
                    col = 255*axis_data.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                else
                    col = 255*figure_data.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                end
        end
    end
    
    marker.color = markercolor;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE COLOR (STYLE)-%

MarkerLineColor = line_data.MarkerEdgeColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(line_data.Marker,filledMarkerSet);

if isnumeric(MarkerLineColor)
    col = 255*MarkerLineColor;
    markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
else
    switch MarkerLineColor
        case 'none'
            markerlinecolor = 'rgba(0,0,0,0)';
        case 'auto'
            col = 255*line_data.Color;
            markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

if filledMarker
    marker.line.color = markerlinecolor;
else
    marker.color = markerlinecolor;
end
end
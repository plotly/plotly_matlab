function marker = extractLineMarker(line_data)

% EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS 
% OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES, 
% STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

%-------------------------------------------------------------------------%

%-INITIALIZE OUTPUT-%
marker = struct(); 

%-------------------------------------------------------------------------%

%-MARKER SIZE-%
marker.size = line_data.MarkerSize;

if length(marker.size) == 1
    marker.size = 0.6*marker.size;
end

%-------------------------------------------------------------------------%

%-MARKER SYMBOL-%
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
    if isfield(line_data, 'MarkerIndices')
        marker.maxdisplayed=length(line_data.MarkerIndices)+1;
    end
end

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH-%
marker.line.width = line_data.LineWidth;

%-------------------------------------------------------------------------%

filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(line_data.Marker,filledMarkerSet);

%-------------------------------------------------------------------------%

%--MARKER FILL COLOR--%

MarkerColor = line_data.MarkerFaceColor;

if filledMarker
    if isnumeric(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                markercolor = 'rgba(0, 0.4470, 0.7410,1)';
        end
    end
    
    marker.color = markercolor;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE COLOR-%

MarkerLineColor = line_data.MarkerEdgeColor;

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
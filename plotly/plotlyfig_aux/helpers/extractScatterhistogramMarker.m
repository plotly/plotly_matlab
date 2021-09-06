function marker = extractScatterhistogramMarker(patch_data, t)

% EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS
% OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
% BARSERIES, CONTOURGROUP, SCATTERGROUP.

%-------------------------------------------------------------------------%

%-AXIS STRUCTURE-%
axis_data = get(ancestor(patch_data.Parent,'axes'));

%-FIGURE STRUCTURE-%
figure_data = get(ancestor(patch_data.Parent,'figure'));

%-INITIALIZE OUTPUT-%
marker = struct();

%-------------------------------------------------------------------------%

%-MARKER SIZE (STYLE)-%
marker.size = patch_data.MarkerSize(t)*0.20;

%-------------------------------------------------------------------------%

%-MARKER SYMBOL (STYLE)-%
if ~strcmp(patch_data.MarkerStyle(t),'none')

    switch patch_data.MarkerStyle(t)
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
marker.line.width = patch_data.LineWidth(t);

%-------------------------------------------------------------------------%

%--MARKER COLOR--%

%-figure colormap-%
colormap = figure_data.Colormap;

% marker face color
MarkerColor = patch_data.Color(t, :);

filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(patch_data.MarkerStyle(t), filledMarkerSet);

if filledMarker && strcmp(patch_data.MarkerFilled, 'on')
    
    if isnumeric(MarkerColor)
        markercolor = sprintf('rgb(%f,%f,%f)', 255*MarkerColor);
    else

        switch MarkerColor
            
            case 'none'
                
                markercolor = 'rgba(0,0,0,0)';
                
            case 'auto'
                
                if ~strcmp(axis_data.Color,'none')
                    col = 255*axis_data.Color;
                else
                    col = 255*figure_data.Color;
                end
                
                markercolor  = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                
                
            case 'flat'

                for n = 1:length(patch_data.CData)

                    capCD = max(min(patch_data.CData(n),axis_data.CLim(2)),axis_data.CLim(1));
                    scalefactor = (capCD - axis_data.CLim(1))/diff(axis_data.CLim);
                    col =  255*(colormap(1 + floor(scalefactor*(length(colormap)-1)),:));
                    
                    markercolor{n} = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                    
                end
        end
    end
    
    marker.color = markercolor;
    
end

if filledMarker
    marker.line.color = markercolor;
end

%-------------------------------------------------------------------------%

end

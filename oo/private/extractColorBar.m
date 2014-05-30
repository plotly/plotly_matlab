function colorbar = extractColorBar(d, strip_style)
% extractColorBar - create a data struct for the colorbar
%   data = extractDataHeatMap(d, strip_style)
%       d - a data struct from matlab describing a scatter plot
%       strip_style - boolean, if true, uses default plotly styling
% 
% For full documentation and examples, see https://plot.ly/api

colorbar = {};

if ~strip_style

    colorbar.titleside = 'right';
    colorbar.xanchor='right';
    %TICKS
    if strcmp(d.TickDir, 'in')
        colorbar.ticks = 'inside';
    else
        colorbar.ticks = 'outside';
    end
    
    %SIZE AND TICKS  
    colorbar.xpad = 0;
    colorbar.ypad = 0;

    colorbar.lenmode = 'fraction';
    colorbar.thicknessmode = 'fraction';
    
    %matlab colorbars can be vertical or horizontal, we need to find the
    %dominant dimension and output the plotly vertical colorbar with that
    %dimension's properties
    
    color_ticks = [];
    if numel(d.XTick)>numel(d.YTick)
        color_ticks = d.XTick;
        colorbar.thickness = d.Position(4);
        colorbar.len = d.Position(3);
    else
        color_ticks = d.YTick;
        colorbar.thickness = d.Position(3);
        colorbar.len = d.Position(4);
    end
    colorbar.autotick = false;
    if numel(color_ticks)>0
        colorbar.tick0 = color_ticks(1);
        colorbar.dtick = color_ticks(2)-color_ticks(1);
        colorbar.nticks = numel(color_ticks);
    end
    
    %TODO: should this multiplier remain?
    if strcmp(d.FontUnits, 'points')
        colorbar.tickfont.size = 1.3*d.FontSize;
    end
    %TODO: additional font properties (when implemented, needs to keep in
    %mind that not all matlab fonts are supported by plotly)
    
    
    
end

end
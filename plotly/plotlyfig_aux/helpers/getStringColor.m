function stringColor = getStringColor(numColor, opacity)
    if nargin == 1
        stringColor = sprintf("rgb(%d,%d,%d)", numColor);
    elseif nargin == 2
        stringColor = sprintf("rgba(%d,%d,%d,%f)", numColor, opacity);
    else
        disp("Too many input arguments for getStringColor function.")
    end
end

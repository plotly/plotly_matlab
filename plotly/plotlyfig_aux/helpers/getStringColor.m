function stringColor = getStringColor(numColor, opacity)
    
    if nargin == 1
        stringColor = sprintf('rgb(%f,%f,%f)', numColor);

    elseif nargin == 2
        stringColor = sprintf('rgba(%f,%f,%f,%f)', numColor, opacity);
        
    else
        disp('Too many input arguments for getStringColor function.')
    end
end
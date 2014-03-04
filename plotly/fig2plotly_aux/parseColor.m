function color_rgb = parseColor(c)

% c is a 1x3 vector
c_int = floor(c*255);
color_rgb = ['rgb(' num2str(c_int(1)) ',' num2str(c_int(2)) ',' num2str(c_int(3)) ')'];

end
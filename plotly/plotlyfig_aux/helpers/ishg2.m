%http://www.mathworks.com/matlabcentral/answers/136834-determine-if-using-hg2
function tf = ishg2(fig)
try
    tf = ~graphicsversion(fig, 'handlegraphics');
catch
    tf = false;
end
end
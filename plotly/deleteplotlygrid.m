function response = deleteplotlygrid(gridID)

%-create plotlygrid-%
g = plotlygrid; 
g.ID = gridID; 

%-delete remote-%
g.deleteRemote; 

%-ouput response-%
response = g.Caller.Response; 

end
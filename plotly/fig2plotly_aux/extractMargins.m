function [l,r,b,t] = extractMargins(f)
%helper function used to set the margins of the plot

%get Figure struct
fig = get(f);

%get children
childHan = get(f,'Children');

%set default margins to size of figure 
l = fig.Position(3);
r = fig.Position(3);
b = fig.Position(4);
t = fig.Position(4);

for i = 1:length(childHan)
    
    %set children units to pixels
    unitsC = get(childHan(i),'Units');
    set(childHan(i),'Units','pixels');
    
    %get the current axes child
    curChild = get(childHan(i));
    
    if strcmpi(curChild.Type,'axes')
        templ = curChild.Position(1);
        l = min(l,templ); 
        tempr = (fig.Position(3) -  curChild.Position(1) - curChild.Position(3));
        r = min(r,tempr); 
        tempb = curChild.Position(2);
        b = min(b,tempb); 
        tempt = (fig.Position(4) - curChild.Position(2) - curChild.Position(4));
        t = min(t,tempt);   
    end
    
    %revert axes units
    set(childHan(i),'Units',unitsC); 
    
end

end


function check = emptyStringText(obj)
check = false;
try
    check = strcmpi(get(obj,'Type'),'text') && isempty(get(obj,'String')); 
end
end
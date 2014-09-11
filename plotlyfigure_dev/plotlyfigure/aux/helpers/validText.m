function check = validText(obj)
check = false;
try
    check = isstrprop(get(obj,'String'),'alpha'); 
end
end
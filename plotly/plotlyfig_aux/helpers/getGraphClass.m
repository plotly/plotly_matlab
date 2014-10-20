function gc = getGraphClass(obj)
if ishg2(obj)
    gc = lower(obj.Type);
else
    gc = lower(handle(obj).classhandle.name);
end
end
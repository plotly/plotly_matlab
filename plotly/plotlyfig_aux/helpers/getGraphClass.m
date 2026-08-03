function gc = getGraphClass(obj)
    gc = lower(get(obj, 'Type'));
end

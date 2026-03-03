function check = isHG2
    %check for HG2 update
    persistent cachedCheck
    if isempty(cachedCheck)
        cachedCheck = ~verLessThan('matlab','8.4.0');
    end
    check = cachedCheck;
end

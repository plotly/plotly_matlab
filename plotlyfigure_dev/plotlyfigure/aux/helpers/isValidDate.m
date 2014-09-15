function valid = isValidDate(string_to_check)
try
    datevec(string_to_check);
    valid = true;
catch
    valid = false;
end
end
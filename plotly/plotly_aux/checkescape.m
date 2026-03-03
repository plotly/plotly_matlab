function escaped_val = checkescape(val)
    %adds '\' escape character if needed
    escaped_val = strrep(val, '\', '\\');
    escaped_val = strrep(escaped_val, '"', '\"');
    escaped_val = strrep(escaped_val, '/', '\/');
end

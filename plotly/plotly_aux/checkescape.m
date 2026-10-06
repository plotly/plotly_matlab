function escaped_val = checkescape(val)
    escaped_val = strrep(val, '\', '\\');
    escaped_val = strrep(escaped_val, '"', '\"');
    escaped_val = strrep(escaped_val, '/', '\/');
    escaped_val = strrep(escaped_val, sprintf('\n'), '\n');
    escaped_val = strrep(escaped_val, sprintf('\r'), '\r');
    escaped_val = strrep(escaped_val, sprintf('\t'), '\t');
    escaped_val = strrep(escaped_val, sprintf('\b'), '\b');
    escaped_val = strrep(escaped_val, sprintf('\f'), '\f');

    ctrl_mask = escaped_val < 32;
    if any(ctrl_mask)
        bad_chars = unique(escaped_val(ctrl_mask));
        for k = 1:numel(bad_chars)
            c = bad_chars(k);
            u_esc = sprintf('\\u%04x', double(c));
            escaped_val = strrep(escaped_val, c, u_esc);
        end
    end
end

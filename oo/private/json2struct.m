function st = json2struct(j)

    % everything is between double quotes. sweet!
    st = struct();
    idx = strfind(j,'"');    
    for i = 1:4:(length(idx)-2)
        jf = j( (idx(i)+1):(idx(i+1)-1) );
        jv = j( (idx(i+2)+1):(idx(i+3)-1) );
        st = setfield(st, jf, jv);
    end
end
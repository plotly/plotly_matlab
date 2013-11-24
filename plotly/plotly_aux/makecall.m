function st = makecall(args, un, key, origin, structargs)
    version = '0.2';
    platform = 'MATLAB';
    
    args = m2json(args);
    kwargs = m2json(structargs);
    url = 'https://plot.ly/clientresp';
    payload = {'platform', platform, 'version', version, 'args', args, 'un', un, 'key', key, 'origin', origin, 'kwargs', kwargs};

    resp = urlread(url, 'Post', payload);
    st = json2struct(resp);

    f = fieldnames(st);
    if any(strcmp(f,'error'))
        error(st.error)                    
    end
    if any(strcmp(f,'warning'))
        fprintf(st.warning)
    end
    if any(strcmp(f,'message'))
        fprintf(st.message)
    end
    if any(strcmp(f,'filename'))
        plotlysession(st.filename)
    end
end

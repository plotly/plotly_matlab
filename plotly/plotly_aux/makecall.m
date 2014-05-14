function st = makecall(args, un, key, origin, structargs)
    version = '0.5.5';
    platform = 'MATLAB';
    
    args = m2json(args);
    kwargs = m2json(structargs);
    url = 'https://plot.ly/clientresp';
    payload = {'platform', platform, 'version', version, 'args', args, 'un', un, 'key', key, 'origin', origin, 'kwargs', kwargs};

    if (is_octave)
        % use octave super_powers
        resp = urlread(url, 'post', payload);
    else
        % do it matlab way
        resp = urlread(url, 'Post', payload);
    end

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

% subfunction that checks if we are in octave
function r = is_octave ()
    persistent x;
    if (isempty (x))
        x = exist ('OCTAVE_VERSION', 'builtin');
    end
    r = x;
end

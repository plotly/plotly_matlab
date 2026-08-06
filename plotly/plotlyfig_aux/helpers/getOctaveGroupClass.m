function cls = getOctaveGroupClass(handle)
    % GETOCTAVEGROUPCLASS Identify the plot type behind an Octave
    % hggroup object. Octave wraps bar, area, stairs, stem, quiver,
    % errorbar, contour and rectangle plots in hggroup objects; each
    % function marks them with custom properties or "__appdata__".
    % Returns a string matching the update function to use, or the
    % empty string if the group cannot be identified.
    cls = '';

    if ~is_octave()
        return
    end

    try
        ad = get(handle, '__appdata__');
        if isstruct(ad) && isfield(ad, '__creator__')
            creator = ad.__creator__;
            if strcmp(creator, '__stem__')
                cls = 'stem';
            elseif strcmp(creator, '__quiver__')
                cls = 'quiver';
            elseif strcmp(creator, '__errplot__')
                cls = 'errorbar';
            elseif strcmp(creator, '__contour__')
                cls = 'contour';
            elseif strcmp(creator, '__scatter__')
                cls = 'scatter';
            end
        end
    catch
    end

    if ~isempty(cls)
        return
    end

    props = {};
    try
        props = fieldnames(get(handle));
    catch
    end

    if any(strcmp(props, 'barlayout')) || any(strcmp(props, 'barwidth'))
        cls = 'bar';
    elseif any(strcmp(props, 'areagroup'))
        cls = 'area';
    elseif any(strcmp(props, 'curvature')) || any(strcmp(props, 'position'))
        cls = 'rectangle';
    elseif any(strcmp(props, 'xdata')) && any(strcmp(props, 'ydata')) ...
            && any(strcmp(props, 'color')) && any(strcmp(props, 'marker'))
        % stairs hggroups expose the line properties directly
        kids = get(handle, 'Children');
        if numel(kids) >= 1 && strcmp(get(kids(1), 'Type'), 'line')
            cls = 'stairs';
        end
    end
end

function persistplotlypath(plotlyFolderPath)
    % keeps plotlyFolderPath on the search path in future sessions without
    % writing outside the user's own files: Octave's savepath writes the
    % per-user ~/.octaverc, while MATLAB's normally writes MATLAB's own
    % pathdef.m inside matlabroot, so MATLAB users get the line to add to
    % their startup.m
    if is_octave
        try
            savepath;
            return
        catch
        end
        startupFile = '~/.octaverc';
    else
        startupFile = 'startup.m';
    end
    fprintf(['\nPlotly is on the search path for this session. To keep it ', ...
             'there in future sessions,\nadd this line to your %s:\n\n', ...
             '    addpath(genpath(''%s''));\n'], ...
            startupFile, strrep(plotlyFolderPath, '''', ''''''));
end

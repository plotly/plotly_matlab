function printplotlypathhint(plotlyFolderPath)
    % prints the line that keeps plotlyFolderPath on the search path in
    % future sessions; setup leaves editing startup files to the user
    if is_octave
        startupFile = '~/.octaverc';
    else
        startupFile = 'startup.m (in the folder that userpath returns)';
    end
    fprintf(['\nPlotly is on the search path for this session. To keep it ', ...
             'there in future sessions,\nadd this line to your %s:\n\n', ...
             '    addpath(genpath(''%s''));\n'], ...
            startupFile, strrep(plotlyFolderPath, '''', ''''''));
end

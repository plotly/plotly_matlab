function [warnings] = addplotlystartup(startupPaths)
%[1]looks at statup.m files specified by the entries of startupPaths
%[2]appends the addplotly function to startup.m files (if not already present)
%[3]checks for other plotly addpath calls within any startup.m and outputs warning

%output warnings
warnings = cell(size(startupPaths)); 

for locs = 1:size(startupPaths,1);
    %addpath string for Plotly API
    addString = 'addpath(genpath(fullfile(matlabroot,''toolbox'',''plotly'')),''-end'');';
    %open current startup.m to read
    currentStartupID = fopen(startupPaths{locs},'r');
    if currentStartupID == -1, error('plotly:startupRead',...
            ['Shoot! It looks like something went wrong reading the file: ' ...
            '\n\t\t\t' startupPaths{locs} '\n\t\t\t' ...
            'Please contact your system admin. or chuck@plot.ly for more \n\t\t\tinformation. In the ' ...
            'mean time you can add the Plotly API \n\t\t\tto your search path manually whenever you need it! \n']);
    end
    %check for any instances of the addplotlyapi function
    startupScan = textscan(currentStartupID, '%s', 'delimiter', '\n', 'whitespace', '');
    startupLines = startupScan{1};
    Index = find(strcmp(startupLines,addString));
    otherPlotlyOccurrence = findstr(fileread(startupPaths{locs}),'plotly');
    %if addString is not in startup.m add it
    if(~any(Index));
        %reopen current startup.m with new permission
        currentStartupID = fopen(startupPaths{locs},'a+');
        if currentStartupID == -1, error('plotly:startupWrite',...
                ['Shoot! It looks like you might not have write permission for: ' ...
                '\n\t\t\t' startupPaths{locs} '\n\t\t\t' ...
                'Please contact your system admin. or chuck@plot.ly for more \n\t\t\tinformation. In the ' ...
                'mean time you can add the Plotly API \n\t\t\tto your search path manually whenever you need it! \n']);
        end
        fprintf(currentStartupID,['\n' addString]);
    end
    if(length(Index) ~= length(otherPlotlyOccurrence));
        warnings{locs} = ['\n\n[WARNING]: \t\t --- \t We found an addpath specification for another version of Plotly at:\n\t\t\t ' ...
                                startupPaths{locs} '\n\t\t\t you may be forcing MATLAB to look for an older version of Plotly!\n\n']; 
    else
        warnings{locs} = ''; 
    end
    fclose(currentStartupID);
end
end


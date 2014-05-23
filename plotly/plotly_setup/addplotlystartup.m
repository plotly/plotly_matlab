function addplotlystartup(startupPaths)
%[1]looks at statup.m files specified by the entries of startupPaths
%[2]appends the addplotly function to startup.m files (if not already present)

for locs = 1:size(startupPaths,1);
    %addpath string for Plotly API
    addString = 'addpath(genpath(fullfile(matlabroot,''toolbox'',''plotly'')));';
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
    fclose(currentStartupID);
end
end


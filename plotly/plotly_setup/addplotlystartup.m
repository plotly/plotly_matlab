function addplotlystartup(startupPaths)
%looks at statup.m files specified by the entries of startupPaths
%appends the addplotly function to startup.m files (if not already present)
for locs = 1:size(startupPaths,1);
    %addpath string for Plotly API
    addString = 'addpath(genpath(fullfile(matlabroot,''toolbox'',''plotly'')));';
    %open current startup.m
    currentStartupID = fopen(startupPaths{locs},'r');
    if currentStartupID == -1, error('Cannot open file. Super weird! Contact Chuck@plot.ly'), end 
    %check for any instances of the addplotlyapi function
    startupScan = textscan(currentStartupID, '%s', 'delimiter', '\n', 'whitespace', '');
    startupLines = startupScan{1};
    Index = find(strcmp(startupLines,addString));
    %reopen current startup.m with new permission
    currentStartupID = fopen(startupPaths{locs},'a+');
    if currentStartupID == -1, error('Cannot open file. Super weird! Contact Chuck@plot.ly'), end 
    %if addString is not in startup.m add it
    if(~any(Index));
        fprintf(currentStartupID,['\n' addString]);
    end
    fclose(currentStartupID);
end
end


function removed = plotlycleanup

% cleans up any old Plotly API MATLAB library files and folders 

% initialize output
removed = {};

%----REMOVE FILES----%
REMOVEFILES = {'plotly.m'};

%----REMOVE FOLDERS----%
REMOVEFOLDERS = {'fig2plotly_aux'};


%----check for local Plotly instances----%
try
    plotlyScriptDirs = which('plotly.m','-all');
    
    if isempty(plotlyScriptDirs);
        error('plotly:missingScript',...
            ['\n\nWe were unable to locate plotly.m. Please Add this\n',...
            'script to your MATLAB search path and try again.\n\n']);
    end
    
    
catch exception %locating plotly error catch...
    fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    return
end

% find the location of all plotly/ directories
plotlyDirs = findPlotlyDirs(plotlyScriptDirs);

for d = 1:length(plotlyDirs)
    
    % delete files from plotly directory
    removefiles = fullfile(plotlyDirs{d}, REMOVEFILES);
    delete(removefiles{:});
    
    % remove folders from plotly directory
    removefolders = fullfile(plotlyDirs{d},REMOVEFOLDERS);
    
    for f = 1:length(removefolders)
        %remove folder from path
        rmpath(removefolders{f});
        %delete folder/subfolders
        try
            status = rmdir(removefolders{f},'s');
            
            if (status == 0)
                error('plotly:deletePlotlyAPI',...
                    ['\n\nShoot! It looks like something went wrong removing the Plotly API ' ...
                    'from the MATLAB toolbox directory \n' ...
                    'Please contact your system admin. or chuck@plot.ly for more information. \n\n']);
            end
            
        end
    end
    
    removed = [removefiles removefolders];
    
end
end
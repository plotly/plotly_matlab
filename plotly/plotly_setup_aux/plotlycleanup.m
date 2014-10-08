function removed = plotlycleanup

% cleans up any old Plotly API MATLAB library files and folders

% initialize output
removed = {};

%----REMOVE FILES----%
REMOVEFILES = {'plotly.m', 'testclean.m'};

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
    
    % add plotlydirs to searchpath (will be removed in future once handled by plotlyupdate)
    addpath(genpath(plotlyDirs{d})); 
    
    % delete files from plotly directory
    removefiles = fullfile(plotlyDirs{d}, REMOVEFILES);
    
    for f = 1:length(removefiles)
        
        % remove removefiles filepath from searchpath
        rmpath(fileparts(removefiles{f}));
        
        if exist(removefiles{f},'file')
            delete(removefiles{f});
        end
        
        % add removefiles filepath back to searchpath
        addpath(fileparts(removefiles{f}));
        
    end
    
    % update removed list
    removed = [removed removefiles];
    
    % remove folders from plotly directory
    removefolders = fullfile(plotlyDirs{d},REMOVEFOLDERS);
    
    for f = 1:length(removefolders)
        if exist(removefolders{f},'dir')
            
            %remove folder from path
            rmpath(genpath(removefolders{f}));
            
            %delete folder/subfolders
            try
                status = rmdir(removefolders{f},'s');
                
                if (status == 0)
                    error('plotly:deletePlotlyAPI',...
                        ['\n\nShoot! It looks like something went wrong removing the Plotly API ' ...
                        'from the MATLAB toolbox directory \n' ...
                        'Please contact your system admin. or chuck@plot.ly for more information. \n\n']);
                end
                
                % update removed list
                removed = [removed removefolders];
                
            end
        end
    end   
end
end
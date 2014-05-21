function plotlysetup( username, api_key )
% 1) adds plotly api to searchpath via startup.m of matlabroot and/or userpath
% 2) calls saveplotlycredentials
% [TODO]: Account for octave users
% [TODO]: Handle Permissions

%check inputs
if nargin ~= 2
    error('plotly:setupInputs',...
        ['Whoops! Please setup your Plotly MATLAB API'...
        'by calling plotlysetup(' '''user_name''' ',' '''api_key''' ')']);
end

%check for matlab...
if(~is_octave)
    
    %matlab root directory
    mtlroot = fullfile(matlabroot,'toolbox'); %this should work on all platforms
    
    %create the plotly folder in the matlab/toolbox dir.
    plotlyToolboxPath = [mtlroot '/plotly'];
    if(~exist(plotlyToolboxPath))
        [status, mess, messid] = mkdir(plotlyToolboxPath);
        
        %check that the folder was created
        if (status == 0)
            if(~strcmp(messid, 'MATLAB:MKDIR:DirectoryExists'))
                error('plotly:savePlotlyAPI',...
                    ['Error saving plotly MATLAB API at ' ...
                    plotlyApiFolder ': '...
                    mess ', ' messid '. Get in touch with ' ...
                    'chuck@plot.ly for support.']);
            end
        end
        
    end
    
    %find the plotly file from the users working directory
    plotlyFilePath = which('plotly.m');
    
    %check that the plotly file was found
    if (strcmp(plotlyFilePath,''))
        error('plotly:plotlyFilePath',...
            ['Error locating the Plotly MATLAB API Folder.' ...
            ' Make sure to place it in your current working directory ! ' ...
            'Get in touch with chuck@plot.ly for support.']);
    end
    
    %grab the plotly folder path
    plotlyFolderPath = plotlyFilePath(1:end-length('plotly.m'));
    
    %move a copy of the plotly api to matlab root directory %should check with user for overwrite!
    [status, mess, messid] = copyfile(plotlyFolderPath,plotlyToolboxPath, 'f');
    %check that the plotly api was copied to the matlab root toolbox directory
    if (status == 0)
        if(~strcmp(messid, 'MATLAB:COPYFILE:SourceAndDestinationSame'))
        error('plotly:copyPlotlyAPI',...
            ['Error moving plotly MATLAB API to ' ...
            plotlyToolboxPath ': '...
             'Get in touch with ' ...
            'chuck@plot.ly for support.']);
        end
    end
    
    %add the api path to MATLAB searchpath
    fprintf('\nAdding Plotly to MATLAB toolbox directory...Done\n');
    
    %check for a startup.m file in matlab rootpath (we want to add one here)
    startupFile = [];
    startupFileRootPath = fullfile(matlabroot,'toolbox','local');
    if(~exist([startupFileRootPath '/startup.m'],'file'))
        startFileID = fopen([startupFileRootPath '/startup.m'], 'w');
        startupFile = {[startupFileRootPath '/startup.m']}; %needed because matlab online detects startup.m when opened. 
        if(startFileID == -1)
            error('plotly:startFileCreation',...
                ['Error creating startup.m file at '...
                startFileRootPath '. Get in touch with '...
                'chuck@plot.ly for support.']);
        end
    end
    
    %check for all startup.m file in searchpath
    startupFile = [startupFile; cell(which('startup.m','-all'))];
    
    %write the addpath - plotly api to the startup.m files
    addplotlystartup(startupFile);
    addpath(genpath(plotlyToolboxPath));
    fprintf('Saving Plotly to MATLAB search path via startup.m...Done\n');
    
else %if octave
    display('Octave users: Automatic Plotly API embedding coming soon!');
end %end check for matlab...

%save user credentials
fprintf('Saving user credentials...Done\n\n');
saveplotlycredentials(username,api_key);

%greet the people
fprintf(['Welcome to Plotly! If you are new to Plotly please enter: >>plotlyhelp to get started!\n\n'])



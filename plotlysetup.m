function plotlysetup( username, api_key )
% 1) adds plotly api to searchpath via startup.m of matlabroot and/or userpath
% 2) calls saveplotlycredentials
% [TODO]: Account for octave users
% [TODO]: Handle Permissions - try/catch  

%check inputs
if nargin ~= 2
    error('plotly:setupInputs',...
        ['Whoops! Please setup your Plotly MATLAB API '...
        'by calling plotlysetup(' '''user_name''' ',' '''api_key''' ')']);
end

try %embed the api to the matlabroot/toolbox dir. 
    
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
                    plotlyToolboxPath ': '...
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
    fprintf('\nAdding Plotly to MATLAB toolbox directory ... Done\n');
    
    %check for a startup.m file in matlab rootpath (we want to add one here)
    startupFile = [];
    startupFileRootPath = fullfile(matlabroot,'toolbox','local');
    if(~exist([startupFileRootPath '/startup.m'],'file'))
        startFileID = fopen([startupFileRootPath '/startup.m'], 'w');
        startupFile = {[startupFileRootPath '/startup.m']}; %needed because matlab only looks for startup.m when first opened. 
        if(startFileID == -1)
            error('plotly:startFileCreation',...
                ['Error creating startup.m file at '...
                startupFileRootPath '. Get in touch with '...
                'chuck@plot.ly for support.']);
        end
    end
    
    %check for all startup.m file in searchpath
    startupFile = [startupFile; cell(which('startup.m','-all'))];
    
    %write the addpath - plotly api to the startup.m files
    addplotlystartup(startupFile);
    addpath(genpath(plotlyToolboxPath));
    fprintf('Saving Plotly to MATLAB search path via startup.m ... Done\n');
     
else %if octave
    display('Octave users: Automatic Plotly API embedding coming soon!');
end %end check for matlab...

catch exception 
fprintf([' \n' exception.identifier '\t --- \tShoot! It looks like you might not have write permission ' ...
    'for the MATLAB toolbox or the startup.m files \n\t\t\twithin your search path. ' ...
    'Please contact your system admin. or chuck@plot.ly for more information. In\n\t\t\tthe ' ...
    'mean time you can add the Plotly API to your search path manually whenever you need it! \n']);     
end

%save user credentials
fprintf('Saving user credentials ... Done\n\n');

try 
saveplotlycredentials(username,api_key);
catch exception
fprintf([' \n' exception.identifier '\t --- \tShoot! It looks like you might not have write permission '...
    'to create a credentials file within your home directory. \n\t\t\tPlease contact your system admin. '...
    'or chuck@plot.ly for more information. In the mean time you can sign in to \n\t\t\tthe Plotly API '...
    'manually using the signin.m function. We have already signed you in for this session! \n ']);         
signin(username,api_key); 
end

%greet the people
fprintf(['Welcome to Plotly! If you are new to Plotly please enter: >>plotlyhelp to get started!\n\n'])



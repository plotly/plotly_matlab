function plotlysetup(username, api_key, varargin)
% CALL: plotlysetup(username,api_key,'kwargs'[optional]);
% WHERE: kwargs are of the form ..,'property,value,'property',value,...
% PROPERTIES: 'stream_token', 'plotly_domain', 'plotly_streaming_domain'
% [1] adds plotly api to matlabroot/toolboxes. If successful do [2]
% [2] adds plotly api to searchpath via startup.m of matlabroot and/or userpath
% [3] calls saveplotlycredentials (using username, api_key and stream_key [optional])
% [4] calls saveplotlyconfig with ('plotly_domain'[optional], 'plotly_streaming_domain' [optional])

try %check number of inputs
    if (nargin<2||nargin>8)
        error('plotly:setupInputs',....
            ['\n\nWhoops! Wrong number of inputs. Please run >> help plotlysetup \n',...
            'for more information regarding thes setup your Plotly API MATLAB \n',...
            'Library. Please contact chuck@plot.ly for more information.']);
    end
catch exception %plotlysetup input problem catch...
    fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    return
end

try %check to see if plotly is in the searchpath
    plotlysetupPath = which('plotlysetup');
    plotlyFolderPath = [plotlysetupPath(1:end-length('plotlysetup.m')) 'plotly']; %there has to be a nicer way of doing this!
    %if it was not found
    if (strcmp(genpath(plotlyFolderPath),''))
        error('plotly:plotlyFilePath',...
            ['\n\nShoot! It looks like MATLAB is having trouble finding the current version '  ...
            '\nof Plotly. Please make sure that the plotly/ API folder is in the same '  ...
            '\ndirectory as plotlysetup.m. Contact chuck@plot.ly for more information. \n\n']);
    end
    addpath(genpath(plotlyFolderPath));
catch exception %plotly file not found problem catch
    fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    return
end

if(~is_octave)%if MATLAB
    
    try %embed the api to the matlabroot/toolbox dir.
        fprintf('\nAdding Plotly to MATLAB toolbox directory ...  ');
        
        %plotly folder in the matlab/toolbox dir.
        plotlyToolboxPath = fullfile(matlabroot,'toolbox','plotly'); %this should work on all platforms
        
        if(exist(plotlyToolboxPath,'dir')) %check for overwrite...
            fprintf(['\n\n[UPDATE]: \n\nHey! We see that a copy of Plotly has previously been added to\n' ...
                'your Matlab toolboxes. Would you like us to overwrite it with:\n' plotlyFolderPath ' ? \n'...
                'Careful! You may lose data saved to this Plotly directory.\n\n']);
            
            overwrite = input('Overwrite (y/n) ? : ','s');
            
            if(strcmpi(overwrite,'y'));
                fprintf('\n[OVERWRITE]:\n\nOverwriting Plotly! ... Done \n');
            else
                fprintf('\n[NO OVERWRITE]:\n\nDid not overwrite Plotly! ... Done \n');
            end
        else %toolbox Plotly not yet created
            
            %worked (without interuption)...just a formatting thing!
            fprintf('Done\n');
            
            %make the plotlyToolboxPath dir.
            status = mkdir(plotlyToolboxPath);
            
            %set status to overwrite
            overwrite = 'y';
            
            %check that the folder was created
            if (status == 0)
                error('plotly:savePlotlyAPI',...
                    ['\n\nShoot! It looks like you might not have write permission ' ...
                    'for the MATLAB toolbox directory \n' ...
                    'Please contact your system admin. or chuck@plot.ly for more information. In the ' ...
                    'mean \ntime you can add the Plotly API to your search path manually whenever you need it! \n\n']);
            end
        end
        
        if(strcmpi(overwrite,'y'))
            
            %move a copy of the Plotly api to matlab root directory (does not remove files simply overwrites common files!)
            [status, ~, messid] = copyfile(plotlyFolderPath,plotlyToolboxPath, 'f');
            %check that the plotly api was copied to the matlab root toolbox directory
            if (status == 0)
                
                if(~strcmp(messid, 'MATLAB:COPYFILE:SourceAndDestinationSame'))
                    error('plotly:copyPlotlyAPI',...
                        ['Shoot! It looks like you might not have write permission ' ...
                        'for the MATLAB toolbox directory \n\t\t\t ' ...
                        'Please contact your system admin. or chuck@plot.ly for more information. In\n\t\t\tthe ' ...
                        'mean time you can add the Plotly API to your search path manually whenever you need it! \n']);
                end
            end
        end
        
        %add it to the searchpath (startup.m will handle this next time!)
        addpath(genpath(plotlyToolboxPath),'-end');
        
        try %save plotly api searchpath to startup.m files (only do this if we actually were able to store the api in mtlroot/toolbox!)
            fprintf('Saving Plotly to MATLAB search path via startup.m ... ');
            
            %check for a startup.m file in matlab rootpath (we want to add one here)
            startupFile = [];
            startupFileRootPath = fullfile(matlabroot,'toolbox','local','startup.m');
            if(~exist(startupFileRootPath,'file'))
                startFileID = fopen(startupFileRootPath, 'w');
                startupFile = {startupFileRootPath}; %needed because matlab only looks for startup.m when first opened.
                if(startFileID == -1)
                    error('plotly:startFileCreation',...
                        ['Shoot! It looks like you might not have write permission ' ...
                        'for the MATLAB toolbox directory \n\t\t\t ' ...
                        'Please contact your system admin. or chuck@plot.ly for more information. In\n\t\t\tthe ' ...
                        'mean time you can add the Plotly API to your search path manually whenever you need it! \n']);
                end
            end
            
            %check for all startup.m file in searchpath
            startupFile = [startupFile; cell(which('startup.m','-all'))];
            %write the addpath - plotly api to the startup.m files
            [warnings] = addplotlystartup(startupFile);
            
            %worked!
            fprintf(' Done\n');
            
            %print any addplotlydstatup warnings;
            w = cellfun(@isempty,warnings);
            if(find(~w))
                fprintf(warnings{find(~w)});
            end
            
        catch exception %writing to startup.m permission problem catch...
            fprintf(['\n\n' exception.identifier exception.message '\n\n']);
        end
        
    catch exception %copying to toolbox permission problem catch...
        fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    end
    
else %if octave
    display('\nOctave users: Automatic Plotly API embedding coming soon!\n');
end %end check for matlab...

try %save user credentials
    fprintf('Saving username/api_key credentials ... ');
    saveplotlycredentials(username,api_key);
    %worked!
    fprintf('Done\n');
catch exception %writing credentials file permission problem catch...
    fprintf(['\n\n' exception.identifier exception.message '\n\n']);
end

%----handle varargin----%
try
    
    if mod(numel(varargin),2)~= 0
        error('plotly:setupInputs',....
            ['\n\nWhoops! Wrong number of varargin inputs. Please run >> help plotlysetup \n',...
            'for more information regarding the setup your Plotly API MATLAB Library. \n',...
            'Your stream_key, plotly_domain, and plotly_streaming domain were not set. \n',...
            'Please contact chuck@plot.ly for more information.']);
    end
    
    for n = 1:2:numel(varargin)
        if strcmp(varargin{n},'stream_key')
            fprintf('Saving stream_key credentials ... ');
            saveplotlycredentials(username,api_key,varargin{n+1});
            %worked!
            fprintf('Done\n');
        end
        if strcmp(varargin{n},'plotly_domain')
            fprintf('Saving plotly_domain configuration ... ');
            saveplotlyconfig(varargin{n+1});
            %worked!
            fprintf('Done\n');
        end
        if strcmp(varargin{n},'plotly_streaming_domain')
            fprintf('Saving plotly_streaming_domain configuration ... ');
            try
                config = loadplotlyconfig;
            catch
                config.plotly_domain = '';
            end
            saveplotlyconfig(config.plotly_domain,varargin{n+1});
            %worked!
            fprintf('Done\n');
        end
    end
    
catch exception %writing aux kwargs problem catch...
    fprintf(['\n\n' exception.identifier exception.message '\n\n']);
end

%sign in the user
signin(username,api_key);

%greet the people!
fprintf('\nWelcome to Plotly! If you are new to Plotly please enter: >> plotlyhelp to get started!\n\n')




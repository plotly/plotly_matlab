function plotlysetup_offline(plotly_bundle_url, varargin)

    % CALL: plotlysetup_offline(plotly_bundle_url);
    % WHERE: plotly_bundle_url is the plotly bundle url, e.g. http://cdn.plot.ly/plotly-latest.min.js
    % If no argument is provided, the default http://cdn.plot.ly/plotly-latest.min.js is used.
    % [1] adds plotly api to matlabroot/toolboxes. If successful do [2]
    % [2] adds plotly api to searchpath via startup.m of matlabroot and/or userpath
    
    %DEFAULT OUTPUT
    exception.message = '';
    exception.identifier = '';
    
    try %check number of inputs
        if(nargin == 0)
            plotly_bundle_url = 'http://cdn.plot.ly/plotly-latest.min.js';
        elseif (nargin>1)
            error('plotly:wrongInput',....
                ['\n\nWhoops! Wrong number of inputs. Please run >> help plotlysetup_offline \n',...
                'for more information regarding the setup your Plotly API MATLAB \n',...
                'Library. Please post a topic on https://community.plotly.com/c/api/matlab/ for more information.']);
        end
    catch exception %plotlysetup input problem catch...
        fprintf(['\n\n' exception.identifier exception.message '\n\n']);
        return
    end
    
    try
        %check to see if plotly is in the searchpath
        plotlysetupPath = which('plotlysetup');
        plotlyFolderPath = fullfile(fileparts(plotlysetupPath),'plotly');
        %if it was not found
        if (strcmp(genpath(plotlyFolderPath),''))
            error('plotly:notFound',...
                ['\n\nShoot! It looks like MATLAB is having trouble finding the current version '  ...
                '\nof Plotly. Please make sure that the Plotly API folder is in the same '  ...
                '\ndirectory as plotlysetup.m. Questions? Ask https://community.plotly.com/c/api/matlab/\n\n']);
        end
        %add Plotly API MATLAB Library to search path
        addpath(genpath(plotlyFolderPath));
    catch exception %plotly file not found problem catch
        fprintf(['\n\n' exception.identifier exception.message '\n']);
        return
    end
    
    if(~is_octave)
        
        try
            %embed the api to the matlabroot/toolbox dir.
            fprintf('\nAdding Plotly to MATLAB toolbox directory ...  ');
            
            %plotly folder in the matlab/toolbox dir.
            plotlyToolboxPath = fullfile(matlabroot,'toolbox','plotly');
            
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
                    error('plotly:savePlotly', permissionMessage('save the Plotly folder'));
                end
            end
            
            if(strcmpi(overwrite,'y'))
                
                %move a copy of the Plotly api to matlab root directory
                [status, msg, messid] = copyfile(plotlyFolderPath,plotlyToolboxPath);
                %check that the plotly api was copied to the matlab root toolbox directory
                if (status == 0)
                    if(~strcmp(messid, 'MATLAB:COPYFILE:SourceAndDestinationSame'))
                        error('plotly:copyPlotly',permissionMessage('copy the Plotly folder'));
                    end
                end
                
            end
            
            %add it to the searchpath (startup.m will handle this next time!)
            addpath(genpath(plotlyToolboxPath),'-end');
            
            %save plotly api searchpath to startup.m files (only do this if we actually were able to store the api in mtlroot/toolbox!)
            fprintf('Saving Plotly to MATLAB search path via startup.m ... ');
            
            %check for a startup.m file in matlab rootpath (we want to add one here)
            startupFile = [];
            startupFileRootPath = fullfile(matlabroot,'toolbox','local','startup.m');
            if(~exist(startupFileRootPath,'file'))
                startFileID = fopen(startupFileRootPath, 'w');
                %startup.m does not exist and startupFilePath is non-writable
                if(startFileID == -1)
                    error('plotly:rootStartupCreation',permissionMessage('write the startup.m script'));
                end
                startupFile = {startupFileRootPath}; %needed because MATLAB only looks for startup.m when first opened.
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
                %output warnings
                exception.warnings = warnings;
                fprintf(warnings{find(~w)});
            end
            
        catch exception %copying to toolbox/writing to startup.m permission problem catch...
            fprintf(['\n\n' exception.identifier exception.message '\n\n']);
        end
        
    else %if octave
        fprintf('\n\nOctave users: Automatic Plotly API embedding coming soon!\n\n');
    end %end check for matlab...
    
    %get offline bundle
    fprintf('\nNow downloading the plotly offline bundle ...');
    getplotlyoffline(plotly_bundle_url);
    
    %greet the people!
    fprintf('\nWelcome to Plotly! If you are new to Plotly please enter: >> plotlyhelp to get started!\n\n')
    
    end
    
    %helper message function 
    function message = permissionMessage(spec)
    message = ['\n\nShoot! We tried to ' spec ' to the MATLAB toolbox \n',...
        'directory, but were denied write permission. You''ll have to add\n',...
        'the Plotly folder to your MATLAB path manually by running: \n\n',...
        '>> plotly_path = fullfile(pwd, ''plotly'')\n',...
        '>> addpath(genpath(plotly_path))\n\n',...
        'Questions? Ask https://community.plotly.com/c/api/matlab/\n\n'];
    end
    
    

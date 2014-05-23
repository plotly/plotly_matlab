function plotlysetup( username, api_key )
% [1] adds plotly api to matlabroot/toolboxes. If successful... (2)
% [2] adds plotly api to searchpath via startup.m of matlabroot and/or userpath
% [3] calls saveplotlycredentials
% [TODO]: Account for octave users
% {TODO]: Test on windows machine

try %check number of inputs
    if nargin ~= 2
        error('plotly:setupInputs',....
            ['Whoops! Wrong number of inputs. Please setup your Plotly '...
            '\n\t\t\tMATLAB API by calling >>plotlysetup(' '''user_name''' ',' '''api_key''' ') \n\n']);
    end
catch exception %plotlysetup input problem catch...
    fprintf(['\n\n' exception.identifier '\t --- \t' exception.message]);
    return
end

try %check to see if plotly is in the searchpath
    plotlysetupPath = which('plotlysetup'); 
    plotlyFolderPath = [plotlysetupPath(1:end-length('plotlysetup.m')) 'plotly']; %there has to be a nicer way of doing this!
    %if it was not found
    if (strcmp(genpath(plotlyFolderPath),''))
        error('plotly:plotlyFilePath',...
            ['Shoot! It looks like MATLAB is having trouble finding the current version '  ...
            '\n\t\t\tof Plotly. Please make sure that the plotly/ API folder is in the same '  ...
            '\n\t\t\tdirectory as plotlysetup.m. Contact chuck@plot.ly for more information. \n\n']);
    end
    addpath(genpath(plotlyFolderPath));
catch exception %plotly file not found problem catch
    fprintf(['\n\n' exception.identifier '\t --- \t' exception.message]);
    return
end

if(~is_octave)%if MATLAB
    
    try %embed the api to the matlabroot/toolbox dir.
        fprintf('\nAdding Plotly to MATLAB toolbox directory ... ');
        
        %matlab root directory
        mtlroot = fullfile(matlabroot,'toolbox'); %this should work on all platforms
        
        %create the plotly folder in the matlab/toolbox dir.
        plotlyToolboxPath = [mtlroot '/plotly'];
        overwrite = 'n'; 
        
        if(exist(plotlyToolboxPath,'dir')) %check for overwrite...
            fprintf(['\n\n[UPDATE]: \t\t --- \t Hey! We see that a copy of Plotly has previously been added to\n\t\t\t ' ...
                'your Matlab toolboxes. Would you like us to overwrite it with:\n\t\t\t ' plotlyFolderPath ' ? \n\t\t\t '...
                'Careful! You may lose data saved to this folder.\n\n']);
            overwrite = input('Overwrite (y/n) ? : ','s');
            if(strcmpi(overwrite,'y'));
                fprintf(['\n\n[OVERWRITE]: \t\t --- \t Overwriting Plotly! ... Done \n\n']);
            else
                fprintf(['\n\n[OVERWRITE]: \t\t --- \t Did not overwrite Plotly! ... Done \n\n']);
            end
        end
            
        if(~exist(plotlyToolboxPath,'dir')||strcmpi(overwrite,'y'))
            
            %make the plotlyToolboxPath dir.
            [status, mess, messid] = mkdir(plotlyToolboxPath);
            
            %check that the folder was created
            if (status == 0)
                if(~strcmp(messid, 'MATLAB:MKDIR:DirectoryExists'))
                    error('plotly:savePlotlyAPI',...
                        ['Shoot! It looks like you might not have write permission ' ...
                        'for the MATLAB toolbox directory \n\t\t\t' ...
                        'Please contact your system admin. or chuck@plot.ly for more information. In\n\t\t\tthe ' ...
                        'mean time you can add the Plotly API to your search path manually whenever you need it! \n']);
                end
            end
            
            %move a copy of the plotly api to matlab root directory %should check with user for overwrite...but we're not!
            [status, mess, messid] = copyfile(plotlyFolderPath,plotlyToolboxPath, 'f');
            %check that the plotly api was copied to the matlab root toolbox directory
            if (status == 0)
                disp(mess)
                disp(messid)

                if(~strcmp(messid, 'MATLAB:COPYFILE:SourceAndDestinationSame'))
                    error('plotly:copyPlotlyAPI',...
                        ['Shoot! It looks like you might not have write permission ' ...
                        'for the MATLAB toolbox directory \n\t\t\t ' ...
                        'Please contact your system admin. or chuck@plot.ly for more information. In\n\t\t\tthe ' ...
                        'mean time you can add the Plotly API to your search path manually whenever you need it! \n']);
                end
            end
            
            if(~strcmpi(overwrite,'y'))
            %worked (without interuption)...just a formatting thing! 
            fprintf('Done\n');
            end
            
        end
        
        %add it to the searchpath (startup.m will handle this next time!)
        addpath(genpath(plotlyToolboxPath),'-end');
        
        try %save plotly api searchpath to startup.m files (only do this if we actually were able to store the api in mtlroot/toolbox!)
            fprintf('Saving Plotly to MATLAB search path via startup.m ... ');
            
            %check for a startup.m file in matlab rootpath (we want to add one here)
            startupFile = [];
            startupFileRootPath = fullfile(matlabroot,'toolbox','local');
            if(~exist([startupFileRootPath '/startup.m'],'file'))
                startFileID = fopen([startupFileRootPath '/startup.m'], 'w');
                startupFile = {[startupFileRootPath '/startup.m']}; %needed because matlab only looks for startup.m when first opened.
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
            fprintf(['\n\n' exception.identifier '\t --- \t' exception.message]);
        end
        
    catch exception %copying to toolbox permission problem catch...
        fprintf(['\n\n' exception.identifier '\t --- \t' exception.message]);
    end
    
else %if octave
    display('Octave users: Automatic Plotly API embedding coming soon!');
end %end check for matlab...

try %save user credentials
    fprintf('Saving user credentials ... ');
    saveplotlycredentials(username,api_key);
    
    %worked!
    fprintf('Done\n\n');
    
catch exception %writing credentials file permission problem catch...
    fprintf(['\n\n' exception.identifier '\t --- \t' exception.message]);
    signin(username,api_key);
end

%greet the people!
fprintf(['Welcome to Plotly! If you are new to Plotly please enter: >>plotlyhelp to get started!\n\n'])




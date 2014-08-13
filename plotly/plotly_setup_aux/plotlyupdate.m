%-----AUTOMATIC PLOTLY MATLAB API UPDATING-----%

function plotlyupdate(varargin)

% plotlyupdate.m automatically updates the Plotly
% API MATLAB library if the current version is not
% up to date. The new version replaces all instances
% of the Plotly API MATLAB library in the users
% search path.

%successful update switch
success = true;

%check for verbose
verbose = any(strcmp(varargin,'verbose'));

%check for nocheck :)
nocheck = any(strcmp(varargin,'nocheck'));

%----check for necessary update----%

% local version number
pvLocal = plotly_version;

% local Plotly API MATLAB Libraries
plotlyScriptDirs = which('plotly','-all');
plotlyDirs = cell(1,length(plotlyScriptDirs));

for d = 1:length(plotlyScriptDirs)
    plotlyDirs{d} = fileparts(plotlyScriptDirs{d});
end

% remote Plotly API MATLAB Library url
remote = ['https://raw.githubusercontent.com/plotly/MATLAB-api/',...
    'master/plotly/plotly_aux/plotly_version.m'];

% remote Plotly API MATLAB Library
try
    pvContent = urlread(remote);
catch
    fprintf(['\nAn error occurred while trying to read the latest\n',...
        'Plotly API MATLAB Library version number from:\n',...
        'https://github.com/plotly/MATLAB-api.\n',...
        'Please check your internet connection or\n',...
        'contact chuck@plot.ly for further assistance.\n\n']);
    return
end

% remote version number
pvBounds = strfind(pvContent,'''');
pvRemote = pvContent(pvBounds(1)+1:pvBounds(2)-1);

%----update if necessary-----%

if strcmp(pvLocal,pvRemote)
    fprintf(['\nYour Plotly API MATLAB Library v.' pvRemote ' is already up to date! \n\n'])
    return
else
    if nocheck
        
        fprintf('\n************************************************\n');
        fprintf(['[UPDATING] Plotly v.' pvLocal ' ----> Plotly v.' pvRemote ' \n']);
        fprintf('************************************************\n');
        
        %----find all old plotly instances-----%
        
        try
            if verbose
                fprintf(['\nSearching for instances of old Plotly API Matlab ',...
                    'Library v.' pvLocal ' ... ']);
            end
            
            if isempty(plotlyScriptDirs);
                error('Plotly:missingfile','No Plotly file found');
            end
            
            if verbose
                fprintf('Done!');
            end
            
        catch
            fprintf(['\n\n An error occured while looking for Plotly. ',...
                'Did you reorganize the Plotly file structure?\n\n']);
            % update failed
            success = false;
        end
        
        
        %----create temporary update folder----%
        try
            
            %temporary update folder location
            plotlyUpdateDir = fullfile(pwd,['plotlyupdate_' pvRemote]);
            
            if verbose
                fprintf(['\nCreating temporary update directory: ' plotlyUpdateDir ' ... ']);
            end
            
            %----make plotlyUpdateDir----%
            status = mkdir(plotlyUpdateDir);
            
            if verbose
                fprintf('Done! \n');
            end
            
            if (status == 0)
                error('plotlyupdate:makeUpdateDir',...
                    ['\n\nShoot! It looks like something went wrong while making',...
                    'the Plotly Update Directory. \n Please contact your system ',...
                    'admin. or chuck@plot.ly for more information. \n\n']);
            end
            
        catch exception
            fprintf(['\n\n' exception.identifier exception.message]);
            % update failed
            success = false;
        end
        
        %----download plotly----%
        if success
            try
                if verbose
                    fprintf(['Downloading the Plotly API Matlab Library v.' pvRemote ' ... ']);
                end
                
                newPlotlyUrl = 'https://github.com/plotly/MATLAB-api/archive/master.zip';
                newPlotlyZip = fullfile(plotlyUpdateDir,['plotlyupdate_' pvRemote '.zip']);
                
                %download from url
                urlwrite(newPlotlyUrl,newPlotlyZip);
                
                if verbose
                    fprintf('Done! \n');
                end
            catch
                fprintf('\n\nAn error occured while downloading the newest version of Plotly\n\n');
                % update failed
                success = false;
            end
        end
        
        %----unzip updated plotly----%
        if success
            try
                if verbose
                    fprintf(['Unzipping the Plotly API Matlab Library v.' pvRemote ' ... ']);
                end
                
                unzip(newPlotlyZip,plotlyUpdateDir);
                
                if verbose
                    fprintf('Done! \n');
                end
            catch
                fprintf('\n\nAn error occured while unzipping the newest version of Plotly\n\n');
                %update failed
                success = false;
            end
        end
        
        %----replace all instances of plotly----%
        if success
            try
                if verbose
                    fprintf(['Updating the Plotly API Matlab Library v.' pvLocal ' ... ']);
                end
                
                % new Plotly directory
                newPlotlyDir = fullfile(plotlyUpdateDir,'MATLAB-api-master','plotly');
                
                % files in Plotly repo root
                repoRoot = dir(fullfile(plotlyUpdateDir,'MATLAB-api-master'));
                
                % files not to be included
                repoExclude = {'.','..','.gitignore','plotly'};
                
                % aux Plotly repo root files
                d = 1;
                for r = 1:length(repoRoot);
                    if(~any(strcmp(repoRoot(r).name,repoExclude)))
                        auxFiles{d} = fullfile(plotlyUpdateDir,'MATLAB-api-master',repoRoot(r).name);
                        d = d+1;
                    end
                end
                
                % plotly toolbox directory
                plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
                
                % replace the old Plotly with the new Plotly
                for d = 1:length(plotlyDirs)
                    % do not copy aux Plotly repo root files to toolbox dir. Plotly
                    if ~strcmp(plotlyDirs{d},plotlyToolboxDir)
                        % aux Files Destination
                        auxFileDest = fileparts(plotlyDirs{d});
                        % copy aux to appropriate destination
                        for r = 1:length(auxFiles)
                            copyfile(auxFiles{r},auxFileDest,'f');
                        end
                    end
                    %copy actual Plotly API Matlab Library
                    copyfile(newPlotlyDir,plotlyDirs{d},'f');
                end
                
                if verbose
                    fprintf('Done! \n');
                end
            catch
                fprintf(['\n\nAn error occured while updating to the newest version \n',...
                    'of Plotly v.' pvRemote '. Please check your write permissions\n',...
                    'for your outdated Plotly directories with your system admin.\n',...
                    'Contact chuck@plot.ly for more information.\n\n']);
                % update failed
                success = false;
            end
        end
        
        %----clean up old Plotly wrapper scipts----%
        if success
            try
                if verbose
                    fprintf('Cleaning up outdated Plotly API MATLAB library scripts ... ');
                end
                
                %run cleanup 
                removed = plotlycleanup;
                
                if verbose
                    fprintf('Done! \n');
                    if ~isempty(removed)
                        fprintf('The following Plotly scripts were removed:\n');
                        % explicitly state the removed files
                        for r = 1:length(removed)
                            fprintf([removed{r} '\n']);
                        end
                    end
                end
            catch
                fprintf(['\n\nAn error occured while cleaning up the outdated Plotly scripts. Please\n',...
                    'check your write permissions for your outdated Plotly directories with \n',...
                    'your system admin. Contact chuck@plot.ly for more information.\n\n']);
            end
        end
        
        %----delete update directory-----%
        if exist(plotlyUpdateDir,'dir')
            try
                if verbose
                    fprintf(['Removing temporary update directory: ' plotlyUpdateDir ' ... ']);
                end
                
                % delete temp update dir.
                rmdir(plotlyUpdateDir,'s');
                
                if verbose
                    fprintf('Done! \n');
                end
                
            catch
                fprintf(['\n\n An error occured while attempting to remove',...
                    ' the \n temporary update directory. Please remove manually.\n\n']);
            end
        end
        
        %----successful update----%
        if success
            fprintf('\n**************************************************\n');
            fprintf(['[UPDATE SUCCESSFUL] visit: https://plot.ly/matlab \n',...
                'or contact: chuck@plot.ly for further information. \n']);
            fprintf('**************************************************\n\n');
        else
            fprintf('\n***************************************************\n');
            fprintf(['[UPDATE UNSUCCESSFUL] visit: https://plot.ly/matlab \n',...
                'or contact: chuck@plot.ly for further information. \n']);
            fprintf('***************************************************\n\n');
        end
        
    else %check
        
        fprintf(['\nYou are about to update your Plotly API MATLAB Library v.' pvLocal ', which will\n',...
            'overwrite modifications made to the Plotly scripts in the following directories:\n\n']);
        
        % explicitly output directories
        for d = 1:length(plotlyDirs)
            fprintf([plotlyDirs{d} '\n']);
        end
        
        overwrite = input('\nProceed with update (y/n) ? : ','s');
        
        if(strcmpi(overwrite,'y'))
            if verbose
                plotlyupdate('verbose','nocheck');
            else
                plotlyupdate('nocheck');
            end
        else
            fprintf('\n***********************************************\n');
            fprintf(['[UPDATE ABORTED] visit: https://plot.ly/matlab \n',...
                'or contact: chuck@plot.ly for more information. \n']);
            fprintf('***********************************************\n\n');
        end
    end
end

end
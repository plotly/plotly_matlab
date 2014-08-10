%-----AUTOMATIC PLOTLY MATLAB API UPDATING-----%

function plotlyupdate(varargin)

% plotlyupdate.m automatically updates the Plotly
% API MATLAB library if the current version is not
% up to date. The new version replaces all instances
% of the Plotly API MATLAB library in the users
% search path.

%success switch
success = true;

%check for verbose
verbose = any(strcmp(varargin,'verbose'));

%check for nocheck :)
nocheck = any(strcmp(varargin,'nocheck'));

%----check for necessary update----%

% local version number
pvLocal = plotly_version;

% remote version number
remote = ['https://raw.githubusercontent.com/plotly/MATLAB-api/',...
    'master/plotly/plotly_aux/plotly_version.m'];
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
        if success
            try
                if verbose
                    fprintf(['\nSearching for instances of old Plotly API Matlab ',...
                        'Library v.' pvLocal ' ... ']);
                end
                
                plotlyScriptDirs = which('plotly','-all');
                plotlyDirs = cell(1,length(plotlyScriptDirs)); 
                
                for d = 1:length(plotlyScriptDirs)
                    plotlyDirs{d} = plotlyScriptDirs{d}(1:end-length('_plotly.m')); % "_" used as generic dir. divider
                end
                
                if verbose
                    fprintf('Done!');
                end
                
            catch
                fprintf(['\n\n An error occured while looking for Plotly.',...
                    'Did you reorganize the Plotly file structure?\n\n']);
                %update failed
                success = false;
            end
        end
        
        %----create temporary update folder----%
        try
            
            %temporary update folder location
            plotlyUpdateDir = fullfile(pwd,['plotlyupdate_' pvRemote]);
            
            if verbose
                fprintf(['\nCreating temporary update directory: plotlyupdate_' pvRemote ' ... ']);
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
            %update failed
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
                urlwrite(newPlotlyUrl,newPlotlyZip);
                
                if verbose
                    fprintf('Done! \n');
                end
            catch
                fprintf('\n\n Error occured while downloading the newest version of Plotly');
                %update failed
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
                
                %readme location
                readmeLoc = fullfile(plotlyUpdateDir,'Matlab-api-master','readme.md'); 
                
                %plotlysetup location 
                setupLoc = fullfile(plotlyUpdateDir,'Matlab-api-master','plotlysetup.m');
                
                %plotly toolbox directory 
                plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
                
                % replace the old Plotly with the new Plotly 
                for d = 1:length(plotlyDirs)
                    copyfile(newPlotlyDir,plotlyDirs{d},'f');
                    %do not copy setup.m and readme.md to toolbox dir. Plotly  
                    if ~strcmp(plotlyDirs{d},plotlyToolboxDir)
                       copyfile(readmeLoc,plotlyDirs{d}(1:end-length('plotly')),'f'); %_ used as generic dir. divide
                       copyfile(setupLoc,plotlyDirs{d}(1:end-length('plotly')),'f'); 
                    end
                end
                
                if verbose
                    fprintf('Done! \n');
                end
            catch
                
                fprintf(['\n\nAn error occured while updating to the newest version \n',...
                    'of Plotly v.' pvRemote '. Please check your write permissions\n',...
                    'for your outdated Plotly directories with your system admin.\n',...
                    'Contact chuck@plot.ly for more information.\n\n']);
                %update failed
                success = false;
            end
        end
        
        %----delete update directory-----%
        if exist(plotlyUpdateDir,'dir')
            try
                if verbose
                    fprintf(['Removing temporary update directory: plotlyupdate_' pvRemote ' ... ']);
                end
                
                %delete temp update dir.
                rmdir(plotlyUpdateDir,'s');
                
                if verbose
                    fprintf('Done! \n\n');
                end
                
            catch
                fprintf(['\n\n An error occured while attempting to remove',...
                    ' the \n temporary update directory. Please remove manually.\n\n']);
            end
        end
        
        %----successful update----%
        if success
            fprintf('**********************************\n');
            fprintf('[UPDATE SUCCESSFUL] ----> Plot On!\n');
            fprintf('**********************************\n\n');
        else
            fprintf('\n*********************\n');
            fprintf('[UPDATE UNSUCCESSFUL]\n');
            fprintf('*********************\n\n');
        end
        
    else
        fprintf(['\nYou are about to update your Plotly API MATLAB wrapper. \n',...
                'This will revert any data you saved to your /plotly \ndirectories.']);
        overwrite = input('Proceed with update (y/n) ? : ','s');
        if(strcmpi(overwrite,'y'))
            if verbose
                plotlyupdate('verbose','nocheck');
            else
                plotlyupdate('nocheck');
            end
        else
            fprintf('\n****************\n');
            fprintf('[UPDATE ABORTED]\n');
            fprintf('****************\n\n');
        end
    end
end

end
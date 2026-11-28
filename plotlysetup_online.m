function plotlysetup_online(username, api_key, varargin)

    % CALL: plotlysetup_online('username','api_key','kwargs'[optional]);
    % WHERE: kwargs are of the form ..,'property,value,'property',value,...
    % VALID PROPERTIES [OPTIONAL]: 'stream_ids' -> your stream ids [cell array] (found online)
    %                              'plotly_domain' -> your desired REST API endpoint [string]
    %                              'plotly_streaming_domain'-> your desired Stream API endpoint [string]
    % [1] adds plotly api to search path and prints how to keep it there
    % [2] calls saveplotlycredentials (using username, api_key and stream_ids [optional])
    % [3] calls saveplotlyconfig with ('plotly_domain'[optional], 'plotly_streaming_domain' [optional])

    %DEFAULT OUTPUT
    exception.message = '';
    exception.identifier = '';

    try %check number of inputs
        if (nargin<2||nargin>8)
            error('plotly:wrongInput',....
                ['\n\nWhoops! Wrong number of inputs. Please run >> help plotlysetup_online \n',...
                'for more information regarding the setup your Plotly API MATLAB \n',...
                'Library. Please post a topic on https://community.plotly.com/c/api/matlab/ for more information.']);
        end
    catch exception %plotlysetup input problem catch...
        fprintf(['\n\n' exception.identifier exception.message '\n\n']);
        return
    end

    try
        %check to see if plotly is in the searchpath
        plotlyFolderPath = fullfile(fileparts(mfilename('fullpath')),'plotly');
        %if it was not found
        if (strcmp(genpath(plotlyFolderPath),''))
            error('plotly:notFound',...
                ['\n\nShoot! It looks like MATLAB is having trouble finding the current version '  ...
                '\nof Plotly. Please make sure that the Plotly API folder is in the same '  ...
                '\ndirectory as plotlysetup_online.m. Questions? Ask on https://community.plotly.com/c/api/matlab/\n\n']);
        end
        %add Plotly API MATLAB Library to search path
        addpath(genpath(plotlyFolderPath));
    catch exception %plotly file not found problem catch
        fprintf(['\n\n' exception.identifier exception.message '\n']);
        return
    end

    printplotlypathhint(plotlyFolderPath);

    try %save user credentials
        fprintf('Saving username/api_key credentials ... ');

        %update: as of v.2.1.7, This also signs in the user
        saveplotlycredentials(username, api_key);

        %worked!
        fprintf('Done\n');
    catch exception %writing credentials file permission problem catch...
        fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    end

    %----handle varargin----%
    try
        %check for ..,property,value,.. structure
        if mod(numel(varargin),2)~= 0
            error('plotly:wrongInputVarargin',....
                ['\n\nWhoops! Wrong number of varargin inputs. Please run >> help plotlysetup_online \n',...
                'for more information regarding the setup of your Plotly API MATLAB Library. \n',...
                'Your stream_ids, plotly_domain, and plotly_streaming domain were not set. \n',...
                'Questions? Please post on https://community.plotly.com/c/api/matlab/22.']);
        end

        for n = 1:2:numel(varargin)
            %check for correct property names
            if isempty(intersect(varargin{n},{'stream_ids','plotly_domain','plotly_streaming_domain'}))
                error('plotly:wrongInputPropertyName',....
                    ['\n\nWhoops! The properperty name: ' varargin{n} ' is invalid. \n',...
                    'Please run >> help plotlysetup_online for more information regarding\n',...
                    'the setup your Plotly API MATLAB Library.']);
            end
            if strcmp(varargin{n},'stream_ids')
                fprintf('Saving stream_ids credentials ... ');

                %update: as of v.2.1.7, This also signs in the user
                saveplotlycredentials(username, api_key, varargin{n+1});

                %worked!
                fprintf('Done\n');
            end
            if strcmp(varargin{n},'plotly_domain')
                fprintf('Saving plotly_domain configuration ... ');

                %update: as of v.2.1.7, This also signs in the user
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

                %update: as of v.2.1.7, This also signs in the user
                saveplotlyconfig(config.plotly_domain,varargin{n+1});

                %worked!
                fprintf('Done\n');
            end
        end

    catch exception %writing varargin problem catch...
        fprintf(['\n\n' exception.identifier exception.message '\n\n']);
    end

    %greet the people!
    fprintf('\nWelcome to Plotly! If you are new to Plotly please enter: >> plotlyhelp to get started!\n\n')
end

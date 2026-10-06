function plotlysetup_offline(plotly_bundle_url, varargin)
    % CALL: plotlysetup_offline(plotly_bundle_url);
    % WHERE: plotly_bundle_url is the plotly bundle url, e.g. https://cdn.plot.ly/plotly-2.35.3.min.js
    % If no argument is provided, the default https://cdn.plot.ly/plotly-2.35.3.min.js is used.
    % [1] adds plotly api to search path and saves it via savepath

    %DEFAULT OUTPUT
    exception.message = '';
    exception.identifier = '';

    try %check number of inputs
        if nargin == 0
            plotly_bundle_url = 'https://cdn.plot.ly/plotly-2.35.3.min.js';
        elseif nargin>1
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

    % Save search path so Plotly remains available in future sessions
    try
        savepath;
    catch
    end

    %get offline bundle
    fprintf('\nNow downloading the plotly offline bundle ...');
    getplotlyoffline(plotly_bundle_url);

    %greet the people!
    fprintf('\nWelcome to Plotly! If you are new to Plotly please enter: >> plotlyhelp to get started!\n\n')
end

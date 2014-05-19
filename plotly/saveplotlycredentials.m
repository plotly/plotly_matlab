function saveplotlycredentials(username, api_key)
    % Save plotly authentication credentials.
    % Plotly credentials are saved as JSON strings
    % in ~/.plotly/.credentials

    % Create the .plotly folder
    userhome = getuserdir();
    plotly_credentials_folder = [userhome '/.plotly'];
    [status, mess, messid] = mkdir(plotly_credentials_folder);
    if (status == 0)
        if(~strcmp(messid, 'MATLAB:MKDIR:DirectoryExists'))
            error('plotly:savecredentials',...
                 ['Error saving credentials folder at ' ...
                  plotly_credentials_folder ': '...
                  mess ', ' messid '. Get in touch at ' ...
                  'chris@plot.ly for support.']);
        end
    end
    plotly_credentials_file = [plotly_credentials_folder '/.credentials'];

    fileID = fopen(plotly_credentials_file, 'w');
    if(fileID == -1)
        error('plotly:savecredentials',...
              ['Error opening credentials file at '...
               plotly_credentials_file '. Get in touch at '...
               'chris@plot.ly for support.']);
    end

    credentials = m2json(struct('username', username, 'api_key', api_key));

    fprintf(fileID, credentials);

    fclose(fileID);

end
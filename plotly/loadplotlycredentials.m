function creds = loadplotlycredentials()

    userhome = getuserdir();
    plotly_credentials_file = [userhome '/.plotly/.credentials'];

    % check if credentials exist
    if ~exist(plotly_credentials_file, 'file')
        error('Plotly:CredentialsNotFound',...
             ['It looks like you haven''t set up your plotly '...
              'account credentials yet.\nTo get started, save your '...
              'plotly username and API key by calling:\n'...
              '>>> saveplotlycredentials(username, api_key)\n\n'...
              'For more help, see https://plot.ly/MATLAB or contact '...
              'chris@plot.ly.']);
    end

    fileID = fopen(plotly_credentials_file, 'r');
    if(fileID == -1)
        error('plotly:loadcredentials', ...
              ['There was an error reading your credentials file at '...
               plotly_credentials_file '. Contact chris@plot.ly for support.']);
    end

    creds_string_array = fread(fileID, '*char');

    creds_string = sprintf(creds_string_array);

    creds = loadjson(creds_string);

end
function saveplotlycredentials(username, api_key, extra_struct)
    % Save plotly authentication credentials.
    % Plotly credentials are saved as JSON strings
    % in ~/.plotly/.credentials
    % extra is a struct

    % if the credentials file exists, then load it up
    try
      creds = loadplotlycredentials();
    catch
      creds = struct();
    end

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

    if nargin < 3
      creds.username = username;
      creds.api_key  = api_key;
    else
      % merge extra into creds
      % remove overlapping fields from first struct
      updated_creds = rmfield(creds, intersect(fieldnames(creds), fieldnames(extra_struct)));
      % obtain all unique names of remaining fields
      names = [fieldnames(updated_creds); fieldnames(extra_struct)];
      % merge both structs
      updated_creds = cell2struct([struct2cell(updated_creds); struct2cell(extra_struct)], names, 1);
      creds = updated_creds;
    end

    creds_string = m2json(creds);

    fprintf(fileID, creds_string);

    fclose(fileID);

end
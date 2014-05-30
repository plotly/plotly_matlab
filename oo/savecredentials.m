function savecredentials(username, api_key)
% SAVECREDENTIALS Save/ovewrite plotly authentication credentials
%
%   SAVECREDENTIALS(USERNAME, API_KEY)

%   Plotly credentials are saved as JSON strings:
%       - Under Windows in $APPDATA$\credentials\plotly
%       - Other OSs in ~/.plotly/.credentials

    % Hidden folder and credentials file names
    userhome = getuserdir();
    if ispc
        folder   = fullfile(userhome,'plotly');
        filename = fullfile(folder, 'credentials');
    else
        folder   = fullfile(userhome,'.plotly');
        filename = fullfile(folder, '.credentials');
    end
    
    % Create folder
    [status, mess, messid] = mkdir(folder);
    if (status == 0)
        if(~strcmp(messid, 'MATLAB:MKDIR:DirectoryExists'))
            error('plotly:savecredentials',...
                 ['Error saving credentials folder at ' ...
                  filename ': '...
                  mess ', ' messid '. Get in touch at ' ...
                  'chris@plot.ly for support.']);
        end
    end
    
    % Create file
    fileID = fopen(filename, 'w');
    if(fileID == -1)
        error('plotly:savecredentials',...
              ['Error opening credentials file at '...
               filename '. Get in touch at '...
               'chris@plot.ly for support.']);
    end
    
    % Save credentials and close
    credentials = m2json(struct('username', username, 'api_key', api_key));
    fprintf(fileID, credentials);
    fclose(fileID);

    % Hide folder and file (Win)
    if ispc
        fileattrib(folder,'+h','','s')
    end
end
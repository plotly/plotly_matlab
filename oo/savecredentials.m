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
                 ['Error saving credentials folder at %s:\n' ...
                  '%s %s.\nGet in touch at ' ...
                  'chris@plot.ly for support.'], filename,mess,messid);
        end
    end
    
    % Unhide if already exists and overwrite
    if exist(filename, 'file')
        fileattrib(filename, '-h')
    end
    fileID = fopen(filename, 'w');
    if(fileID == -1)
        error('plotly:savecredentials',...
              ['Error opening credentials file at %s.\n',...
              'Get in touch at chris@plot.ly for support.'], filename);
    end
    
    % Save credentials and close
    credentials = m2json(struct('username', username, 'api_key', api_key));
    fprintf(fileID, credentials);
    status = fclose(fileID);

    % Hide folder and file
    if ispc 
        user = '';
    else
        user = 'u';
    end
    fileattrib(folder,'+h',user,'s')
    
    % Print result
    if status == 0, fprintf('Credentials successfully saved.\n'), end
end
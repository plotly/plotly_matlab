classdef plotly
% PLOTLY 
    %  Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        User = '';
    end
    
    properties(Access = private)
        Key = '';
    end
    
    methods 
        
        function obj = plotly(user,key)
            % PLOTLY Sign into plot.ly
            
            if nargin == 0
                try
                    obj = obj.loadcredentials;
                catch
                    obj.signup
                end
            elseif nargin == 2
                obj.User = user;
                obj.Key  = key;
            end
        end
        
        function obj = signin(obj, user, key)
            % SIGNIN Sign into plot.ly with username and key
            
            obj.User = user;
            obj.Key  = key;
        end
        
        function obj = savecredentials(obj)
            % SAVECREDENTIALS Save/overwrite plotly authentication credentials
            
            % Call external
            savecredentials(obj.User,obj.Key)
        end
    end
    methods(Access = private)
        
        % SIGNUP
        function obj = signup(obj)
            response = signup;
            if isempty(response), return, end
            obj.User = response.un;
            obj.Key  = response.api_key;
        end
        
        function obj = loadcredentials(obj)
            % LOADCREDENTIALS
            % Credentials file name
            userhome = getuserdir();
            if ispc
                filename = fullfile(userhome, 'plotly', 'credentials');
            else
                filename = fullfile(userhome,'.plotly', '.credentials');
            end
            
            % Check if credentials file exist
            if ~exist(filename, 'file')
                error('Plotly:CredentialsNotFound',...
                    ['It looks like you haven''t set up your plotly '...
                    'account credentials yet.\nTo get started, save your '...
                    'plotly username and API key by calling:\n'...
                    '>>> saveplotlycredentials(username, api_key)\n\n'...
                    'For more help, see https://plot.ly/MATLAB or contact '...
                    'chris@plot.ly.']);
            end
            
            % Open file
            fileID = fopen(filename, 'r');
            if(fileID == -1)
                error('plotly:loadcredentials', ...
                    ['There was an error reading your credentials file at '...
                    filename '. Contact chris@plot.ly for support.']);
            end
            
            % Read in credentials
            credentials = fread(fileID, [1,inf],'*char');
            credentials = json2struct(credentials);
            
            % Save state
            obj.User = credentials.username;
            obj.Key  = credentials.api_key;
            
        end
    end
    
    
end


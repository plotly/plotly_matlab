classdef plotlyfolder < dynamicprops & handle
    
    %----CLASS PROPERTIES----%
    
    properties
        FolderPath;
        FolderOptions;
    end
    
    properties (SetAccess=protected)
        file;
        url;
        errors;
    end
    
    properties (Hidden=true, SetAccess=protected)
        UserData;
        Caller;
    end
    
    %----CLASS METHODS----%
    
    methods
        
        function obj =  plotlyfolder(varargin)
            
            %--user data--%
            [un, key, domain] = signin;
            
            if isempty(un) || isempty(key)
                errkey = 'folderAuthentication:credentialsNotFound';
                error(errkey,foldermsg(errkey));
            end
            
            %--update user data--%
            obj.UserData.UserName = un;
            obj.UserData.ApiKey = key;
            obj.UserData.Domain = domain;
            
            %--initialize folder options--%
            obj.FolderOptions.OpenUrl = false;
            obj.FolderOptions.ShowUrl = false;
            
            %--initialize folderpath-%
            obj.FolderPath = ''; 
            
            %-check folderpath input-%
            if nargin > 0
            obj.FolderPath = varargin{1}; 
            end

            %--check for Key/Value--%
            if nargin > 1
                
                if mod(length(varargin(2:end)),2)~=0
                    errkey = 'folderInputs:notKeyValue';
                    error(errkey, foldermsg(errkey));
                end
                
                %--parse variable arguments--%
                for n = 2:2:length(varargin)
                    switch varargin{n}
                        case 'open'
                            obj.FolderOptions.OpenUrl = varargin{n+1};
                        case 'show_url'
                            obj.FolderOptions.ShowUrl = varargin{n+1};
                    end
                end
            end
            
            %-caller-%
            obj.Caller = plotlyapiv2(obj.UserData.UserName,obj.UserData.ApiKey);
            
        end
        
        function obj = plotly(obj)
            
            %--check for valid filename and data--%
            if isempty(obj.FolderPath)
                errkey = 'folderPath:notValid';
                error(foldermsg(errkey));
            else
                
                
                %--relative endpoint--%
                relative_endpoint = '/folders';
                
                %-payload-%
                payload.name = obj.FolderPath;
                
                %-make call-%
                obj.Caller.makecall('Post', relative_endpoint, payload);
                
                %-handle succes/errors-%
                if obj.Caller.Success
                   
                    obj.file.fid = obj.Caller.Response.fid; 
                    obj.file.parent = obj.Caller.Response.parent; 
                    
                else
                    errkey = 'folderGeneric:genericError';
                    error(errkey,[foldermsg(errkey) obj.Caller.Response.detail]);
                end
                
            end
        end
        
        function obj = upload(obj)
            obj.plotly;
        end
        
    end
end






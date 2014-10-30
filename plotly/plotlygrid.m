classdef plotlygrid < dynamicprops & handle
    
    %----CLASS PROPERTIES----%
    
    properties
        UserData;
        GridOptions;
        url;
        warnings;
        errors;
    end
    
    properties (Hidden=true)
        File;
        Data;
        Endpoints;
    end
    
    %----CLASS METHODS----%
    methods
        
        function obj =  plotlygrid(data,varargin)
            
            %--UserData--%
            [un, key, domain] = signin;
            
            if isempty(un) || isempty(key)
                errkey = 'gridAuthentication:credentialsNotFound';
                error(errkey,gridmsg(errkey));
            end
            
            %--update UserData--%
            obj.UserData.UserName = un;
            obj.UserData.ApiKey = key;
            obj.UserData.Domain = domain;
            
            %--add raw data as property--%
            obj.Data = data;
            
            %--check for Key/Value--%
            if mod(length(varargin),2)~=0
                errkey = 'gridInputs:notKeyValue';
                error(errkey, gridmsg(errkey));
            end
            
            %--initialize GridData--%
            obj.GridOptions.FileName = '';
            obj.GridOptions.WorldReadable = true;
            obj.GridOptions.Parent = '0';
            obj.GridOptions.ParentPath = '';
            obj.GridOptions.OpenUrl = true;
            obj.GridOptions.ShowUrl = true;
            
            %--parse variable arguments--%
            for n = 1:2:length(varargin)
                switch varargin{n}
                    case 'filename'
                        obj.GridOptions.FileName = varargin{n+1};
                    case 'world_readable'
                        obj.GridOptions.WorldReadable = varargin{n+1};
                    case 'parent'
                        obj.GridOptions.Parent = varargin{n+1};
                    case 'parent_path'
                        obj.GridOptions.ParentPath = varargin{n+1};
                    case 'open'
                        obj.GridOptions.OpenUrl = varargin{n+1};
                    case 'show_url'
                        obj.GridOptions.ShowUrl = varargin{n+1};
                end
            end
            
            %--grid endpoint-%
            obj.Endpoints.Grid = [obj.UserData.Domain '/v2/grids'];
            
            %--upload the grid--%
            obj.uploadGrid;
            
            %--handle successful grid creation--%
            if ~isempty(obj.File)
                
                %-update endpoints-%
                obj.Endpoints.Row = [obj.UserData.Domain '/v2/grids/' obj.File.fid '/row'];
                obj.Endpoints.Col = [obj.UserData.Domain '/v2/grids/' obj.File.fid '/col'];
                
                %-update cols-$
                obj.addColProps;
            end
            
        end
        
        function obj = uploadGrid(obj)
            
            %--check for valid filename--%
            if isempty(obj.GridOptions.FileName)
                errkey = 'gridFilename:notValid';
                display(gridmsg(errkey));
            else
                
                %--parse data--%
                if isstruct(obj.Data)
                    if ~isempty(obj.Data)
                        fields = fieldnames(obj.Data);
                        for f = 1:length(fields)
                            %format the GridData
                            gd.cols.(fields{f}).data = obj.Data.(fields{f});
                            gd.cols.(fields{f}).order = f-1;
                        end
                    end
                end
                
                %--send grid to Plotly--%
                endpoint = obj.Endpoints.Grid;
                
                %-payload-%
                payload.data = m2json(gd);
                payload.filename = obj.GridOptions.FileName;
                payload.world_readable = obj.GridOptions.WorldReadable;
                
                %-make call-%
                response = obj.makecall('Post', endpoint, payload);
                
                %-handle success/errors-%
                if isfield(response,'file')
                    
                    obj.File = response.file;
                    obj.url = response.file.web_url;
                    
                    % whoops an error occurred
                elseif isfield(response,'detail')
                    
                    errkey = 'gridGeneric:genericError';
                    error(errkey,[gridmsg(errkey) response.detail]);
                    
                end
                
                if isfield(response,'warnings')
                    obj.warnings = response.warnings;
                end
                
            end
        end
        
        function obj = appendRows(obj, data)
            
            %TODO: CHECK CORRECT INPUT STRUCTURE
            
            %-endpoint-%
            endpoint = obj.Endpoints.Row;
            
            %-payload-%
            payload.rows = m2json(data);
            
            %-make call-%
            response = obj.makecall('Post', endpoint, payload);
            
            %-handle errors-%
            if isfield(response,'detail')
                errkey = 'gridGeneric:genericError';
                error(errkey,[gridmsg(errkey) response.detail]);
            end
            
        end
        
        function obj = appendCols(obj, cols)
            
            %-cellularize input-%
            if ~iscell(cols)
                cols = {cols};
            end
            
            %-check for duplicate column names-%
            for c = 1:length(cols)
                if ~isempty(intersect(cols{c}.name,fieldnames(obj)))
                    errkey = 'gridCols:duplicateName';
                    error(errkey, gridmsg(errkey))
                end
            end
            
            %-endpoint-%
            endpoint = obj.Endpoints.Col;
            
            %-payload-%
            payload.cols = m2json(cols);
            
            %-make call-%
            response = obj.makecall('Post', endpoint, payload);
            
            %-handle errors-%
            if isfield(response,'detail')
                errkey = 'gridGeneric:genericError';
                error(errkey,[gridmsg(errkey) response.detail]);
            end
            
            %-append new columns-%
            for c = 1:length(cols)
                obj.File.cols{end + 1} = response.cols{c}; 
                obj.Data.(cols{c}.name) = cols{c}.data; 
                obj.addColProps; 
            end
        end
    end
    
    methods(Hidden=true)
        
        function obj = addColProps(obj)
            
            %--add dynamic properties--%
            fields = fieldnames(obj.Data);
            
            for d = 1:length(fields)
                if ~isprop(obj, fields{d})
                    
                    % add property field
                    addprop(obj,fields{d});
                    
                    % create column object
                    plotlycol = plotlycolumn(obj.Data.(fields{d}), ...
                        obj.File.cols{d}.name, obj.File.cols{d}.uid, obj.File.fid);
                    
                    % initialize property field
                    obj.(fields{d}) = plotlycol;
                    
                end
            end
            
        end
        
        function response = makecall(obj, request, endpoint, payload)
            
            %-initialize ouptut-%
            response = ''; 
            
            %-encoding-%
            encoder = sun.misc.BASE64Encoder();
            encoded_un_key = char(encoder.encode(java.lang.String([obj.UserData.UserName, ':', ...
                obj.UserData.ApiKey]).getBytes()));
            
            %-headers-%
            headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'},...
                'value', {['Basic ' encoded_un_key], 'MATLAB', 'application/json','*/*'});
            
            %-make call-%
            resp = urlread2(endpoint, request , m2json(payload), headers);
            
            if ~isempty(resp)
                
                %-check response-%
                response_handler(resp);
                
                %-structure resp-%
                response = loadjson(resp);
            end
        end
    end
end






classdef plotlygrid < dynamicprops & handle
    
    
    %----CLASS PROPERTIES----%
    
    properties
        UserData;
        GridOptions;
        url;
        warnings;
    end
    
    properties (Hidden=true)
        GridData;
        File;
    end
    %----CLASS METHODS----%
    methods
        
        function obj =  plotlygrid(data,varargin)
            
            %--initialize UserData--%
            [un, key, domain] = signin;
            
            if isempty(un) || isempty(key)
                error('Plotly:CredentialsNotFound',...
                    ['It looks like you haven''t set up your plotly '...
                    'account credentials yet.\nTo get started, save your '...
                    'plotly username and API key by calling:\n'...
                    '>>> saveplotlycredentials(username, api_key)\n\n'...
                    'For more help, see https://plot.ly/MATLAB or contact '...
                    'chris@plot.ly.']);
            end
            
            %--update UserData--%
            obj.UserData.UserName = un;
            obj.UserData.ApiKey = key;
            obj.UserData.Domain = domain;
            
            %--parse data--%
            if isstruct(data)
                if ~isempty(data)
                    fields = fieldnames(data);
                    for f = 1:length(fields)
                        %format the GridData
                        obj.GridData.cols.(fields{f}).data = data.(fields{f});
                        obj.GridData.cols.(fields{f}).order = f;
                    end
                end
            end
            
            %--check for Key/Value--%
            if mod(length(varargin),2)~=0
                error('must be key value');
            end
            
            %--initialize GridData--%
            obj.GridOptions.FileName = 'untitled';
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
            
            %--send grid to Plotly--%
            obj.upload;
            
            %--add dynamic properties--%
            fields = fieldnames(data);
            
            for d = 1:length(fields)
                % add property field
                addprop(obj,fields{d});
                % create column object
                plotlycol = plotlycolumn(data.(fields{d}), obj.File.cols{d}.name, obj.File.cols{d}.uid);
                % initialize property field
                obj.(fields{d}) = plotlycol;
            end
        end
        
        function obj = upload(obj)
            
            platform = 'MATLAB';
            endpoint = [obj.UserData.Domain '/v2/grids'];
            
            %-PAYLOAD-%
            payload.data = m2json(obj.GridData);
            payload.filename = obj.GridOptions.FileName;
            payload.world_readable = obj.GridOptions.WorldReadable;
            
            encoder = sun.misc.BASE64Encoder();
            encoded_un_key = char(encoder.encode(java.lang.String([obj.UserData.UserName, ':', obj.UserData.ApiKey]).getBytes()));
            headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'}, 'value', {['Basic ' encoded_un_key], platform, 'application/json','*/*'});
            
            resp = urlread2(endpoint, 'Post', m2json(payload), headers);
            
            % check response
            response_handler(resp);
            
            % add to PlotOption
            response = loadjson(resp);
            obj.File = response.file;
            obj.url = response.file.web_url;
            obj.warnings = response.warnings;
            
        end
        
        function obj = appendCols(obj, cols)
            
            %cellularize input 
            if ~iscell(cols)
                cols = {cols};
            end
           
            platform = 'MATLAB';
            endpoint = [obj.UserData.Domain '/v2/grids/' obj.File.fid '/col'];
            
            %-PAYLOAD-%
            payload.cols = m2json(cols);
            
            encoder = sun.misc.BASE64Encoder();
            encoded_un_key = char(encoder.encode(java.lang.String([obj.UserData.UserName, ':', obj.UserData.ApiKey]).getBytes()));
            headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'}, 'value', {['Basic ' encoded_un_key], platform, 'application/json','*/*'});
            
            resp = urlread2(endpoint, 'Post', m2json(payload), headers);
            
            % check response
            response_handler(resp);
            
            % structure resp
            response = loadjson(resp);
            
%             for c = 1:length(name)
%             % add property fields
%             addprop(obj, name{c});
%             
%             % create column objects
%             plotlycol = plotlycolumn(data, name, response.cols.uid);
%             
%             % initialize property fields
%             obj.(fields{d}) = plotlycol;
%             end
        end
        
        function obj = appendRows(obj, data)
            
            platform = 'MATLAB'; %not supported yet
            endpoint = [obj.UserData.Domain '/v2/grids/' obj.File.fid '/row'];
            
            %-PAYLOAD-%
            payload.rows = m2json(data);
            
            encoder = sun.misc.BASE64Encoder();
            encoded_un_key = char(encoder.encode(java.lang.String([obj.UserData.UserName, ':', obj.UserData.ApiKey]).getBytes()));
            headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'}, 'value', {['Basic ' encoded_un_key], platform, 'application/json','*/*'});
            
            urlread2(endpoint, 'Post', m2json(payload), headers);
            
        end
    end
end
classdef plotlygrid < dynamicprops & handle
    
    
    %----CLASS PROPERTIES----%
    
    properties
        UserData;
        GridOptions;
        GridData;
        Response;
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
                        obj.GridData.cols.(fields{f}).data = getfield(data,fields{f}); 
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
            obj.makePlotlyGrid; 
            
%             % post grid to plotly
%             % resp = obj.makecall;
%             resp.time = '123AB2'; 
%             resp.power = 'J67003';
%             
%             % data fields
%             datafields = fieldnames(data);
%             
%             
%             % add dynamic properties
%             for n = 1:length(datafields)
%                 % add property field
%                 addprop(obj,datafields{n});
%                 % create column object
%                 plotlycol = plotlycolumn(getfield(data,datafields{n}),'id', getfield(resp,datafields{n}));
%                 % initialize property field
%                 setfield(obj, datafields{n}, plotlycol);
%             end
            
        end
        
        function obj = makePlotlyGrid(obj)
            
            platform = 'MATLAB'; %not supported yet
            url = [obj.UserData.Domain '/v2/grids'];
            
            %--HEADERS--%
            names = {'plotly-username','plotly-apikey','content-type','accept'};
            values = {obj.UserData.UserName,obj.UserData.ApiKey,'application/json','*/*'};
            [headers(1:length(names)).name] = names{1,:}; 
            [headers(1:length(values)).value] = values{1,:}; 
            
            %-PAYLOAD-%
            payload.data = m2json(obj.GridData); 
            payload.filename = obj.GridOptions.FileName; 
            payload.world_readable = obj.GridOptions.WorldReadable; 
            payload.parent = obj.GridOptions.Parent; 
            payload.parent_path = obj.GridOptions.ParentPath; 
            
            if (is_octave)
                % use octave super_powers
                resp = urlread2(url, 'post', m2json(payload), headers);
            else
                % do it matlab way
                resp = urlread2(url, 'Post', m2json(payload), headers);
            end
            
            % check response
            response_handler(resp);
            
            % add to PlotOption
            obj.Response = loadjson(resp);
            
        end
    end
end


classdef plotlygrid < dynamicprops & handle
    
    %----CLASS PROPERTIES----%
    
    properties
        ID; 
        GridOptions;
        ColumnData;
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
        
        function obj =  plotlygrid(varargin)
            
            %--user data--%
            [un, key, domain] = signin;
            
            if isempty(un) || isempty(key)
                errkey = 'gridAuthentication:credentialsNotFound';
                error(errkey,gridmsg(errkey));
            end
            
            %--update user data--%
            obj.UserData.UserName = un;
            obj.UserData.ApiKey = key;
            obj.UserData.Domain = domain;
            
            %--initialize grid options--%
            obj.GridOptions.FileName = '';
            obj.GridOptions.WorldReadable = true;
            obj.GridOptions.Parent = '0';
            obj.GridOptions.ParentPath = '';
            obj.GridOptions.OpenUrl = false;
            obj.GridOptions.ShowUrl = false;
            
            %--add raw data as property--%
            if nargin > 0
                obj.ColumnData = varargin{1};
            else
                obj.ColumnData = struct();
            end
            
            %--check for Key/Value--%
            if nargin > 1
                
                if mod(length(varargin(2:end)),2)~=0
                    errkey = 'gridInputs:notKeyValue';
                    error(errkey, gridmsg(errkey));
                end
                
                %--parse variable arguments--%
                for n = 2:2:length(varargin)
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
            end
            
            %-caller-%
            obj.Caller = plotlyapiv2(obj.UserData.UserName,obj.UserData.ApiKey);
            
        end
        
        function obj = upload(obj)
            
            %--check for valid filename and data--%
            if isempty(obj.GridOptions.FileName)
                errkey = 'gridFilename:notValid';
                error(gridmsg(errkey));
            elseif ~isstruct(obj.ColumnData)
                errkey = 'gridData:notValid';
                error(gridmsg(errkey));
            else
                
                %--parse data--%
                fields = fieldnames(obj.ColumnData);
                gd = struct();
                
                for f = 1:length(fields)
                    %format the grid data (gd)
                    gd.cols.(fields{f}).data = obj.ColumnData.(fields{f});
                    gd.cols.(fields{f}).order = f-1;
                end
                
                %--relative endpoint--%
                relative_endpoint = '/grids';
                
                %-payload-%
                payload.data = m2json(gd);
                payload.filename = obj.GridOptions.FileName;
                payload.world_readable = obj.GridOptions.WorldReadable;
                
                %-make call-%
                obj.Caller.makecall('Post', relative_endpoint, payload);
                
                %-handle succes/errors-%
                if obj.Caller.Success
                    
                    %-update properties-%
                    obj.file = obj.Caller.Response.file;
                    obj.url = obj.Caller.Response.file.web_url;
                    obj.ID = obj.Caller.Response.file.fid;
                    
                    %-update cols-$
                    obj.addColProps;
                    
                else
                    errkey = 'gridGeneric:genericError';
                    error(errkey,[gridmsg(errkey) obj.Caller.Response.detail]);
                end
                
            end
        end
        
        function obj = appendRows(obj, data)
            
            %-endpoint-%
            if ~isempty(obj.ID)
                relative_endpoint = ['/grids/' obj.ID '/row'];
            else
                errkey = 'gridAppendRows:noGridId';
                error(errkey, gridmsg(errkey));
            end
            
            %-check input-%
            if ~ismatrix(data)
                errkey = 'gridAppendRows:invalidInput'; 
                error(errkey, gridmsg(errkey)); 
            end
            
            %-payload-%
            payload.rows = m2json(data);
            
            %-make call-%
            obj.Caller.makecall('Post', relative_endpoint, payload);
            
            %-handle succes/errors-%
            if obj.Caller.Success
                
                %-columns to be updated-%
                colnames = fieldnames(obj.ColumnData);
                appendPos = obj.longestColumn();
                
                %-update columns-%
                for c = 1:length(colnames)
                    obj.(colnames{c}) = obj.(colnames{c}).appendData(data(:,c),appendPos);
                    obj.ColumnData.(colnames{c}) = obj.(colnames{c}).ColumnData;
                end
                
            else
                errkey = 'gridGeneric:genericError';
                error(errkey,[gridmsg(errkey) obj.Caller.Response.detail]);
            end
            
        end
        
        function obj = appendCols(obj, cols)
            
            %-endpoint-%
            if ~isempty(obj.ID)
                relative_endpoint = ['/grids/' obj.ID '/col'];
            else
                errkey = 'gridAppendCols:noGridId';
                error(errkey, gridmsg(errkey));
            end
            
            %-check input-%
            if isstruct(cols)
                if ~iscell(cols)
                    cols = {cols};
                end
            else
                errkey = 'gridAppendCols:invalidInput';
                error(errkey, gridmsg(errkey));
            end
            
            %-payload-%
            payload.cols = m2json(cols);
            
            %-make call-%
            obj.Caller.makecall('Post', relative_endpoint, payload);
            
            %-handle succes/errors-%
            if obj.Caller.Success
                
                %-append new columns-%
                for c = 1:length(cols)
                    obj.file.cols{end + 1} = obj.Caller.Response.cols{c};
                    obj.ColumnData.(cols{c}.name) = cols{c}.data;
                    obj.addColProps;
                end
                
            else
                errkey = 'gridGeneric:genericError';
                error(errkey,[gridmsg(errkey) obj.Caller.Response.detail]);
            end
            
        end
    end
    
    methods(Hidden=true)
        
        function obj = addColProps(obj)
            
            %--add dynamic properties--%
            fields = fieldnames(obj.ColumnData);
            
            for d = 1:length(fields)
                if ~isprop(obj, fields{d})
                    
                    % add property field
                    addprop(obj,fields{d});
                    
                    % create column object
                    plotlycol = plotlycolumn(obj.ColumnData.(fields{d}), ...
                        obj.file.cols{d}.name, obj.file.cols{d}.uid, obj.file.fid);
                    
                    % initialize property field
                    obj.(fields{d}) = plotlycol;
                    
                end
            end
        end
        
        function maxlen = longestColumn(obj)
            
            %-column names-%
            colnames = fieldnames(obj.ColumnData);
            
            %-initial max lengt-%
            maxlen = 0;
            
            %-iterate through columns and grab longest length-%
            for c = 1:length(colnames)
                if length(obj.(colnames{c})) > maxlen
                    maxlen = length(obj.(colnames{c}));
                end
            end
            
        end  
    end
end






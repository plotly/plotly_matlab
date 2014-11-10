classdef plotlycolumn
    
    %----CLASS PROPERTIES----%
    properties
        Data;
        ID;
        Name;
    end
    
    %----CLASS METHODS----%
    methods
        
        function obj = plotlycolumn(data, name, uid, fid)
            
            %-make data a column vector-%
            if size(data,2) > 1
                data = data';
            end
            
            obj.Data = data;
            obj.Name = name;
            obj.ID = [strrep(fid,':','/') ':' uid];
            
        end
        
        %--display--%
        function obj = disp(obj)
            disp(obj.Data');
        end
        
        %--apend data-%
        function obj = appendData(obj, data, appendPos)
            
            %-make data a column vector-%
            if size(data,2) > 1
                data = data';
            end
            
            obj.Data = [obj.Data ; nan(1, diff(appendPos,length(obj.Data))) ; data];
            
        end
        
        %--overloaded plotting functions--%
        function han = plot(obj, varargin)
            [data vargs] = filterCol(obj,varargin);
            han = plot(data, vargs{:});
            referenceData(obj, han, varargin);
        end
        
        function obj = bar(obj, varargin)
            han = bar(obj, varargin{:});
            referenceData(obj, han, varargin);
        end
        
        %--extract out data from column object--%
        function [data, vars] = filterCol(obj,varargin)
            data = obj.Data;
            vars = {};
            count = 0;
            for n = 1:length(varargin)
                if isa(varargin{n},'plotlycolumn')
                    vars{count} = varargin{n}.Data;
                    count = count + 1;
                end
            end
        end
        
        %--reference data--%
        function obj = referenceData(obj, handles, varargin)
            
            userdata.plotlycolrefs{1} = obj;
            
            for n = 1:length(varargin)
                if isa(varargin{n},'plotlycolumn')
                    userdata.plotlycolrefs{n+1} = varargin{n};
                end
            end
            
            for h = 1:length(handles)
                set(handles(h), 'UserData', userdata);
            end
            
        end
    end
end
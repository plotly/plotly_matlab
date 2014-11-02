classdef plotlycolumn < double
    
    %----CLASS PROPERTIES----%
    properties
        Data;
        FID
        UID;
        Name;
    end
    
     %----CLASS METHODS----%
    methods
        
        function obj = plotlycolumn(data, name, uid, fid)
            
            %-make data a column vector-%
            if size(data,2) > 1
                data = data';
            end
            
            obj = obj@double(data);
            obj.Data = data; 
            obj.Name = name; 
            obj.UID = uid; 
            obj.FID = fid; 
            
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
    end
end
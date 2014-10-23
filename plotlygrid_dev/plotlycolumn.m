classdef plotlycolumn < double
    
    %---column properties---%
    properties
        Data;
        FID
        UID;
        Name;
    end
    
    %---column methods---%
    methods
        
        %---constructor---%
        function obj = plotlycolumn(data, name, uid, fid)
            
            obj = obj@double(data);
            obj.Data = data; 
            obj.Name = name; 
            obj.UID = uid; 
            obj.FID = fid; 
            
        end
        
        %---display---%
        function obj = disp(obj)
            disp(double(obj));
        end
        
    end
end
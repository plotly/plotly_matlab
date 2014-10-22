classdef plotlycolumn < double
    
    %---column properties---%
    properties
        Data;
        ID;
        Name;
    end
    
    %---column methods---%
    methods
        
        %---constructor---%
        function obj = plotlycolumn(data, name, id)
            
            obj = obj@double(data);
            obj.Data = data; 
            obj.Name = name; 
            obj.ID = id; 
            
        end
        
        %---display---%
        function obj = disp(obj)
            disp(double(obj));
        end
        
    end
end
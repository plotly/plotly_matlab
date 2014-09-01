classdef plotlycolumn < double
    %---column properties---%
    properties
        ID
    end
    
    %---column methods---%
    methods
        
        %---constructor---%
        function obj = plotlycolumn(data,varargin)
            
            obj = obj@double(data);
            
            % check for key/value
            if mod(length(varargin),2)~=0
                error('must be key value');
            end
            
            %parse variable arguments
            for n = 1:2:length(varargin)
                switch upper(varargin{n})
                    case 'ID'
                        obj.ID = varargin{n+1};      
                end
            end
        end
        
        %---display---%
        function obj = disp(obj)
            disp(double(obj));
        end
    end
end
classdef plotlyapiv2 < handle
    
    %----CLASS PROPERTIES----%
    properties
        Domain = 'http://api-local.plot.ly:3000/v2';
        Response
        UserData
        Success
    end
    
    %----CLASS METHODS----%
    methods
        
        %-CLASS CONSTRUCTOR-%
        function obj =  plotlyapiv2(username, api_key)
            obj.UserData.UserName = username;
            obj.UserData.ApiKey = api_key;
            obj.Success = false;
        end
        
        %-MAKE CALL-%
        function obj = makecall(obj, request, relative_endpoint, payload)
            
            %-platform-%
            platform = 'MATLAB';
            
            %-initialize response-%
            obj.Response = '';
            
            %-endpoint-%
            endpoint = [obj.Domain relative_endpoint];
            
            %-encoding-%
            encoder = sun.misc.BASE64Encoder();
            encoded_un_key = char(encoder.encode(java.lang.String([obj.UserData.UserName, ':', ...
                obj.UserData.ApiKey]).getBytes()));
            
            %-headers-%
            headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'},...
                'value', {['Basic ' encoded_un_key], platform, 'application/json','*/*'});
            
            %-make call-%
            resp = urlread2(endpoint, request , m2json(payload), headers);
            
            if ~isempty(resp)
                
                %-check response-%
                response_handler(resp);
                
                %-structure resp-%
                response = loadjson(resp);
                
                %-update properties-%
                obj.Response = response;
                
            end
            
            if isfield(obj.Response, 'detail')
                obj.Success = false;
            else
                obj.Success = true;
            end
        end
    end
end






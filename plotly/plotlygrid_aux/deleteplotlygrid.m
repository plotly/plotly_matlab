function response = deleteplotlygrid(varargin)

%-initialize input-%
response = ''; 

%-check correct input number-%
if (0 > nargin) && (nargin > 1)
    errkey = 'gridDelete:invalidInputs';
    error(errkey, gridmsg(errkey));
end

%-gridID-%
gridID = varargin{1}; %will handle plotlygrid and url input soon

%--user authentication--%
[un, key, domain] = signin;

if isempty(un) || isempty(key)
    errkey = 'gridAuthentication:credentialsNotFound';
    error(errkey,gridmsg(errkey));
end

%-endpoint-%
endpoint = [domain '/v2/grids/' gridID];

%-request-%
request = 'DELETE'; 

%-encoding-%
encoder = sun.misc.BASE64Encoder();
encoded_un_key = char(encoder.encode(java.lang.String([un, ':', key]).getBytes()));

%-headers-%
headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'},...
    'value', {['Basic ' encoded_un_key], 'MATLAB', 'application/json','*/*'});

%-make call-%
resp = urlread2(endpoint, request , '', headers);

if ~isempty(resp)
    
    %-check response-%
    response_handler(resp);
    
    %-structure resp-%
    response = loadjson(resp);
end

end
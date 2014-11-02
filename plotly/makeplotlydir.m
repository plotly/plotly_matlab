function response = makeplotlydir(folder_path)

%-initialize input-%
response = '';

%--user authentication--%
[un, key, domain] = signin;

if isempty(un) || isempty(key)
    errkey = 'gridAuthentication:credentialsNotFound';
    error(errkey,gridmsg(errkey));
end

%-input coniditioning-%
if strcmp(folder_path(end),'/')
    folder_path = folder_path(1:end); 
end

%-get path and file-%
[parent_path, filename] = fileparts(folder_path);

%-payload-%
if isempty(parent_path)
    payload.parent = '-1';
else
    payload.parent_path = ['/' parent_path];
end

payload.name = filename;

%-endpoint-%
endpoint = [domain '/v2/folders'];

%-request-%
request = 'POST'; 

%-encoding-%
encoder = sun.misc.BASE64Encoder();
encoded_un_key = char(encoder.encode(java.lang.String([un, ':', key]).getBytes()));

%-headers-%
headers = struct('name', {'Authorization','plotly_client_platform','content-type','accept'},...
    'value', {['Basic ' encoded_un_key], 'MATLAB', 'application/json','*/*'});

%-make call-%
resp = urlread2(endpoint, request , m2json(payload) , headers);

if ~isempty(resp)
    
    %-check response-%
    response_handler(resp);
    
    %-structure resp-%
    response = loadjson(resp);
end

end
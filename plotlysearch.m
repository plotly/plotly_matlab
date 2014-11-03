function resp = plotlysearch(query)

%--user data--%
[username, apikey] = signin;

%--relative endpoint--%
relative_endpoint = '/search';

%-payload-%
payload = query;

%-caller-%
caller = plotlyapiv2(username,apikey);
caller.makecall('Get', relative_endpoint, payload);
resp = caller.Response;

end
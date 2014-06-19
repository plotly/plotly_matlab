function response = signup
% SIGNUP Sign up to plot.ly with a new email and username

% Prompt for email and username
s = inputdlg({'Email','Username'},'Sign up');
if isempty(s)
    fprintf('Sign up cancelled.\n')
    response = [];
    return
end

% Post request
platform = 'MATLAB';
payload  = {'version', '0.2', 'un', s{2}, 'email', s{1},'platform',platform};
url      = 'https://plot.ly/apimkacct';
resp     = urlread(url, 'Post', payload);
response = json2struct(resp);

% Some error handling
if isfield(response,'error') && ~isempty(response.error)
    error(response.error)
end
if isfield(response,'warning') && ~isempty(response.warning)
    fprintf(response.warning)
end

% Print temp pass
fprintf('You successfully signed up!\nYour temporary password is: %s\n', response.tmp_pw)

% Prompt to save credentials
choice = questdlg('Do you want to save your credentials?', ...
                  'Plot.ly credentials', 'Yes','No','Yes');
if strcmpi(choice,'yes')
    saveplotlycredentials(response.un, response.api_key)
end
end
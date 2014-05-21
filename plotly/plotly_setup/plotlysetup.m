function plotlysetup( username, api_key )

%check inputs 
if nargin ~= 2 
    error(['Whoops! Please setup your Plotly MATLAB API by calling plotlysetup(' '''user_name''' ',' '''api_key''' ')']); 
end

%matlab root directory
mtlroot = fullfile(matlabroot,'toolbox','matlab','graphics'); %this should work on all platforms [untested] 

%working directory
wd = pwd;

%check directory exists 
plotly_api_folder = [mtlroot '/plotly/'];
[status, mess, messid] = mkdir(plotly_api_folder);
if (status == 0)
    if(~strcmp(messid, 'MATLAB:MKDIR:DirectoryExists'))
        error('plotly:savecredentials',...
            ['Error saving credentials folder at ' ...
            plotly_credentials_folder ': '... 
            mess ', ' messid '. Get in touch at ' ...
            'chris@plot.ly for support.']);
    end
end

%move a copy of the plotly api to matlab root directory
copyfile([wd '/plotly'],[plotly_api_folder]);

%add the api path to MATLAB searchpath  
fprintf('\nAdding Plotly to MATLAB toolbox directory...Done\n');  
addpath(genpath(plotly_api_folder)); 

%remove the current Plotly directory
%rmpath(genpath(pwd))

%save the MATLAB search path with the newly added Plotly MATLAB API
fprintf('Saving Plotly to MATLAB search path...Done\n'); 
%savepath; 

%add the original working directory back in the searchpath 
%addpath(genpath(pwd))

%save user credentials 
fprintf('Saving user credentials...Done\n\n'); 
saveplotlycredentials(username,api_key); 

%greet the people 
fprintf(['Welcome to Plotly! If you are new to Plotly please enter: >>plotlyhelp to get started!\n\n'])

end


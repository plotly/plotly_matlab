%----UPDATE THE PLOTLY HELP GRAPH REFERENCE----%
function updatePlotlyHelp

% remote Plotly Graph Reference url
remote = ['https://raw.githubusercontent.com/plotly/',...
    'graph_reference/master/graph_objs/matlab/graph_objs_keymeta.json'];

% download the remote content
try
    prContent = urlread(remote);
catch
    fprintf(['\nAn error occurred while trying to read the latest\n',...
        'Plotly MATLAB API graph reference from:\n',...
        'https://github.com/plotly/graph_reference.']);
    return
end

% load the json into a struct
pr = loadjson(prContent); 

% save directory
helpdir = fileparts(which('updatePlotlyHelp')); 

% pr filename 
prname = fullfile(helpdir,'plotly_reference'); 

%----save----%
save(prname,'pr'); 

end
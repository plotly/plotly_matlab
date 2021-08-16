%----UPDATE THE PLOTLY HELP GRAPH REFERENCE----%
function updateplotlyhelp

% remote Plotly Graph Reference url

% download the remote content

% !!! old remote !!!
% remote = ['https://raw.githubusercontent.com/plotly/',...
%     'graph_reference/master/graph_objs/matlab/graph_objs_keymeta.json'];

% !!! new remote -- not recommended !!!
% remote = 'https://api.plot.ly/v2/plot-schema?format=json&sha1=';

% !!! new remote -- Recommended !!!
remote = 'https://github.com/plotly/plotly.js/raw/master/dist/plot-schema.json';

fprintf('Downloading plotly-schema.json from remote...\n%s\n',remote);
newFile=false;
try
    prContent = webread(remote);
    pr = jsondecode(prContent);
    newFile=true;
catch
    fprintf(['\nAn error occurred while trying to read the latest\n',...
        'Plotly MATLAB API graph reference from:\n',...
        'https://github.com/plotly/plotly.js/blob/master/dist/plot-schema.json.\n']);
    try
        pr = loadjson('plot-schema.json');
    catch 
        fprintf('Failed to load the local file... Quiting!\n');
        return;
    end
end

if newFile
    f=fopen('plot-schema.json','w');
    fwrite(f,prContent);
    fclose(f);
end

%------------------------MATLAB SPECIFIC TWEAKS---------------------------%

%-Dump non-relevant info & simplify the content-%
% fields=fieldnames(pr.traces);
% for i = 1:numel(fields)
%     field = fields{i};
%     try
%         prN.(field) = pr.traces.(field);
%     catch
%         fprintf('No attributes for: %s | Adding entire field.\n',field);
%         prN.(field) = pr.traces.(field);
%     end
% end
% prN.layout = pr.layout.layoutAttributes;

% prN.annotation = pr.layout.layoutAttributes.annotations.items.annotation;
% prN.line = pr.line;

%-key_type changes-%
% prN.annotation.xref.key_type = 'plot_info'; 
% prN.annotation.yref.key_type = 'plot_info'; 
% prN.line.shape.key_type = 'plot_info'; 

% pr=prN;

%-------------------------------------------------------------------------%

% save directory
helpdir = fullfile(fileparts(which('updateplotlyhelp')),'plotly_reference'); 

% pr filename 
prname = fullfile(helpdir); 

%----save----%
save(prname,'pr');

end
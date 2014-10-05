function plotlyDirs = findPlotlyDirs(plotlyScriptDirs)

% initialize output
plotlyDirs = cell(1,length(plotlyScriptDirs));

for d = 1:length(plotlyScriptDirs)
    %parse filepath string at the Plotly directory
    plotlyLoc = strfind(fileparts(plotlyScriptDirs{d}),'plotly');
    plotlyDirs{d} = fullfile(plotlyScriptDirs{d}(1:plotlyLoc-1),'plotly');
end

end
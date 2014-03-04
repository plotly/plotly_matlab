function [response] = fig2plotly(f, plot_name)
% fig2plotly - plots a matlab figure object with PLOTLY
%   [response] = fig2plotly(f, plot_name)
%       f - root figure object in the form of a struct. Use f = get(gcf); to
%           get the current figure struct.
%       plot_name - a string naming the plot
%       response - a struct containing the result info of the plot
% 
% For full documentation and examples, see https://plot.ly/api

%convert figure into data and layout data structures
[data, layout] = convertFigure(f);

% send graph request
response = plotly(data, struct('layout', layout, ...
    'filename',plot_name, ...
	'fileopt', 'overwrite'));

display('Check out your plot at:')
display(response.url)

end
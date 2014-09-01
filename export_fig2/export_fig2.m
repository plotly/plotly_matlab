function export_fig2(fig, beautify, filename, format)

%----INPUT----% 
% fig: handle of figure to be converted
% beautify: binary flag 1 = use Plotly defaults, 0 = use MATLAB defaults
% fielname: name of file to be saved to specified directory
% format: one of 'png' (default), 'pdf', 'jpeg', 'svg'

%-----convert figure-----%
[plotlyfigure.data, plotlyfigure.layout] = convertFigure(get(fig), beautify);

%----saveplotlyfig-----%
saveplotlyfig(plotlyfigure, filename, format)

end
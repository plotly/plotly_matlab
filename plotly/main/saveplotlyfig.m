function p = saveplotlyfig(figure_or_data, filename, varargin)

%-----------------------------SAVEPLOTLYFIG-------------------------------%

% Save a MATLAB figure as a static image using Plotly

% [CALL]:

% p = saveplotlyfig(figure, filename)
% p = saveplotlyfig(data, filename)
% p = saveplotlyfig(figure, filename, varargin)
% p = saveplotlyfig(data, filename, varargin)

% [INPUTS]: [TYPE]{default} - description/'options'

% figure: [structure array]{} - structure with 'data' and 'layout' fields
% data: [cell array]{} - cell array of Plotly traces
% varargin: [string]{.png} - image extension ('png','jpeg','pdf','svg') 

% [OUTPUT]:

% static image save to the directory specified within the filename with the
% extension specified within filename or varargin. 

% [EXAMPLE]: 

% data.type = 'scatter';
% data.x = 1:10; 
% data.y = 1:10; 
% saveplotlyfig(data,'myimage.jpeg'); 

% [ADDITIONAL RESOURCES]:

% For full documentation and examples, see https://plot.ly/matlab/static-image-export/

%-------------------------------------------------------------------------%

%--CONSTRUCT PLOTLY FIGURE OBJECT--%
p = plotlyfig('Visible','off');

%-------------------------------------------------------------------------%

%--PARSE FIGURE_OR_DATA--%
if iscell(figure_or_data)
    p.data = figure_or_data;
elseif isstruct(figure_or_data); 
    p.data = figure_or_data.data;
    p.layout = figure_or_data.layout;
elseif isa(figure_or_data, 'plotlyfig')
    p = figure_or_data; 
else
    errkey = 'plotlySaveImage:invalidInputs'; 
    error(errkey,plotlymsg(errkey)); 
end

%-------------------------------------------------------------------------%

%--MAKE CALL TO SAVEAS METHOD--%
p.saveas(filename, varargin{:});

%-------------------------------------------------------------------------%

end

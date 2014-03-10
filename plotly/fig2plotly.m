function [response] = fig2plotly(varargin)
% fig2plotly - plots a matlab figure object with PLOTLY
%   [response] = fig2plotly()
%   [response] = fig2plotly(gcf)
%   [response] = fig2plotly(f)
%   [response] = fig2plotly(gcf, 'property', value, ...)
%   [response] = fig2plotly(f, 'property', value, ...)
%       gcf - root figure object in the form of a double.
%       f - root figure object in the form of a struct. Use f = get(gcf); to
%           get the current figure struct.
%       List of valid properties:
%           'name' - ('untitled')string, name of the plot
%           'strip' - (false)boolean, ignores all styling, uses plotly defaults
%           'open' - (true)boolean, opens a browser window with plot result
%       response - a struct containing the result info of the plot
%
% For full documentation and examples, see https://plot.ly/api

%default input
f = get(gcf);
plot_name = 'untitled';
strip_style = false;
open_browser = true;

switch numel(varargin)
    case 0
    case 1
        if isa(varargin{1}, 'double')
            f = get(varargin{1});
        end
        if isa(varargin{1}, 'struct')
            f = varargin{1};
        end
    otherwise
        if isa(varargin{1}, 'double')
            f = get(varargin{1});
        end
        if isa(varargin{1}, 'struct')
            f = varargin{1};
        end
        if mod(numel(varargin),2)~=1
            error('Invalid number of arguments')
        else
            for i=2:2:numel(varargin)
                if strcmp('strip', varargin{i})
                    strip_style = varargin{i+1};
                end
                if strcmp('name', varargin{i})
                    plot_name = varargin{i+1};
                end
                if strcmp('open', varargin{i})
                    open_browser = varargin{i+1};
                end             
            end
        end
        
end


%convert figure into data and layout data structures
[data, layout, title] = convertFigure(f, strip_style);

if numel(title)>0 && strcmp('untitled', plot_name)
    plot_name = title;
end

% send graph request
response = plotly(data, struct('layout', layout, ...
    'filename',plot_name, ...
	'fileopt', 'overwrite'));

if open_browser
    status = dos(['open ' response.url ' > nul 2> nul']);
    if status==1
        status = dos(['start ' response.url ' > nul 2> nul']);
    end
end

end
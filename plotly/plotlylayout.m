function [response] = plotlylayout(varargin)
% plotlylayout- apply layout to a plotly plot
%   [response] = plotlylayout(layout, kwargs)
%       layout - struct specifying the layout
%       kwargs - an optional argument struct
% 
% See also plotly, plotlystyle, signin, signup
% 
% For full documentation and examples, see https://plot.ly/api
    % check if signed in
    [un, key] = signin;
    if isempty(un) || isempty(key)
        error('Not signed in.')
    end
    
    %%%%%%%%%%%%%%%
    % call plotly %
    %%%%%%%%%%%%%%%
    origin = 'layout';
    args = varargin(1);
    if nargin==2
        if isstruct(varargin{end})
            structargs = varargin{end};
            f = lower(fieldnames(structargs));
            if ~any(strcmp('filename',f))
               structargs.filename = plotlysession;
            end
            if ~any(strcmp('fileopt',f))
                structargs.fileopt = NaN;
            end
        end
    else
        structargs = struct('filename', plotlysession,'fileopt',NaN);
    end

    response = makecall(args, un, key, origin, structargs);    
end
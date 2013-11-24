function [response] = plotlystyle(varargin)
% plotlystyle - apply style to the traces of a plotly plot
%   [response] = plotlystyle({data1, data2, ...}, kwargs)
%       data1 - struct specifying the style
%       kwargs - an optional argument struct
% 
% See also plotly, plotlylayout, plotlystyle, signin, signup
% 
% For full documentation and examples, see https://plot.ly/api

    % check if signed in
    [un, key] = signin;
    if isempty(un) || isempty(key)
        error('Not signed in.')
    end
    
    origin = 'style';
    if isstruct(varargin{end})
        structargs = varargin{end};
        f = lower(fieldnames(structargs));
        if ~any(strcmp('filename',f))
            structargs.filename = plotlysession;
        end
        if ~any(strcmp('fileopt',f))
            structargs.fileopt = NaN;
        end
        args = varargin(1:(end-1));
    else
        structargs = struct('filename', plotlysession,'fileopt',NaN);
        args = varargin(1:end);
    end

    response = makecall(args, un, key, origin, structargs);    
end
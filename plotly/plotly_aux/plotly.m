function [response] = plotly(varargin)
% plotly - create a graph in your plotly account
%   [response] = plotly(x1,y1,x2,y2,..., kwargs)
%   [response] = plotly({data1, data2, ...}, kwargs)
%       x1,y1 - arrays
%       data1 - a data struct with styling information
%       kwargs - an optional argument struct
%
% See also plotlylayout, plotlystyle, signin, signup
%
% For full documentation and examples, see https://plot.ly/api
origin = 'plot';
offline = true;
struct_provided = false;

if isstruct(varargin{end})
    structargs = varargin{end};
    f = lower(fieldnames(structargs));
    if ~any(strcmp('filename',f))
        if offline
            structargs.filename = 'untitled';
        else
            structargs.filename = NaN;
        end
    end
    if ~any(strcmp('fileopt',f))
        structargs.fileopt = NaN;
    end
    if any(strcmp('offline', f))
        offline = getfield(structargs, 'offline');
    end

    struct_provided = true;

    args = varargin(1:(end-1));
    
else
    
    if offline
        structargs = struct('filename', 'untitled', 'fileopt', NaN);
    else
        structargs = struct('filename', NaN,'fileopt',NaN);
    end
    args = varargin(1:end);
    struct_provided = false;
end

if offline
    if (struct_provided)
        nofig_obj = plotlynofig(varargin{1:end-1}, structargs);
    else
        nofig_obj = plotlynofig(varargin{1:end}, structargs);
    end
    nofig_obj.layout.width = 840;
    nofig_obj.layout.height = 630;
    response = nofig_obj.plotly;
    
else
    response = makecall(args, origin, structargs);
end


end
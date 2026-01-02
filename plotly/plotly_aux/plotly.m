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
    offline_given = true;
    writeFile = true;

    if isstruct(varargin{end})
        structargs = varargin{end};
        f = fieldnames(structargs);

        idx = cellfun(@(x) strcmpi(x, 'offline'), f);
        if sum(idx) == 1
            offline = structargs.(f{idx});
            offline_given = offline;
        else
            offline = true;
            offline_given = offline;
        end

        if ~any(strcmpi('filename', f))
            if offline
                structargs.filename = 'untitled';
            else
                structargs.filename = NaN;
            end
        end
        if ~any(strcmpi('fileopt',f))
            structargs.fileopt = NaN;
        end

        idx = cellfun(@(x) strcmpi(x, 'writefile'),f);
        if sum(idx) == 1
            writeFile=structargs.(f{idx});
        end

        args = varargin(1:(end-1));

    else
        if offline_given
            structargs = struct('filename', 'untitled', 'fileopt', NaN);
        else
            structargs = struct('filename', NaN, 'fileopt', NaN);
        end
        args = varargin(1:end);
    end

    if ~writeFile
        offline_given = true;
    end

    if offline_given
        obj = plotlyfig(args, structargs);
        obj.layout.width = 840;
        obj.layout.height = 630;
        response = obj.plotly;
    else
        response = makecall(args, origin, structargs);
    end
end

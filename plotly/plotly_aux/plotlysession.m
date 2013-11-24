function [filename] = plotlysession(varargin)
    % a function to save variables that are important to a plotly
    % users session.
    persistent FILENAME
    if nargin==1
        FILENAME = varargin{1};
        mlock;
    else
        filename = FILENAME;
    end
end
function [un, key] = signin(varargin)
% SIGNIN(username, api_key)  Sign In to a plotly session
%   
% See also plotly, plotlylayout, plotlystyle, signup
% 
% For full documentation and examples, see https://plot.ly/api
    persistent USERNAME KEY
    if nargin==2 && ischar(varargin{1}) && ischar(varargin{2})
        USERNAME = varargin{1};
        KEY = varargin{2};
        plotlysession('MATLAB API');
        mlock;
    else
        un = USERNAME;
        key = KEY;
    end
end
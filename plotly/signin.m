function [un, key, domain] = signin(varargin)
% SIGNIN(username, api_key)  Sign In to a plotly session
%
% See also plotly, plotlylayout, plotlystyle, signup
%
% For full documentation and examples, see https://plot.ly/api
    persistent USERNAME KEY PLOTLY_DOMAIN
    if nargin==2 && ischar(varargin{1}) && ischar(varargin{2})
        USERNAME = varargin{1};
        KEY = varargin{2};
        plotlysession('MATLAB API');
        mlock;
    elseif isempty(USERNAME) || isempty(KEY)
        creds = loadplotlycredentials();
        USERNAME = creds.username;
        KEY = creds.api_key;
    end
    un = USERNAME;
    key = KEY;
    if isempty(PLOTLY_DOMAIN)
        try
            creds = loadplotlycredentials();
            PLOTLY_DOMAIN = creds.plotly_rest_url;
        catch
            % fails cuz either creds haven't been written yet
            % or because plotly_rest_url wasn't a key in the
            % creds file.
            PLOTLY_DOMAIN = 'https://plot.ly';
        end
    end
    domain = PLOTLY_DOMAIN;
end
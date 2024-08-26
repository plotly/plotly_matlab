function plotlygenimage(figure_or_data, filename, varargin)
    [~, ~, ext] = fileparts(filename);
    if nargin < 3
        format = ext(2:length(ext));
    else
        format = varargin{1};
    end

    if (strcmp(ext,'') && nargin < 3)
        filename = [filename, '.png'];
        format = 'png';
    elseif ( ~strcmp(ext, '') && nargin < 3)
        format = ext(2:length(ext));
    elseif (strcmp(ext,'') && nargin==3)
        filename = [filename, '.', varargin{1}];
    else
        filename = [filename, '.', varargin{1}];
    end

    if isstruct(figure_or_data)
        figure = figure_or_data;
    elseif iscell(figure_or_data)
        figure = struct('data', data);
    end

    payload = struct('figure',figure,'format',format);

    [un, key, domain] = signin;

    url = [domain, '/apigenimage/'];

    headerFields = [ ...
            "plotly-username", string(un); ...
            "plotly-apikey", string(key); ...
            "plotly-version", plotly_version; ...
            "plotly-platform", "MATLAB"; ...
            "user-agent", "MATLAB" ...
    ];

    response_object = webwrite(url, payload, weboptions("HeaderFields", headerFields));
    image_data = response_object;

    fileID = fopen(filename, 'w');
    fwrite(fileID, image_data);
    fclose(fileID);
end

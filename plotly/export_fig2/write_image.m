function output = write_image(pfObj, imageFormat, filename, height, width, scale)
    % Function to write plotly figures to a supported image format, which
    % are the following: "png", "jpg", "jpeg", "webp", "svg", "pdf", "eps",
    % "json".

    debug=0;
    if nargin < 2
        imageFormat = "png";
        filename = "figure.png";
        height = pfObj.layout.height;
        width = pfObj.layout.width;
        scale = 1;
    elseif nargin < 3
        filename = "figure." + imageFormat;
        height = pfObj.layout.height;
        width = pfObj.layout.width;
        scale = 1;
    elseif nargin < 4
        height = pfObj.layout.height;
        width = pfObj.layout.width;
        scale = 1;
    elseif nargin < 5
        width = pfObj.layout.width;
        scale = 1;
    elseif nargin < 6
        scale = 1;
    end

    if strcmpi(imageFormat, "jpg")
        imageFormat = "jpeg";
    end

    wd = fileparts(fileparts(mfilename("fullpath")));
    output = [];

    if ~isa(pfObj, "plotlyfig")
        fprintf("\nError: Input is not a plotlyfig object.\n\n");
        return
    end

    if isunix()
        kExec = string(fullfile(wd,"kaleido", "kaleido"));
        cc = "cat";
    else
        kExec = string(fullfile(wd,"kaleido", "kaleido.cmd"));
        cc = "type";
    end
    plyJsLoc = string(fullfile(wd,"kaleido", "plotly-latest.min.js"));

    if ~isfile(kExec) || ~isfile(plyJsLoc)
        status = getKaleido();
    else
        status = 1;
    end

    if status == 0
        return
    end

    mjLoc = replace(string(fullfile( ...
            wd, "kaleido", "etc", "mathjax", "MathJax.js")), "\", "/");
    scope="plotly";

    % Prepare input plotly object for Kaleido
    q = struct();
    q.data.data = pfObj.data;
    q.data.layout = pfObj.layout;
    q.data.layout = rmfield(q.data.layout, "height");
    q.data.layout = rmfield(q.data.layout, "width");
    q.format = string(imageFormat);
    q.height = height;
    q.scale = scale;
    q.width = width;

    pfJson = native2unicode(jsonencode(q), "UTF-8");
    tFile = string(fullfile(wd, "kaleido", "temp.txt"));
    f = fopen(tFile, "w");
    fprintf(f, "%s", pfJson);
    fclose(f);

    cmd = [cc, " ", tFile, " | ", kExec, " ", scope, " --plotlyjs='", ...
            plyJsLoc, "' ", "--mathjax='file:///",mjLoc,"' " ...
            + "--no-sandbox --disable-gpu " ...
            + "--allow-file-access-from-files --disable-breakpad " ...
            + "--disable-dev-shm-usage"];

    if debug
        inputCmd = char(join(cmd, ""));
        fprintf("\nDebug info:\n%s\n\n", inputCmd);
    end

    [code,out] = system(char(join(cmd, "")));
    if debug
        disp(out);
    end

    if code ~= 0
        fprintf("\nFatal: Failed to run Kaleido.\n\n");
        return;
    else
        a = string(split(out,newline));
        if a(end) == ""
            a(end) = [];
        end
        output = jsondecode(a(end));
    end

    if output.code ~= 0
        fprintf("\nError: %s\n", output.message);
    else
        out = unicode2native(output.result, "UTF-8");
        out = matlab.net.base64decode(out);
        f = fopen(char(filename), "wb");
        fwrite(f, out);
        fclose(f);
    end
end

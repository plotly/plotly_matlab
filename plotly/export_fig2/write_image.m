function output = write_image(pfObj, options)
    % Function to write plotly figures to a supported image format, which
    % are the following: "png", "jpg", "jpeg", "webp", "svg", "pdf", "eps",
    % "json".
    arguments
        pfObj
        options.imageFormat string = "png"
        options.filename string = ""
        options.height double = pfObj.layout.height
        options.width double = pfObj.layout.width
        options.scale double = 1
    end

    % Set default filename based on imageFormat if not provided
    if strcmp(options.filename, "")
        options.filename = sprintf("figure.%s", options.imageFormat);
    end

    imageFormat = options.imageFormat;
    filename = options.filename;
    height = options.height;
    width = options.width;
    scale = options.scale;

    if strcmp(imageFormat, "jpg")
        imageFormat = "jpeg";
    end

    wd = fileparts(fileparts(mfilename("fullpath")));
    output = [];

    if ~isa(pfObj, "plotlyfig")
        fprintf("\nError: Input is not a plotlyfig object.\n\n");
        return
    end

    if isunix()
        kExec = fullfile(wd,"kaleido", "kaleido");
        cc = "cat";
    else
        kExec = fullfile(wd,"kaleido", "kaleido.cmd");
        cc = "type";
    end
    plyJsLoc = fullfile(wd,"kaleido", "plotly-latest.min.js");

    if ~isfile(kExec) || ~isfile(plyJsLoc)
        status = getKaleido();
        if status == 0
            return
        end
    end

    mjLoc = replace(fullfile( ...
            wd, "kaleido", "etc", "mathjax", "MathJax.js"), '\', '/');
    scope = "plotly";

    % Prepare input plotly object for Kaleido
    q = struct( ...
        "data", struct( ...
            "data", {pfObj.data}, ...
            "layout", rmfield(pfObj.layout, ["height" "width"]) ...
        ), ...
        "format", imageFormat, ...
        "height", height, ...
        "scale", scale, ...
        "width", width ...
    );

    pfJson = native2unicode(jsonencode(q), "UTF-8");
    tFile = fullfile(wd, "kaleido", "temp.txt");
    f = fopen(tFile, "w");
    fprintf(f, "%s", pfJson);
    fclose(f);

    cmd = sprintf(['%s %s | %s %s --plotlyjs=''%s'' --mathjax=''file:///%s'' ' ...
            '--no-sandbox --disable-gpu ' ...
            '--allow-file-access-from-files --disable-breakpad ' ...
            '--disable-dev-shm-usage'], cc, tFile, kExec, scope, plyJsLoc, mjLoc);

    [code,out] = system(cmd);

    if code ~= 0
        fprintf("\nFatal: Failed to run Kaleido.\n\n");
        return
    end

    a = split(out,newline);
    if strcmp(a{end}, "")
        a(end) = [];
    end
    output = jsondecode(a{end});

    if output.code ~= 0
        fprintf("\nError: %s\n", output.message);
        return
    end

    if strcmp(imageFormat, "json") || strcmp(imageFormat, "svg")
        out = unicode2native(output.result, "UTF-8");
    elseif is_octave()
        out = __base64_decode_bytes__(output.result);
    else
        out = matlab.net.base64decode(unicode2native(output.result, "UTF-8"));
    end
    f = fopen(char(filename), "wb");
    fwrite(f, out);
    fclose(f);
end

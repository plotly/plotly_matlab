function plan = buildfile
    plan = buildplan(localfunctions);
end

function packageTask(~)
    % Package the plotly folder as a toolbox in release/
    root = fileparts(mfilename('fullpath'));

    % only tracked files: a working copy also holds downloads such as the
    % Kaleido binaries under plotly/kaleido
    [status, listing] = system(sprintf('git -C "%s" ls-files plotly', root));
    if status ~= 0
        error('buildfile:git', 'git ls-files failed:\n%s', listing);
    end
    files = string(splitlines(strtrim(listing)));
    files = files(~startsWith(files, "plotly/testing/") & ~contains(files, "/Test_"));
    folders = unique(regexprep(files(endsWith(files, ".m")), '/[^/]*$', ''));

    version = regexp(fileread(fullfile(root, 'plotly', 'plotly_aux', 'plotly_version.m')), ...
        '"(\d+\.\d+\.\d+)"', 'tokens', 'once');
    version = string(version{1});

    % ship the license at the toolbox root; the copy only lives for the build
    licenseCopy = fullfile(root, 'plotly', 'LICENSE');
    copyfile(fullfile(root, 'LICENSE'), licenseCopy);
    removeLicense = onCleanup(@() delete(licenseCopy)); %#ok<NASGU>

    opts = matlab.addons.toolbox.ToolboxOptions(fullfile(root, 'plotly'), ...
        "e59f316c-4a80-11e4-9553-005056977bd0");
    opts.ToolboxName = "Plotly Graphing Library for MATLAB";
    opts.ToolboxVersion = version;
    opts.Summary = "Convert MATLAB figures into interactive plotly.js charts";
    if isprop(opts, 'Description') % removed in R2026b
        opts.Description = "fig2plotly converts MATLAB figures into interactive " + ...
            "plotly.js web charts that open in your browser, fully offline. " + ...
            "Run getplotlyoffline() once after installing to download plotly.js.";
    end
    opts.AuthorCompany = "Plotly";
    opts.ToolboxFiles = [root + "/" + files; string(licenseCopy)];
    opts.ToolboxMatlabPath = root + "/" + folders;
    opts.MinimumMatlabRelease = "R2021a";
    opts.MaximumMatlabRelease = "";
    opts.OutputFile = fullfile(root, "release", "plotly_matlab-" + version + ".mltbx");

    if ~isfolder(fullfile(root, "release"))
        mkdir(fullfile(root, "release"));
    end
    matlab.addons.toolbox.packageToolbox(opts);
end

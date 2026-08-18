function gallery = makegallerytests(varargin)
    % MAKEGALLERYTESTS Create a single-page HTML gallery from the
    % Test_plotlyfig plot tests. For every test, the gallery shows a PNG
    % export of the native Octave/MATLAB figure next to the converted
    % Plotly figure, with the test name on top and the plot-generating
    % code displayed underneath it.
    %
    % [CALL]:
    %   gallery = makegallerytests()
    %   gallery = makegallerytests('FileName', 'gallery.html')
    %   gallery = makegallerytests('Tests', {'testScatterPlotData'})
    %   gallery = makegallerytests('OutputFolder', '/path/to/folder')
    %
    % [OPTIONS]: (Name, Value)
    %   FileName     - HTML file name. Default: 'plotly_gallery_tests.html'
    %   OutputFolder - folder in which the HTML file is written.
    %                  Default: current working directory.
    %   Tests        - cellstr of test names to include.
    %                  Default: all tests in Test_plotlyfig.m.
    %   Visible      - 'off' (default) to keep the figures hidden while
    %                  the gallery is generated. Pass 'on' if your
    %                  graphics toolkit cannot print hidden figures
    %                  (Octave's fltk), 'off' otherwise.
    %   EmbedPNG     - true (default) to embed the native PNGs in the
    %                  HTML as base64 data URIs (single self-contained
    %                  file), false to link to separate .png files.
    %   SavePNGs     - true to also write the native .png files next to
    %                  the HTML. Default: false.
    %   PlotlyJS     - 'auto' (default) to embed the local offline Plotly
    %                  bundle when available and fall back to the Plotly
    %                  CDN, 'bundle' to require the local bundle, 'cdn'
    %                  to always link the CDN, 'none' to skip Plotly.
    %   Width,Height - maximum width and aspect ratio (Width:Height) of
    %                  the figure panels. The native PNGs and the Plotly
    %                  figures share the same size and shrink together
    %                  as the window narrows. Default: 640, 480
    %
    % [OUTPUT]:
    %   gallery - struct with the generated HTML file path, the Plotly JS
    %             source that was used, and the per-entry status of the
    %             native figure export and of the Plotly conversion.
    %
    % NOTE: the plot code is not duplicated here; it is parsed out of
    % Test_plotlyfig.m at runtime (the lines between
    % `fig = figure("Visible","off");` and `p = plotlyfig(fig,...)`), so
    % the gallery always reflects the current tests.

    opts = parseOptions(varargin);

    if is_octave()
        try
            pkg load statistics;
        catch
        end
    end

    if isempty(which('plotlyfig'))
        warning('makegallerytests:noPlotlyfig', ...
            ['plotlyfig was not found on the MATLAB/Octave path. ' ...
            'Run plotlysetup_offline() first; the Plotly panels will ' ...
            'report conversion errors.']);
    end

    allEntries = testEntries();
    if isempty(opts.Tests)
        names = {allEntries.name};
    else
        requested = cellstr(opts.Tests);
        ok = ismember(requested, {allEntries.name});
        if ~all(ok)
            error('makegallerytests:unknownTest', ...
                'Unknown test(s): %s. Valid names are: %s', ...
                strjoin(requested(~ok), ', '), ...
                strjoin({allEntries.name}, ', '));
        end
        names = requested;
    end

    fprintf('Generating Test_plotlyfig gallery with %d entries ...\n', numel(names));

    js = resolvePlotlyJS(lower(opts.PlotlyJS));

    entries = processEntries(names, allEntries, opts);

    parts = htmlHeader(opts, js, numel(entries));
    parts{end + 1} = htmlSummary(entries);
    for i = 1:numel(entries)
        parts = [parts htmlEntry(entries(i), i, opts)];
    end
    parts{end + 1} = sprintf('</body>\n</html>\n');

    page = char(strjoin(cellfun(@flattenChar, parts, 'UniformOutput', false), ''));

    htmlPath = fullfile(opts.OutputFolder, opts.FileName);
    fid = fopen(htmlPath, 'w');
    fwrite(fid, page);
    fclose(fid);

    gallery.html = htmlPath;
    gallery.outputFolder = opts.OutputFolder;
    gallery.plotlyJS = js.mode;
    gallery.entries = entries;
    gallery.summary = struct( ...
        'total', numel(entries), ...
        'nativeOK', sum([entries.nativeOK]), ...
        'plotlyOK', sum([entries.plotlyOK]) ...
    );

    fprintf('\nGallery written to: %s\n', htmlPath);
    fprintf('  %d/%d native figure exports OK, %d/%d Plotly conversions OK\n', ...
        gallery.summary.nativeOK, gallery.summary.total, ...
        gallery.summary.plotlyOK, gallery.summary.total);
end

function opts = parseOptions(varargs)
    opts = struct( ...
        'FileName', 'plotly_gallery_tests.html', ...
        'OutputFolder', pwd, ...
        'Tests', {{}}, ...
        'Visible', 'off', ...
        'EmbedPNG', true, ...
        'SavePNGs', false, ...
        'PlotlyJS', 'auto', ...
        'Width', 640, ...
        'Height', 480 ...
    );
    i = 1;
    while i <= numel(varargs)
        arg = varargs{i};
        if ~ischar(arg) && ~isstring(arg)
            error('makegallerytests:badOption', ...
                'Options must be given as Name, Value pairs.');
        end
        name = lower(char(arg));
        if i + 1 > numel(varargs)
            error('makegallerytests:missingValue', ...
                'Missing value for option %s.', name);
        end
        value = varargs{i + 1};
        switch name
            case 'filename'
                opts.FileName = char(value);
            case 'outputfolder'
                opts.OutputFolder = char(value);
            case 'tests'
                opts.Tests = cellstr(value);
            case 'visible'
                opts.Visible = char(value);
            case 'embedpng'
                opts.EmbedPNG = logical(value);
            case 'savepngs'
                opts.SavePNGs = logical(value);
            case 'plotlyjs'
                opts.PlotlyJS = char(value);
            case 'width'
                opts.Width = value;
            case 'height'
                opts.Height = value;
            otherwise
                error('makegallerytests:unknownOption', ...
                    'Unknown option %s.', name);
        end
        i = i + 2;
    end
end

function entries = testEntries()
    % Parse the Test_plotlyfig*.m files next to this file and extract,
    % for every test method, the plot-generating code between the
    % `fig = figure("Visible","off");` line and the
    % `p = plotlyfig(fig,...)` line. Also record whether the test is
    % guarded with `if is_octave() return` (Octave-unsupported feature).
    folder = fileparts(mfilename('fullpath'));
    if isempty(which('testParams'))
        addpath(fullfile(folder, 'testing'));
    end
    testFiles = dir(fullfile(folder, 'Test_plotlyfig*.m'));

    entries = struct('name', {}, 'code', {}, 'guarded', {}, 'guardReason', {});

    for fi = 1:numel(testFiles)
        if strcmp(testFiles(fi).name, 'Test_plotlyfig_perf.m')
            continue
        end
        testFile = fullfile(folder, testFiles(fi).name);
        fid = fopen(testFile, 'r');
        if fid < 0
            error('makegallerytests:noTestFile', ...
                'Cannot open %s', testFile);
        end
        text = fread(fid, Inf, '*char')';
        fclose(fid);
        lines = strsplit(text, sprintf('\n'));

        i = 1;
        n = numel(lines);
        while i <= n
            toks = regexp(lines{i}, '^\s{8}function\s+(test\w+)\s*\(tc(?:,\s*\w+)*\)\s*$', ...
                'tokens', 'once');
            if isempty(toks)
                i = i + 1;
                continue;
            end
            name = toks{1};

            % the method ends at the first later line of exactly 8 spaces + end
            j = i + 1;
            while j <= n && isempty(regexp(lines{j}, '^\s{8}end\s*$', 'once'))
                j = j + 1;
            end
            body = lines(i + 1:j - 1);

            figIdx = [];
            pIdx = [];
            for k = 1:numel(body)
                if isempty(figIdx) && ...
                        ~isempty(regexp(body{k}, '^\s*fig\s*=\s*figure\(', 'once'))
                    figIdx = k;
                end
                if ~isempty(regexp(body{k}, '^\s*p\s*=\s*plotlyfig\(fig,', 'once'))
                    pIdx = k;
                    break;
                end
            end

            % extraction starts after any leading comments and the Octave
            % guard block (`if is_octave() return ... end`), so the code
            % runs standalone; setup statements before `fig` (tables,
            % digraphs, legend labels, ...) are kept
            startIdx = 1;
            k = 1;
            while k <= numel(body) && ...
                    ~isempty(regexp(body{k}, '^\s*%', 'once'))
                k = k + 1;
            end
            if k <= numel(body) && ...
                    ~isempty(regexp(body{k}, '^\s*if\s+is_octave\(\)', 'once'))
                while k <= numel(body) && ...
                        isempty(regexp(body{k}, '^\s*end\s*$', 'once'))
                    k = k + 1;
                end
                k = k + 1; % skip the guard's end line
            end
            startIdx = k;

            guarded = false;
            guardReason = '';
            if ~isempty(figIdx)
                for k = 1:figIdx - 1
                    if ~isempty(regexp(body{k}, '^\s*if\s+is_octave\(\)', 'once')) ...
                            && k + 1 <= numel(body) ...
                            && ~isempty(regexp(body{k + 1}, '^\s*return', 'once'))
                        guarded = true;
                        m = regexp(body{k + 1}, '^\s*return\s*%\s*(.*)$', ...
                            'tokens', 'once');
                        if ~isempty(m)
                            guardReason = strtrim(m{1});
                        end
                        break;
                    end
                end
            end

            if ~isempty(figIdx) && ~isempty(pIdx) && pIdx > figIdx
                % parameterized methods: prepend the first combination as
                % assignments so the extracted code runs standalone
                prepends = {};
                try
                    [combos, ~, argNames] = testParams(testFile, name);
                    if ~isempty(combos)
                        for v = 1:numel(combos{1})
                            text = valueToEval(combos{1}{v});
                            if isempty(text)
                                prepends = {};
                                break;
                            end
                            prepends{end+1} = sprintf('%s = %s;', argNames{v}, text); %#ok<AGROW>
                        end
                    end
                catch
                    prepends = {};
                end
                code = strjoin(body(startIdx:pIdx - 1), sprintf('\n'));
                if ~isempty(prepends)
                    code = [strjoin(prepends, sprintf('\n')) sprintf('\n') code];
                end
                entries(end + 1) = struct( ... %#ok<AGROW>
                    'name', name, ...
                    'code', code, ...
                    'guarded', guarded, ...
                    'guardReason', guardReason ...
                );
            end
            i = j;
        end
    end
end

function fig = runCode(code)
    % evaluate the extracted plot code in this function's workspace and
    % hand back the figure handle it created
    eval(code);
end

function entries = processEntries(names, allEntries, opts)
    entries = struct( ...
        'name', {}, 'code', {}, 'guarded', {}, 'guardReason', {}, ...
        'skipped', {}, ...
        'nativeOK', {}, 'plotlyOK', {}, ...
        'nativeError', {}, 'plotlyError', {}, ...
        'plotlyStack', {}, ...
        'image', {}, 'pngFile', {}, ...
        'plotlyJSON', {} ...
    );

    for i = 1:numel(names)
        name = names{i};
        idx = find(strcmp({allEntries.name}, name), 1);
        e = allEntries(idx);

        entry = struct( ...
            'name', name, 'code', e.code, ...
            'guarded', e.guarded, 'guardReason', e.guardReason, ...
            'skipped', false, ...
            'nativeOK', false, 'plotlyOK', false, ...
            'nativeError', '', 'plotlyError', '', ...
            'plotlyStack', '', ...
            'image', '', 'pngFile', '', ...
            'plotlyJSON', struct() ...
        );

        if is_octave() && e.guarded
            entry.skipped = true;
        else
            try
                fig = runCode(e.code);
                set(fig, 'Visible', opts.Visible);
                drawnow;
            catch e2
                entry.nativeError = e2.message;
            end

            % NOTE: the export must come from the native figure handle via
            % print(); it must NOT come from the converted Plotly object.
            if isempty(entry.nativeError)
                pngName = sprintf('%02d_%s.png', i, name);
                if opts.EmbedPNG && ~opts.SavePNGs
                    pngPath = [tempname() '.png'];
                    deleteTmp = true;
                else
                    pngPath = fullfile(opts.OutputFolder, pngName);
                    deleteTmp = false;
                end
                try
                    if is_octave()
                        % print() renders the PNG at the figure's
                        % __device_pixel_ratio__; on HiDPI displays that
                        % doubles the -S size (e.g. 1280x960 from 640x480).
                        % Temporarily force a ratio of 1 so the PNG comes
                        % out at exactly the requested size on any display
                        dpr = [];
                        try
                            dpr = get(fig, '__device_pixel_ratio__');
                            set(fig, '__device_pixel_ratio__', 1);
                        catch
                        end
                        print(fig, '-dpng', '-S640,480', pngPath);
                        if ~isempty(dpr)
                            try
                                set(fig, '__device_pixel_ratio__', dpr);
                            catch
                            end
                        end
                    else
                        print(fig, '-dpng', pngPath);
                    end
                    fid = fopen(pngPath, 'rb');
                    pngBytes = fread(fid, Inf, 'uint8')';
                    fclose(fid);
                    if deleteTmp
                        delete(pngPath);
                    end
                    entry.image = base64DataURI(pngBytes);
                    entry.pngFile = pngName;
                    entry.nativeOK = true;
                catch e2
                    entry.nativeError = e2.message;
                end
            end

            if entry.nativeOK
                try
                    p = plotlyfig(fig, 'visible', 'off');
                    % plotlyfig sets autosize to false and stores a fixed
                    % pixel size (1.5x the figure) in the layout. With both
                    % width and height set, Plotly's responsive mode never
                    % resizes the figure, so it cannot track its HTML
                    % container. Enable autosize and drop the fixed size so
                    % the figure fills the container instead; the container
                    % CSS below matches the native PNG's shape
                    layout = p.layout;
                    if isfield(layout, 'width')
                        layout = rmfield(layout, 'width');
                    end
                    if isfield(layout, 'height')
                        layout = rmfield(layout, 'height');
                    end
                    layout.autosize = true;
                    entry.plotlyJSON = struct( ...
                        'data', jsonForScript(m2json(p.data)), ...
                        'layout', jsonForScript(m2json(layout)) ...
                    );
                    entry.plotlyOK = true;
                catch e2
                    entry.plotlyError = e2.message;
                    entry.plotlyStack = '';
                    for st = 1:numel(e2.stack)
                        entry.plotlyStack = [entry.plotlyStack ...
                            sprintf('%s (line %d)\n', e2.stack(st).name, e2.stack(st).line)];
                    end
                end
            end
            if ~entry.plotlyOK && isempty(entry.plotlyError)
                entry.plotlyError = 'Skipped because the native figure export failed.';
            end
        end

        try
            close(fig);
        catch
        end

        entries(i) = entry;

        if entry.skipped
            fprintf('  %-38s skipped (Octave)\n', name);
        else
            fprintf('  %-38s native: %-6s plotly: %-6s\n', name, ...
                tern(entry.nativeOK, 'OK', 'FAIL'), ...
                tern(entry.plotlyOK, 'OK', 'FAIL'));
            if ~entry.plotlyOK && ~isempty(entry.plotlyError)
                fprintf('      plotly error: %s\n', entry.plotlyError);
                if ~isempty(entry.plotlyStack)
                    fprintf('      stack:\n%s', entry.plotlyStack);
                end
            end
        end
    end
end

function parts = htmlHeader(opts, js, nEntries)
    if is_octave()
        try
            runtime = sprintf('%s (%s graphics toolkit)', ...
                version(), graphics_toolkit());
        catch
            runtime = version();
        end
    else
        runtime = version();
    end

    % the embedded bundle must never pass through sprintf/fprintf, which
    % would interpret backslash sequences inside the JavaScript
    if js.embedded
        jsTag = ['<script type="text/javascript">' sprintf('\n') ...
            js.script sprintf('\n</script>\n')];
    elseif ~isempty(js.script)
        jsTag = ['<script src="' js.script '"></script>' sprintf('\n')];
    else
        jsTag = '';
    end

    % the figure panel size is defined once below (:root variables);
    % the page width, the PNG cap and the Plotly containers all derive
    % from it, so changing Width/Height needs no other edits
    fmt = [ ...
        '<!DOCTYPE html>\n' ...
        '<html lang="en">\n' ...
        '<head>\n' ...
        '<meta charset="utf-8">\n' ...
        '<meta name="viewport" content="width=device-width, initial-scale=1">\n' ...
        '<title>Test_plotlyfig Plotly Gallery</title>\n' ...
        '<style>\n' ...
        ':root { --fig-width: %d; --fig-height: %d; ' ...
        '--panel-gap: 16px; --page-padding: 24px; }\n' ...
        'body { box-sizing: border-box; ' ...
        'max-width: calc(2 * var(--fig-width) * 1px + var(--panel-gap) + 2 * var(--page-padding)); ' ...
        'font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif; ' ...
        'margin: 0; padding: var(--page-padding); background: #f6f8fa; color: #1f2328; }\n' ...
        'h1 { margin: 0 0 4px; }\n' ...
        '.subtitle { color: #57606a; margin: 0 0 20px; }\n' ...
        '.summary { border-collapse: collapse; margin: 0 0 24px; font-size: 13px; }\n' ...
        '.summary th, .summary td { border: 1px solid #d0d7de; padding: 3px 10px; text-align: left; }\n' ...
        '.summary th { background: #eaeef2; }\n' ...
        '.ok { color: #116329; }\n' ...
        '.fail { color: #cf222e; }\n' ...
        '.entry { background: #fff; border: 1px solid #d0d7de; border-radius: 8px; ' ...
        'padding: 16px; margin-bottom: 24px; }\n' ...
        '.entry h2 { margin: 0 0 8px; font-size: 18px; }\n' ...
        '.chip { display: inline-block; padding: 2px 10px; border-radius: 999px; ' ...
        'font-size: 12px; margin-left: 6px; vertical-align: middle; }\n' ...
        '.chip.ok { background: #dafbe1; color: #116329; }\n' ...
        '.chip.fail { background: #ffebe9; color: #cf222e; }\n' ...
        '.codebox { background: #f6f8fa; border: 1px solid #d0d7de; border-radius: 6px; ' ...
        'padding: 10px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; ' ...
        'font-size: 13px; overflow-x: auto; margin: 8px 0 12px; }\n' ...
        '.panels { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); ' ...
        'gap: var(--panel-gap); }\n' ...
        '.panel h3 { margin: 0 0 8px; font-size: 14px; color: #57606a; font-weight: 600; }\n' ...
        '.panel img { max-width: min(100%%, calc(var(--fig-width) * 1px)); ' ...
        'border: 1px solid #d0d7de; border-radius: 6px; background: #fff; }\n' ...
        '.err { color: #cf222e; font-size: 13px; white-space: pre-wrap; ' ...
        'background: #fff5f5; border: 1px solid #ffcecb; border-radius: 6px; padding: 8px; }\n' ...
        '.plotlybox { width: 100%%; max-width: calc(var(--fig-width) * 1px); ' ...
        'aspect-ratio: var(--fig-width) / var(--fig-height); }\n' ...
        '</style>\n' ...
        '</head>\n' ...
        '<body>\n' ...
        '<h1>Test_plotlyfig tests &rarr; Plotly gallery</h1>\n' ...
        '<p class="subtitle">Generated %s with %s &middot; %d tests &middot; ' ...
        'Plotly JS: %s &middot; The plot code is parsed from Test_plotlyfig.m &middot; ' ...
        'The PNGs are exported from the native figures with print(), not from ' ...
        'the converted Plotly objects.</p>\n' ...
    ];
    parts = {sprintf(fmt, opts.Width, opts.Height, datestr(now), ...
        runtime, nEntries, js.mode), jsTag};
end

function str = htmlSummary(entries)
    fmt = ['<table class="summary">\n' ...
        '<thead><tr><th>test</th><th>native figure</th><th>plotly</th></tr></thead>\n' ...
        '<tbody>\n'];
    str = sprintf(fmt);
    rowFmt = ['<tr><td><a href="#fn-%s">%s</a></td><td>%s</td><td>%s</td></tr>\n'];
    for i = 1:numel(entries)
        if entries(i).skipped
            nativeChip = '<span class="fail">SKIP</span>';
            plotlyChip = '<span class="fail">SKIP</span>';
        else
            nativeChip = tern(entries(i).nativeOK, ...
                '<span class="ok">OK</span>', '<span class="fail">FAIL</span>');
            plotlyChip = tern(entries(i).plotlyOK, ...
                '<span class="ok">OK</span>', '<span class="fail">FAIL</span>');
        end
        str = [str sprintf(rowFmt, entries(i).name, entries(i).name, ...
            nativeChip, plotlyChip)];
    end
    str = [str sprintf('</tbody>\n</table>\n')];
end

function parts = htmlEntry(entry, i, opts)
    parts = {};

    parts{end + 1} = sprintf('<section class="entry" id="fn-%s">\n', entry.name);
    parts{end + 1} = sprintf('<h2><code>%s</code>', entry.name);
    if entry.skipped
        parts{end + 1} = sprintf('<span class="chip fail">Octave: not supported</span>');
    else
        parts{end + 1} = chipTag(entry.nativeOK, 'native');
        parts{end + 1} = chipTag(entry.plotlyOK, 'plotly');
    end
    parts{end + 1} = sprintf('</h2>\n');

    % htmlEscape output is appended by concatenation, never through
    % sprintf, to keep backslash characters in the escaped text intact
    codeShown = entry.code;
    if entry.guarded
        codeShown = [sprintf('%% [Octave: skipped] %s\n', entry.guardReason) ...
            codeShown];
    end
    parts{end + 1} = [sprintf('<pre class="codebox"><code>') ...
        htmlEscape(codeShown) sprintf('</code></pre>\n')];
    parts{end + 1} = sprintf('<div class="panels">\n');

    parts{end + 1} = sprintf(['<div class="panel">\n' ...
        '<h3>Native figure</h3>\n']);
    if entry.skipped
        parts{end + 1} = [sprintf('<p class="err">') ...
            htmlEscape(sprintf('Not supported in Octave: %s', entry.guardReason)) ...
            sprintf('</p>\n')];
    elseif entry.nativeOK
        if opts.EmbedPNG
            parts{end + 1} = [sprintf('<img src="') entry.image ...
                sprintf('" alt="%s native figure">\n', entry.name)];
        else
            parts{end + 1} = [sprintf('<img src="') entry.pngFile ...
                sprintf('" alt="%s native figure">\n', entry.name)];
        end
    else
        parts{end + 1} = [sprintf('<p class="err">') ...
            htmlEscape(entry.nativeError) sprintf('</p>\n')];
    end
    parts{end + 1} = sprintf('</div>\n');

    parts{end + 1} = sprintf(['<div class="panel">\n' ...
        '<h3>Plotly figure</h3>\n']);
    if entry.skipped
        parts{end + 1} = sprintf('<p class="err">Skipped.</p>\n');
    elseif entry.plotlyOK
        divId = sprintf('plotly-%d', i);
        % the container is sized purely by CSS like the native PNG: it
        % fills the panel width, capped at the --fig-width variable with
        % the --fig-width/--fig-height shape. The layout has no fixed
        % pixel size, so Plotly's responsive mode follows the container
        divFmt = ['<div id="%s" class="plotlybox"></div>\n'];
        parts{end + 1} = sprintf(divFmt, divId);

        % the JSON comes from m2json(); it is appended with char
        % concatenation, never through sprintf, so that backslash
        % sequences inside the JSON survive untouched
        scriptPart = [sprintf('<script type="text/javascript">\n') ...
            sprintf('Plotly.newPlot("%s", ', divId) ...
            entry.plotlyJSON.data [', '] entry.plotlyJSON.layout ...
            sprintf(', {"responsive": true});\n</script>\n')];
        parts{end + 1} = scriptPart;
    else
        parts{end + 1} = [sprintf('<p class="err">') ...
            htmlEscape(entry.plotlyError) sprintf('</p>\n')];
        if ~isempty(entry.plotlyStack)
            parts{end + 1} = [sprintf('<pre class="err">') ...
                htmlEscape(entry.plotlyStack) sprintf('</pre>\n')];
        end
    end
    parts{end + 1} = sprintf('</div>\n');

    parts{end + 1} = sprintf('</div>\n');
    parts{end + 1} = sprintf('</section>\n\n');
end

function chip = chipTag(ok, label)
    if ok
        chip = sprintf('<span class="chip ok">%s OK</span>', label);
    else
        chip = sprintf('<span class="chip fail">%s FAIL</span>', label);
    end
end

function s = valueToEval(v)
    % render one parameter value as an evaluable literal for the prepend
    % assignments; '' when the value cannot be rendered (the gallery
    % entry then reports the error)
    if ischar(v)
        s = sprintf('''%s''', strrep(v, '''', ''''''));
    elseif isstring(v) && isscalar(v)
        s = sprintf('"%s"', char(v));
    elseif isnumeric(v) && isscalar(v)
        s = strtrim(sprintf('%.17g', v));
    elseif islogical(v) && isscalar(v)
        if v, s = 'true'; else, s = 'false'; end
    else
        s = '';
    end
end

function json = jsonForScript(rawJson)
    % make the m2json output safe to embed inside a <script> element:
    % replace real line breaks with JSON escapes and break up any
    % "</script" sequence that would close the element prematurely
    json = strrep(strrep(rawJson, sprintf('\n'), '\n'), sprintf('\r'), '\r');
    json = strrep(json, '</script', '<\/script');
end

function js = resolvePlotlyJS(mode)
    js.mode = mode;
    js.script = '';
    js.embedded = false;

    if strcmpi(mode, 'cdn')
        js.mode = 'cdn';
        js.script = 'https://cdn.plot.ly/plotly-latest.min.js';
    elseif strcmpi(mode, 'bundle') || strcmpi(mode, 'auto')
        % look for the local offline bundle (same location as plotlyoffline)
        bundleFile = fullfile(userHome(), '.plotly', 'plotlyjs', ...
            'plotly-matlab-offline-bundle.js');
        if exist(bundleFile, 'file')
            try
                js.mode = 'bundle';
                js.script = readBundle(bundleFile);
                js.embedded = true;
                return;
            catch
            end
        end
        if strcmpi(mode, 'bundle')
            error('makegallerytests:bundleNotFound', ...
                ['Offline Plotly bundle not found at: %s. ' ...
                'Run getplotlyoffline() first.'], bundleFile);
        end
        js.mode = 'cdn';
        js.script = 'https://cdn.plot.ly/plotly-latest.min.js';
    end
end

function bundle = readBundle(bundleFile)
    % read the offline Plotly bundle. Bundles saved by getplotlyoffline
    % were pre-escaped for sprintf with escapechars (every '%' and every
    % backslash was doubled); detect that and undo it so the browser
    % receives the byte-accurate JavaScript. Raw bundles are returned
    % unchanged.
    bundle = fileread(bundleFile);
    c = uint8(bundle);
    isPct = c == uint8('%');
    isBk = c == uint8('\');
    nextPct = [isPct(2:end) false];
    nextBk = [isBk(2:end) false];
    prevPct = [false isPct(1:end - 1)];
    prevBk = [false isBk(1:end - 1)];
    singlePct = isPct & ~nextPct & ~prevPct;
    singleBk = isBk & ~nextBk & ~prevBk;
    if any(singlePct) || any(singleBk)
        return;
    end
    % regexprep matches non-overlapping pairs, unlike strrep which would
    % re-match on the doubled text and collapse pairs too far
    bundle = regexprep(bundle, '%%', char(1));
    bundle = regexprep(bundle, '\\\\', char(2));
    bundle = strrep(bundle, char(1), '%');
    bundle = strrep(bundle, char(2), '\');
end

function d = userHome()
    if is_octave()
        d = getenv('HOME');
        if isempty(d)
            d = getenv('USERPROFILE');
        end
    else
        try
            d = char(java.lang.System.getProperty('user.home'));
        catch
            d = getenv('USERPROFILE');
        end
    end
end

function row = flattenChar(p)
    % strjoin requires every element to be a char row vector; strings
    % and cells convert to padded char matrices, so flatten afterwards
    if iscell(p) || isstring(p)
        p = char(p);
    end
    row = p(:)';
end

function clean = htmlEscape(str)
    clean = strrep(str, '&', '&amp;');
    clean = strrep(clean, '<', '&lt;');
    clean = strrep(clean, '>', '&gt;');
    clean = strrep(clean, '"', '&quot;');
end

function uri = base64DataURI(bytes)
    uri = ['data:image/png;base64,' base64Encode(bytes)];
end

function b64 = base64Encode(bytes)
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    n = numel(bytes);
    if n == 0
        b64 = '';
        return;
    end
    pad = mod(3 - mod(n, 3), 3);
    b = reshape([bytes(:); zeros(pad, 1)], 3, []);
    idx = zeros(4, size(b, 2));
    idx(1, :) = bitshift(b(1, :), -2) + 1;
    idx(2, :) = bitshift(bitand(b(1, :), 3), 4) + bitshift(b(2, :), -4) + 1;
    idx(3, :) = bitshift(bitand(b(2, :), 15), 2) + bitshift(b(3, :), -6) + 1;
    idx(4, :) = bitand(b(3, :), 63) + 1;
    b64 = char(alphabet(idx));
    b64 = b64(:)';
    if pad > 0
        b64(end - pad + 1:end) = '=';
    end
end

function out = tern(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end

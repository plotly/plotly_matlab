function diag_untitled_filename(outRoot)
    % Temporary CI diagnostic for the JOSS review report that fig2plotly
    % errors on subplot/tiledlayout figures without per-axis titles.
    % Throwaway branch only; not meant to be merged.

    outRoot = fullfile(pwd, outRoot);
    if ~exist(outRoot, 'dir'), mkdir(outRoot); end
    diary(fullfile(outRoot, 'diag.log'));
    cleanup = onCleanup(@() diary('off'));

    section('ENVIRONMENT');
    fprintf('version: %s\n', version);
    fprintf('computer: %s\n', computer);
    fprintf('pwd: %s\n', pwd);
    fprintf('which fig2plotly: %s\n', which('fig2plotly'));
    fprintf('which parseString: %s\n', which('parseString'));
    fprintf('which handleFileName: %s\n', which('handleFileName'));

    section('OFFLINE BUNDLE (as plotlysetup_offline does)');
    bundleFile = fullfile(getuserdir(), '.plotly', 'plotlyjs', ...
        'plotly-matlab-offline-bundle.js');
    fprintf('bundle file: %s\n', bundleFile);
    fprintf('exists before: %d\n', exist(bundleFile, 'file') == 2);
    try
        getplotlyoffline('https://cdn.plot.ly/plotly-2.35.3.min.js');
    catch err
        printErr(err);
    end
    haveBundle = exist(bundleFile, 'file') == 2;
    fprintf('exists after: %d\n', haveBundle);
    if haveBundle
        d = dir(bundleFile);
        fprintf('bundle bytes: %d\n', d.bytes);
    end

    section('STANDALONE: plotlyoffline filename steps with a string name');
    s = "untitled";
    show('s', s);
    cleanName = s(s ~= ' ');
    show('cleanFilename', cleanName);
    htmlName = [cleanName '.html'];
    show('htmlFilename', htmlName);
    filePath = fullfile(tempdir, htmlName);
    show('fullfile(tempdir, htmlFilename)', filePath);
    fid = [];
    try
        fid = fopen(filePath, 'w');
        show('fid', fid);
    catch err
        fprintf('fopen threw:\n'); printErr(err);
    end
    try
        fprintf(fid, '%s', 'x');
        fprintf('fprintf(fid, ...) OK\n');
    catch err
        fprintf('fprintf threw:\n'); printErr(err);
    end
    try
        fclose(fid);
        fprintf('fclose(fid) OK\n');
    catch err
        fprintf('fclose threw:\n'); printErr(err);
    end

    section('STANDALONE: parseString and title String types');
    show('parseString('''', ''tex'')', parseString('', 'tex'));
    show('parseString('''', ''none'')', parseString('', 'none'));
    show('parseString(''A'', ''tex'')', parseString('A', 'tex'));
    show('parseString(''A b'', ''tex'')', parseString('A b', 'tex'));
    f = figure('Visible', 'off');
    ax = axes(f);
    show('untitled axes Title.String', get(get(ax, 'Title'), 'String'));
    title(ax, 'A');
    show('titled axes Title.String', get(get(ax, 'Title'), 'String'));
    close(f);

    section('CASES');
    cases = {'single_notitle', 'single_title', ...
        'subplot_notitles', 'subplot_title_first', 'subplot_title_last', 'subplot_titles', ...
        'tiled_notitles', 'tiled_title_first', 'tiled_title_last', 'tiled_titles', ...
        'tiled_layouttitle_only'};
    summary = {};
    for c = 1:numel(cases)
        name = cases{c};
        fprintf('\n---------- %s ----------\n', name);
        summary(end+1, :) = runCase(outRoot, name, {}, haveBundle); %#ok<AGROW>
        fprintf('\n---------- %s (explicit filename) ----------\n', name);
        summary(end+1, :) = runCase(outRoot, [name '_named'], ...
            {'filename', ['named_' name]}, haveBundle); %#ok<AGROW>
    end

    section('SUMMARY');
    for r = 1:size(summary, 1)
        fprintf('%-34s convert: %-5s fig2plotly: %-5s %s\n', summary{r, :});
    end
end

function row = runCase(outRoot, name, extraArgs, haveBundle)
    convertResult = 'FAIL';
    fig2plotlyResult = 'FAIL';
    detail = '';
    baseName = regexprep(name, '_named$', '');

    f = figure('Visible', 'off');
    try
        buildCase(f, baseName);
    catch err
        fprintf('native build threw:\n'); printErr(err);
        close(f);
        row = {name, 'n/a', 'n/a', 'native build failed'};
        return
    end

    axs = findobj(f, 'Type', 'axes');
    fprintf('findobj axes (in conversion order source):\n');
    for i = 1:numel(axs)
        str = get(get(axs(i), 'Title'), 'String');
        fprintf('  ax(%d) pos=%s title=%s\n', i, mat2str(get(axs(i), 'Position'), 3), describe(str));
    end

    % conversion only, then the filename step on its own
    try
        lastwarn('');
        p = plotlyfig(f, 'visible', 'off');
        convertResult = 'OK';
        fprintf('plotlyfig OK: %d traces, %d annotations, NumTexts=%d\n', ...
            numel(p.data), numel(p.layout.annotations), p.State.Figure.NumTexts);
        for t = 1:p.State.Figure.NumTexts
            txt = p.State.Text(t);
            str = '';
            try str = get(txt.Handle, 'String'); catch, end
            fprintf('  State.Text(%d) Title=%d String=%s\n', t, txt.Title, describe(str));
        end
        show('FileName before handleFileName', p.PlotOptions.FileName);
        try
            handleFileName(p);
            show('FileName after handleFileName', p.PlotOptions.FileName);
        catch err
            fprintf('handleFileName threw:\n'); printErr(err);
        end
        printWarn();
    catch err
        fprintf('plotlyfig threw:\n'); printErr(err);
    end

    % a fresh figure, so the probe's plotlyfig listeners (which sync the
    % figure Name with FileName) cannot influence the fig2plotly run
    close(f);
    clear p
    f = figure('Visible', 'off');
    buildCase(f, baseName);

    % full fig2plotly from its own folder, as the reviewer ran it (SaveFolder = pwd)
    caseDir = fullfile(outRoot, name);
    if ~exist(caseDir, 'dir'), mkdir(caseDir); end
    oldDir = cd(caseDir);
    try
        lastwarn('');
        args = [{'open', false, 'visible', 'off'}, extraArgs];
        if ~haveBundle
            args = [args, {'include_plotlyjs', false}];
            fprintf('(no bundle: include_plotlyjs false)\n');
        end
        p2 = fig2plotly(f, args{:});
        fig2plotlyResult = 'OK';
        show('fig2plotly FileName', p2.PlotOptions.FileName);
        show('fig2plotly url', p2.url);
        printWarn();
    catch err
        fprintf('fig2plotly threw:\n'); printErr(err);
        detail = err.message;
        detail = detail(1:min(end, 90));
        detail(detail == newline) = ' ';
    end
    cd(oldDir);

    files = dir(caseDir);
    files = files(~[files.isdir]);
    fprintf('files written in %s: %d\n', caseDir, numel(files));
    for i = 1:numel(files)
        fprintf('  %s (%d bytes)\n', files(i).name, files(i).bytes);
        if ~isempty(regexp(files(i).name, '\.html$', 'once'))
            txt = fileread(fullfile(caseDir, files(i).name));
            fprintf('    has Plotly.newPlot: %d, "type" count: %d, inlined bundle: %d\n', ...
                ~isempty(strfind(txt, 'Plotly.newPlot')), numel(strfind(txt, '"type"')), ...
                numel(txt) > 1e6);
        end
    end

    close(f);
    row = {name, convertResult, fig2plotlyResult, detail};
end

function buildCase(f, name)
    figure(f);
    switch name
        case 'single_notitle'
            plot(1:3);
        case 'single_title'
            plot(1:3); title('Only');
        case 'subplot_notitles'
            subplot(2, 1, 1); plot(1:3);
            subplot(2, 1, 2); plot(3:-1:1);
        case 'subplot_title_first'
            subplot(2, 1, 1); plot(1:3); title('First');
            subplot(2, 1, 2); plot(3:-1:1);
        case 'subplot_title_last'
            subplot(2, 1, 1); plot(1:3);
            subplot(2, 1, 2); plot(3:-1:1); title('Last');
        case 'subplot_titles'
            subplot(2, 1, 1); plot(1:3); title('First');
            subplot(2, 1, 2); plot(3:-1:1); title('Last');
        case 'tiled_notitles'
            tiledlayout(f, 2, 1);
            nexttile; plot(1:3);
            nexttile; plot(3:-1:1);
        case 'tiled_title_first'
            tiledlayout(f, 2, 1);
            nexttile; plot(1:3); title('First');
            nexttile; plot(3:-1:1);
        case 'tiled_title_last'
            tiledlayout(f, 2, 1);
            nexttile; plot(1:3);
            nexttile; plot(3:-1:1); title('Last');
        case 'tiled_titles'
            tiledlayout(f, 2, 1);
            nexttile; plot(1:3); title('First');
            nexttile; plot(3:-1:1); title('Last');
        case 'tiled_layouttitle_only'
            t = tiledlayout(f, 2, 1);
            title(t, 'Layout');
            nexttile; plot(1:3);
            nexttile; plot(3:-1:1);
        otherwise
            error('unknown case %s', name);
    end
end

function section(name)
    fprintf('\n==================== %s ====================\n', name);
end

function show(label, v)
    fprintf('%s: %s\n', label, describe(v));
end

function out = describe(v)
    if isstring(v)
        if isempty(v)
            vals = '';
        else
            vals = strjoin(cellstr(v), '" | "');
        end
        out = sprintf('class=string size=%s value="%s"', mat2str(size(v)), vals);
    elseif ischar(v)
        out = sprintf('class=char size=%s value=''%s''', mat2str(size(v)), v);
    elseif iscell(v)
        parts = cellfun(@describe, v, 'UniformOutput', false);
        out = sprintf('class=cell size=%s {%s}', mat2str(size(v)), strjoin(parts, '; '));
    elseif isnumeric(v) || islogical(v)
        out = sprintf('class=%s size=%s value=%s', class(v), mat2str(size(v)), mat2str(v));
    else
        out = sprintf('class=%s size=%s', class(v), mat2str(size(v)));
    end
end

function printErr(err)
    fprintf('  ERROR id=%s\n  message: %s\n', err.identifier, err.message);
    for s = 1:numel(err.stack)
        fprintf('    at %s (%s:%d)\n', err.stack(s).name, err.stack(s).file, err.stack(s).line);
    end
end

function printWarn()
    [msg, id] = lastwarn;
    if ~isempty(msg)
        fprintf('  last warning id=%s: %s\n', id, msg);
    end
end

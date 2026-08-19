function runplotlytests(varargin)
    if exist('OCTAVE_VERSION', 'builtin')
        try pkg load datatypes; catch, end
        try pkg load statistics; catch, end
    end
    root = getenv('PLOTLY_ROOT');
    if isempty(root)
        root = fileparts(fileparts(mfilename('fullpath')));
    end
    addpath(genpath(root));

    % every Test_*.m under the root, in any folder, forms both the
    % default suite and the pool a bare test method name resolves against
    suiteFiles = sort(findTestFiles(root));

    % Targets: {className, methodName, rawParams, file} rows; an empty
    % methodName runs every test method of the class.  methodName may
    % carry a positional parameter filter:
    %   'Class/method'           -> all parameterized values
    %   'Class/method(2,"x")'    -> only matching combinations
    %   'Class/method(2,,"x")'   -> empty slot: all annotated values
    % A bare test method name ('testFoo' or 'testFoo(2)') resolves to
    % its class when unambiguous.  Passing parameters to a method with
    % no annotation is an error, as is passing more values than the
    % method takes arguments.  Without arguments the default suites run.
    if nargin == 0
        args = cell(1, numel(suiteFiles));
        for f = 1:numel(suiteFiles)
            [~, cls] = fileparts(suiteFiles{f});
            args{f} = cls;
        end
    else
        args = varargin;
    end
    targets = cell(numel(args), 4);
    for i = 1:numel(args)
        [className, methodName, rawParams, file] = parseTarget(args{i}, suiteFiles);
        targets{i, 1} = className;
        targets{i, 2} = methodName;
        targets{i, 3} = rawParams;
        targets{i, 4} = file;
    end

    % Validate explicit parameter filters before running anything.
    for t = 1:size(targets, 1)
        rawParams = targets{t, 3};
        if isempty(rawParams)
            continue;
        end
        className = targets{t, 1};
        methodName = targets{t, 2};
        file = targets{t, 4};
        try
            tc0 = str2func(className)();
        catch
            continue; % reported as SKIP by the main loop
        end
        if ~ismember(methodName, methods(tc0))
            continue; % reported as SKIP by the main loop
        end
        [~, argCount] = testParams(file, methodName);
        args0 = parseParamList(rawParams);
        if argCount == 0
            error('runplotlytests:paramsOnNoArgMethod', ...
                'Test method %s/%s takes no arguments but parameters (%s) were given.', ...
                className, methodName, rawParams);
        end
        if numel(args0) > argCount
            error('runplotlytests:tooManyParams', ...
                'Test method %s/%s takes %d argument(s) but %d value(s) (%s) were given.', ...
                className, methodName, argCount, numel(args0), rawParams);
        end
    end

    allVerdicts = struct('Name', {}, 'Passed', {}, 'VerificationFailures', {}, ...
        'Diagnostics', {}, 'ErrorTrace', {}, 'Duration', {}, 'Errored', {});

    for t = 1:size(targets, 1)
        className = targets{t, 1};
        onlyMethod = targets{t, 2};
        rawParams = targets{t, 3};
        file = targets{t, 4};

        if isempty(onlyMethod)
            fprintf('Running %s\n', className);
        elseif isempty(rawParams)
            fprintf('Running %s/%s\n', className, onlyMethod);
        else
            fprintf('Running %s/%s(%s)\n', className, onlyMethod, rawParams);
        end

        try
            constructor = str2func(className);
            tc = constructor();
        catch e
            fprintf('  SKIP: could not instantiate %s: %s\n', className, e.message);
            continue;
        end

        classMeths = methods(tc);
        % setUp/tearDown (if defined) run around every test case,
        % including each parameterized case
        hasSetup = ismember('setUp', classMeths);
        hasTearDown = ismember('tearDown', classMeths);
        nTests = 0;
        verdicts = struct('Name', {}, 'Passed', {}, 'VerificationFailures', {}, ...
            'Diagnostics', {}, 'ErrorTrace', {}, 'Duration', {}, 'Errored', {});

        if ~isempty(onlyMethod)
            meths = classMeths(strcmp(classMeths, onlyMethod));
        else
            meths = classMeths;
        end

        for i = 1:numel(meths)
            methodName = meths{i};
            if length(methodName) < 5 || ~strncmp(methodName, 'test', 4)
                continue;
            end
            nTests = nTests + 1;

            combos = testParams(file, methodName);
            if ~isempty(rawParams)
                args0 = parseParamList(rawParams);
                combos = filterCombos(combos, args0);
                if isempty(combos)
                    fprintf('\n');
                    printBanner();
                    fprintf('No parameterization of %s/%s matches (%s).\n', ...
                        className, methodName, rawParams);
                    printBanner();
                    fprintf('\n');
                    verdicts(end+1) = struct('Name', ...
                        sprintf('%s/%s(%s)', className, methodName, rawParams), ...
                        'Passed', false, 'VerificationFailures', 1, ...
                        'Diagnostics', {sprintf( ...
                            'No parameterization of %s matches (%s).', methodName, rawParams)}, ...
                        'ErrorTrace', '', 'Duration', 0, 'Errored', true);
                    continue;
                end
            end
            if isempty(combos)
                combos = {{}};
            end

            for ci = 1:numel(combos)
                combo = combos{ci};
                if isempty(combo)
                    caseName = [className '/' methodName];
                else
                    labels = cellfun(@valueLabel, combo, 'UniformOutput', false);
                    caseName = sprintf('%s/%s(%s)', className, methodName, ...
                        strjoin(labels, ', '));
                end

                tic;
                tc.startTest(caseName);
                fname = str2func(methodName);
                threw = false;
                trace = '';
                % sequential try/catch blocks (Octave has no finally):
                % setUp, then the test, then tearDown regardless of what
                % threw
                setUpOk = true;
                if hasSetup
                    try
                        tc.setUp();
                    catch e
                        threw = true;
                        trace = errorTrace(e);
                        setUpOk = false;
                    end
                end
                if setUpOk
                    try
                        fname(tc, combo{:});
                    catch e
                        threw = true;
                        trace = errorTrace(e);
                    end
                end
                if hasTearDown
                    try
                        tc.tearDown();
                    catch e
                        threw = true;
                        if isempty(trace)
                            trace = errorTrace(e);
                        else
                            trace = [trace sprintf('\n\n') errorTrace(e)];
                        end
                    end
                end
                tc.ErrorTrace = trace;
                dt = toc;
                v = tc.finishTest();
                v.Duration = dt;
                v.Errored = threw;
                verdicts(end+1) = v;

                if threw
                    fprintf('\n');
                    printBanner();
                    fprintf('Error occurred in %s and it did not run to completion.\n', v.Name);
                    diag = v.ErrorTrace;
                    nl = strfind(diag, char(10));
                    if ~isempty(nl)
                        id = diag(1:nl(1)-1);
                        rest = diag(nl(1)+1:end);
                    else
                        id = '';
                        rest = diag;
                    end
                    fprintf('    ---------\n    Error ID:\n    ---------\n');
                    fprintf('    %s\n', id);
                    fprintf('    --------------\n    Error Details:\n    --------------\n');
                    fprintf('    %s\n', rest);
                    printBanner();
                    fprintf('\n');
                elseif ~v.Passed
                    fprintf('\n');
                    for d = 1:numel(v.Diagnostics)
                        printBanner();
                        fprintf('Verification failed in %s.\n', v.Name);
                        fprintf('    ----------------\n    Test Diagnostic:\n    ----------------\n');
                        fprintf('    %s\n', v.Diagnostics{d});
                        printBanner();
                        fprintf('\n');
                    end
                else
                    fprintf('.');
                end
            end
        end

        % A requested method that does not exist counts as an error
        if ~isempty(onlyMethod) && nTests == 0
            fprintf('\n  SKIP: no test method ''%s'' in %s\n', onlyMethod, className);
            verdicts(end+1) = struct('Name', sprintf('%s/%s', className, onlyMethod), ...
                'Passed', false, 'VerificationFailures', 1, ...
                'Diagnostics', {sprintf('No test method ''%s'' in %s', onlyMethod, className)}, ...
                'ErrorTrace', '', 'Duration', 0, 'Errored', true);
        end

        fprintf('\nDone %s\n', className);
        fprintf('__________\n\n');

        allVerdicts = [allVerdicts, verdicts];
    end

    % Failure summary, skipped when every test passed
    nErrored = 0; nFailed = 0; nPassed = 0;
    maxName = 0;
    for i = 1:numel(allVerdicts)
        v = allVerdicts(i);
        if v.Errored
            nErrored = nErrored + 1;
        elseif ~v.Passed
            nFailed = nFailed + 1;
        else
            nPassed = nPassed + 1;
        end
        if ~v.Passed || v.Errored
            maxName = max(maxName, length(v.Name));
        end
    end

    if nFailed > 0 || nErrored > 0
        fprintf('Failure Summary:\n\n');
        % the name field grows with the longest failing case name (capped
        % at 80 so parameterized names like Class/method('value1', 2) stay
        % readable); shorter suites keep the table compact
        nameWidth = min(max(maxName, 20), 80);
        headerLine = sprintf('     %-*s   %-7s %s\n', nameWidth, 'Name', 'Failed', 'Errored');
        fprintf('%s', headerLine);
        fprintf('     %s\n', repmat('=', 1, numel(headerLine) - 6));
        for i = 1:numel(allVerdicts)
            v = allVerdicts(i);
            if ~v.Passed || v.Errored
                nm = v.Name;
                if length(nm) > nameWidth, nm = [nm(1:nameWidth-3) '...']; end
                fprintf('     %-*s   %-7s %s\n', nameWidth, nm, ...
                    iff(~v.Passed && ~v.Errored, 'X', ''), ...
                    iff(v.Errored, 'X', ''));
            end
        end
    end

    fprintf('\nTotals:\n');
    fprintf('   %d Passed, %d Failed, %d Errored.\n', nPassed, nFailed, nErrored);
    if ~isempty(allVerdicts)
        total = sum([allVerdicts.Duration]);
        fprintf('   %.4f seconds testing time.\n', total);
    end

    if ~isempty(getenv('CI')) && (nFailed > 0 || nErrored > 0)
        exit(1);
    end
end

function [className, methodName, rawParams, file] = parseTarget(arg, suiteFiles)
    % Accept 'Class', 'Class.m', 'Class/method', 'Class.method',
    % 'Class/method(v1,v2,...)' parameter filters and a bare test
    % method name ('testFoo' or 'testFoo(v1)'), resolved to its class
    % when unambiguous.
    methodName = '';
    rawParams = '';
    file = '';
    if ~ischar(arg)
        arg = char(arg);
    end
    arg = strtrim(arg);

    if ~isempty(strfind(arg, '/'))
        % Path to a test file
        if exist(arg, 'file')
            file = arg;
        end
    elseif isempty(strfind(arg, '.'))
        % Bare class name on the path
        file = which(arg);
    elseif numel(arg) >= 2 && strcmp(arg(numel(arg)-1:numel(arg)), '.m')
        % Class file name on the path (Octave's which resolves any
        % dotted name to the class file, so only try '.m' suffixes)
        file = which(arg);
    end

    if isempty(file) && ~isempty(arg)
        % Split at the first '/' or '.': Class/method or Class.method
        slash = strfind(arg, '/');
        dot = strfind(arg, '.');
        sep = min([slash, dot]);
        if ~isempty(sep)
            cls = arg(1:sep-1);
            methodName = arg(sep+1:end);
            if isempty(methodName)
                error('runplotlytests:badTarget', ...
                    'No test method given in ''%s''', arg);
            end
            if ~isempty(strfind(methodName, '('))
                [methodName, rawParams] = stripParams(methodName, arg);
            end
            file = which(cls);
            if isempty(file) && exist(cls, 'file')
                file = cls;
            end
        else
            % no class prefix: a bare test method name resolves to the
            % class that defines it when unambiguous
            name = arg;
            rawParams = '';
            if ~isempty(strfind(arg, '('))
                [name, rawParams] = stripParams(arg, arg);
            end
            if ~isempty(regexp(name, '^test\w+$', 'once'))
                file = findTestMethodFile(suiteFiles, name);
                if ~isempty(file)
                    methodName = name;
                end
            end
            if isempty(file) && ~isempty(strfind(arg, '('))
                error('runplotlytests:paramsNeedMethod', ...
                    ['Parameters in ''%s'' require a test method target like ' ...
                    'Class/method(v1,v2).'], arg);
            end
        end
    end

    if isempty(file)
        error('runplotlytests:noTarget', ...
            'No test class or file ''%s'' found', arg);
    end

    [~, className] = fileparts(file);
end

function files = findTestFiles(folder)
    files = {};
    d = dir(folder);
    for i = 1:numel(d)
        if isempty(d(i).name) || d(i).name(1) == '.'
            continue; % . and .. and hidden folders
        end
        if d(i).isdir
            files = [files, findTestFiles(fullfile(folder, d(i).name))]; %#ok<AGROW>
        elseif ~isempty(regexp(d(i).name, '^Test_.*\.m$', 'once'))
            files{end+1} = fullfile(folder, d(i).name); %#ok<AGROW>
        end
    end
end

function file = findTestMethodFile(suiteFiles, name)
    % locate the class file that defines the test method name; error on
    % ambiguity
    found = cell(1, numel(suiteFiles));
    n = 0;
    for i = 1:numel(suiteFiles)
        if fileDefinesMethod(suiteFiles{i}, name)
            n = n + 1;
            found{n} = suiteFiles{i};
        end
    end
    found = found(1:n);
    if numel(found) > 1
        classes = cell(1, numel(found));
        for i = 1:numel(found)
            [~, classes{i}] = fileparts(found{i});
        end
        error('runplotlytests:ambiguousMethod', ...
            'Test method ''%s'' is defined in %s; use Class/method to disambiguate.', ...
            name, strjoin(classes, ', '));
    end
    file = '';
    if ~isempty(found)
        file = found{1};
    end
end

function ok = fileDefinesMethod(file, name)
    fid = fopen(file, 'r');
    if fid < 0
        ok = false;
        return;
    end
    text = fread(fid, Inf, '*char')';
    fclose(fid);
    pat = ['^\s*function\s+' regexptranslate('escape', name) '\s*\('];
    ok = ~isempty(regexp(text, pat, 'once', 'lineanchors'));
end

function [name, raw] = stripParams(name, fullArg)
    % strip a trailing '(v1,v2,...)' from the method name
    raw = '';
    open = strfind(name, '(');
    if isempty(open)
        return;
    end
    if name(end) ~= ')'
        error('runplotlytests:badParams', ...
            'Unbalanced ''('' in ''%s''', fullArg);
    end
    raw = name(open(1)+1:end-1);
    name = name(1:open(1)-1);
end

function args = parseParamList(raw)
    % args: 1xn struct array with fields value (eval'd) and wildcard
    % (true for empty slots)
    args = struct('value', {}, 'wildcard', {});
    tokens = splitOnCommas(raw);
    for i = 1:numel(tokens)
        tok = strtrim(tokens{i});
        if isempty(tok)
            args(end+1) = struct('value', [], 'wildcard', true); %#ok<AGROW>
        else
            try
                v = eval(tok);
            catch e
                error('runplotlytests:badParamValue', ...
                    'Cannot evaluate parameter value ''%s'': %s', tok, e.message);
            end
            args(end+1) = struct('value', v, 'wildcard', false); %#ok<AGROW>
        end
    end
end

function tokens = splitOnCommas(raw)
    % comma split that ignores commas inside single- or double-quoted
    % literals (doubled quotes escape a quote inside the literal)
    tokens = {};
    start = 1;
    q = 0; % current quote character: 0 outside a literal, else ' or "
    i = 1;
    while i <= numel(raw)
        c = raw(i);
        if q == 0
            if c == '''' || c == '"'
                q = c;
            elseif c == ','
                tokens{end+1} = raw(start:i-1); %#ok<AGROW>
                start = i + 1;
            end
        else
            if c == q
                if i + 1 <= numel(raw) && raw(i+1) == q
                    i = i + 1; % doubled quote inside the literal
                else
                    q = 0;
                end
            end
        end
        i = i + 1;
    end
    tokens{end+1} = raw(start:end);
end

function combos = filterCombos(combos, args)
    % keep only the combinations whose leading values match the filter;
    % wildcard slots match every annotated value
    if isempty(args)
        return;
    end
    keep = false(1, numel(combos));
    for c = 1:numel(combos)
        combo = combos{c};
        ok = true;
        for j = 1:numel(args)
            if args(j).wildcard
                continue;
            end
            if j > numel(combo) || ~paramEqual(combo{j}, args(j).value)
                ok = false;
                break;
            end
        end
        keep(c) = ok;
    end
    combos = combos(keep);
end

function ok = paramEqual(a, b)
    % char and string compare as equal across engines and quote styles
    if (ischar(a) || isstring(a)) && (ischar(b) || isstring(b))
        ok = strcmp(char(a), char(b));
    else
        ok = isequal(a, b);
    end
end

function s = valueLabel(v)
    % compact display form of one parameter value for verdict names
    if ischar(v)
        s = sprintf('''%s''', v);
    elseif isstring(v) && isscalar(v)
        s = sprintf('"%s"', char(v));
    elseif isnumeric(v) && isscalar(v)
        s = strtrim(sprintf('%.17g', v));
    elseif islogical(v) && isscalar(v)
        if v, s = 'true'; else, s = 'false'; end
    else
        s = sprintf('%s', class(v));
    end
end

function trace = errorTrace(e)
    trace = sprintf('''%s''\n%s', e.identifier, e.message);
    for si = 1:numel(e.stack)
        trace = sprintf('%s\n\nError in %s (line %d)', ...
            trace, e.stack(si).name, e.stack(si).line);
    end
end

function r = iff(cond, tval, fval)
    if cond, r = tval; else r = fval; end
end

function printBanner()
    fprintf('================================================================================\n');
end

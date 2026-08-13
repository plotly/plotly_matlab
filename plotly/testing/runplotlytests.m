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

    %-targets: {className, methodName} rows; an empty methodName runs
    %-every test method of the class.  Without arguments the default
    %-suites run-%
    if nargin == 0
        args = {'Test_m2json', 'Test_plotlyfig', 'Test_plotlyfig_perf'};
    else
        args = varargin;
    end
    targets = cell(numel(args), 2);
    for i = 1:numel(args)
        [className, methodName] = parseTarget(args{i});
        targets{i, 1} = className;
        targets{i, 2} = methodName;
    end

    allVerdicts = struct('Name', {}, 'Passed', {}, 'VerificationFailures', {}, ...
        'Diagnostics', {}, 'ErrorTrace', {}, 'Duration', {}, 'Errored', {});

    for t = 1:size(targets, 1)
        className = targets{t, 1};
        onlyMethod = targets{t, 2};

        if isempty(onlyMethod)
            fprintf('Running %s\n', className);
        else
            fprintf('Running %s/%s\n', className, onlyMethod);
        end

        try
            constructor = str2func(className);
            tc = constructor();
        catch e
            fprintf('  SKIP: could not instantiate %s: %s\n', className, e.message);
            continue;
        end

        meths = methods(tc);
        nTests = 0;
        verdicts = struct('Name', {}, 'Passed', {}, 'VerificationFailures', {}, ...
            'Diagnostics', {}, 'ErrorTrace', {}, 'Duration', {}, 'Errored', {});

        if ~isempty(onlyMethod)
            meths = meths(strcmp(meths, onlyMethod))
        end

        for i = 1:numel(meths)
            methodName = meths{i};
            if length(methodName) < 5 || ~strncmp(methodName, 'test', 4)
                continue;
            end
            nTests = nTests + 1;

            tic;
            tc.startTest([className '/' methodName]);
            fname = str2func(methodName);
            threw = false;
            try
                fname(tc);
            catch e
                threw = true;
                trace = sprintf('''%s''\n%s', e.identifier, e.message);
                for si = 1:numel(e.stack)
                    trace = sprintf('%s\n\nError in %s (line %d)', ...
                        trace, e.stack(si).name, e.stack(si).line);
                end
                tc.ErrorTrace = trace;
            end
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

        %-a requested method that does not exist counts as an error-%
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

    % Failure summary
    fprintf('Failure Summary:\n\n');
    nErrored = 0; nFailed = 0; nPassed = 0;
    for i = 1:numel(allVerdicts)
        v = allVerdicts(i);
        if v.Errored
            nErrored = nErrored + 1;
        elseif ~v.Passed
            nFailed = nFailed + 1;
        else
            nPassed = nPassed + 1;
        end
    end

    fprintf('     Name                                                 Failed  Errored\n');
    fprintf('    =====================================================================\n');
    for i = 1:numel(allVerdicts)
        v = allVerdicts(i);
        if ~v.Passed || v.Errored
            nm = v.Name;
            if length(nm) > 50, nm = [nm(1:47) '...']; end
            fprintf('     %-55s %-7s %s\n', nm, ...
                iff(~v.Passed && ~v.Errored, 'X', ''), ...
                iff(v.Errored, 'X', ''));
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

function [className, methodName] = parseTarget(arg)
    % Accept 'Class', 'Class.m', 'Class/method' and 'Class.method'
    methodName = '';
    if ~ischar(arg)
        arg = char(arg);
    end
    arg = strtrim(arg);

    file = '';
    if ~isempty(strfind(arg, '/'))
        % path to a test file
        if exist(arg, 'file')
            file = arg;
        end
    elseif isempty(strfind(arg, '.'))
        % bare class name on the path
        file = which(arg);
    elseif numel(arg) >= 2 && strcmp(arg(numel(arg)-1:numel(arg)), '.m')
        % class file name on the path (Octave's which resolves any
        % dotted name to the class file, so only try '.m' suffixes)
        file = which(arg);
    end

    if isempty(file) && ~isempty(arg)
        % split at the first '/' or '.': Class/method or Class.method
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
            file = which(cls);
            if isempty(file) && exist(cls, 'file')
                file = cls;
            end
        end
    end

    if isempty(file)
        error('runplotlytests:noTarget', ...
            'No test class or file ''%s'' found', arg);
    end

    [~, className] = fileparts(file);
end

function r = iff(cond, tval, fval)
    if cond, r = tval; else r = fval; end
end

function printBanner()
    fprintf('================================================================================\n');
end

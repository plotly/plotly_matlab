function runplotlytests()
    clear classes;
    if exist('OCTAVE_VERSION', 'builtin')
        try pkg load datatypes; catch, end
        try pkg load statistics; catch, end
    end
    addpath(genpath('/workspace/plotly'));

    suites = {
        'Test_m2json',       '/workspace/plotly/plotly_aux/Test_m2json.m'
        'Test_plotlyfig',    '/workspace/plotly/Test_plotlyfig.m'
        'Test_plotlyfig_perf','/workspace/plotly/Test_plotlyfig_perf.m'
    };

    allVerdicts = struct([]);

    for s = 1:size(suites, 1)
        className = suites{s, 1};
        fprintf('Running %s\n', className);

        try
            constructor = str2func(className);
            tc = constructor();
        catch e
            fprintf('  SKIP: could not instantiate %s: %s\n', className, e.message);
            continue;
        end

        meths = methods(tc);
        nTests = 0;
        verdicts = struct([]);

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
                tc.recordFail(sprintf('THREW: %s', e.message));
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
                fprintf('    ---------\n    Error Details:\n    --------------\n');
                fprintf('    %s\n', tc.Failures{end});
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
end

function r = iff(cond, tval, fval)
    if cond, r = tval; else r = fval; end
end

function printBanner()
    fprintf('================================================================================\n');
end

function runplotlytests()
    addpath(genpath('/workspace/plotly'));
    addpath('/workspace/plotly/testing');

    suites = {
        'Test_m2json',       '/workspace/plotly/plotly_aux/Test_m2json.m'
        'Test_plotlyfig',    '/workspace/plotly/Test_plotlyfig.m'
        'Test_plotlyfig_perf','/workspace/plotly/Test_plotlyfig_perf.m'
    };

    totalPassed = 0;
    totalFailed = 0;

    for s = 1:size(suites, 1)
        className = suites{s, 1};
        fprintf('\n=== %s ===\n', className);

        try
            constructor = str2func(className);
            tc = constructor();
        catch e
            fprintf('  SKIP: could not instantiate %s: %s\n', className, e.message);
            continue;
        end

        meths = methods(tc);
        nTests = 0;
        for i = 1:numel(meths)
            methodName = meths{i};
            if ~startsWith(methodName, 'test')
                continue;
            end
            nTests = nTests + 1;
            fname = str2func(methodName);
            try
                fname(tc);
            catch e
                tc.recordFail(sprintf('%s THREW: %s', methodName, e.message));
            end
        end

        fprintf('  Tests run: %d, Passed: %d, Failed: %d\n', ...
            nTests, tc.Passed, tc.Failed);
        for f = 1:tc.Failed
            fprintf('    FAIL %d: %s\n', f, tc.Failures{f});
        end
        totalPassed = totalPassed + tc.Passed;
        totalFailed = totalFailed + tc.Failed;
    end

    fprintf('\n=== TOTAL: %d passed, %d failed ===\n', totalPassed, totalFailed);
end

function r = startsWith(s, prefix)
    if length(s) < length(prefix)
        r = false;
    else
        r = strncmp(s, prefix, length(prefix));
    end
end

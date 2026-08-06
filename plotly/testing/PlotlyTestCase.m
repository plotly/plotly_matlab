classdef PlotlyTestCase < handle

    properties
        CurrentTest = ''
        Passed = 0
        Failed = 0
        Failures = {}
        TestVerdicts = []
        ErrorTrace = ''
    end

    properties (Access = private)
        p_curPassed = 0
        p_curFailed = 0
        p_curDiagnostics = {}
    end

    methods
        function startTest(testCase, name)
            testCase.CurrentTest = name;
            testCase.p_curPassed = 0;
            testCase.p_curFailed = 0;
            testCase.p_curDiagnostics = {};
            testCase.ErrorTrace = '';
        end

        function v = finishTest(testCase)
            v = struct('Name', testCase.CurrentTest, ...
                       'Passed', testCase.p_curFailed == 0, ...
                       'VerificationFailures', testCase.p_curFailed, ...
                       'Diagnostics', {testCase.p_curDiagnostics}, ...
                       'ErrorTrace', testCase.ErrorTrace, ...
                       'Duration', 0, ...
                       'Errored', false);
            testCase.CurrentTest = '';
            if isempty(testCase.TestVerdicts)
                testCase.TestVerdicts = v;
            else
                testCase.TestVerdicts(end+1) = v;
            end
        end

        function recordPass(testCase)
            testCase.Passed = testCase.Passed + 1;
            testCase.p_curPassed = testCase.p_curPassed + 1;
        end

        function recordFail(testCase, diagnostic)
            testCase.Failed = testCase.Failed + 1;
            testCase.p_curFailed = testCase.p_curFailed + 1;
            testCase.p_curDiagnostics{end+1} = diagnostic;
            if isempty(testCase.CurrentTest)
                testCase.Failures{end+1} = diagnostic;
            else
                testCase.Failures{end+1} = [testCase.CurrentTest ': ' diagnostic];
            end
        end

        function verifyEqual(testCase, actual, expected, varargin)
            [absTol, msg] = testCase.parseVerifyArgs(varargin{:});
            if isstruct(actual) && isstruct(expected)
                testCase.compareHelper(actual, expected, '', varargin);
                return;
            end
            ok = testCase.isEqualCheck(actual, expected, absTol);
            if ok
                testCase.recordPass();
            else
                detail = sprintf('  Actual  : %s\n  Expected: %s', ...
                    testCase.formatValue(actual), testCase.formatValue(expected));
                if absTol > 0 && isnumeric(actual) && isnumeric(expected)
                    detail = [detail sprintf('\n  AbsTol  : %s', strtrim(sprintf('%.17g', absTol)))];
                end
                if isnumeric(actual) && isnumeric(expected) && isscalar(actual) && isscalar(expected)
                    detail = [detail sprintf('\n  |a-e|   : %s', strtrim(sprintf('%.17g', abs(double(actual) - double(expected)))))];
                end
                if isempty(msg)
                    testCase.recordFail(sprintf('Values are not equal.\n%s', detail));
                else
                    testCase.recordFail(sprintf('%s\n%s', msg, detail));
                end
            end
        end

        function verifyEqualStructs(testCase, actual, expected, varargin)
            testCase.compareHelper(actual, expected, '<Value>', varargin);
        end

        function verifyNumElements(testCase, value, expectedCount)
            actual = numel(value);
            if actual == expectedCount
                testCase.recordPass();
            else
                testCase.recordFail(sprintf( ...
                    'Expected %d elements but found %d.', expectedCount, actual));
            end
        end

        function verifyTrue(testCase, condition, diagnostic)
            if nargin < 3, diagnostic = ''; end
            diag = diagnostic;
            if condition
                testCase.recordPass();
            else
                if isempty(diag)
                    diag = 'Condition was false.';
                end
                testCase.recordFail(diag);
            end
        end

        function verifyFalse(testCase, condition, diagnostic)
            if nargin < 3, diagnostic = ''; end
            testCase.verifyTrue(~condition, diagnostic);
        end

        function verifyNotEmpty(testCase, value)
            if ~isempty(value)
                testCase.recordPass();
            else
                testCase.recordFail('Expected non-empty value but got empty.');
            end
        end

        function verifyGreaterThan(testCase, value, floor, varargin)
            if value > floor
                testCase.recordPass();
            else
                if numel(varargin) >= 1 && ischar(varargin{1})
                    msg = varargin{1};
                    testCase.recordFail(msg);
                else
                    testCase.recordFail(sprintf( ...
                        'Expected value > %s but got %s.', testCase.formatValue(floor), testCase.formatValue(value)));
                end
            end
        end

        function verifyGreaterThanOrEqual(testCase, value, floor, varargin)
            if value >= floor
                testCase.recordPass();
            else
                if numel(varargin) >= 1 && ischar(varargin{1})
                    msg = varargin{1};
                    testCase.recordFail(msg);
                else
                    testCase.recordFail(sprintf( ...
                        'Expected value >= %s but got %s.', testCase.formatValue(floor), testCase.formatValue(value)));
                end
            end
        end

        function verifyLessThan(testCase, value, ceiling, varargin)
            if value < ceiling
                testCase.recordPass();
            else
                if numel(varargin) >= 1 && ischar(varargin{1})
                    msg = varargin{1};
                    testCase.recordFail(msg);
                else
                    testCase.recordFail(sprintf( ...
                        'Expected value < %s but got %s.', testCase.formatValue(ceiling), testCase.formatValue(value)));
                end
            end
        end
    end

    methods (Access = private)
        function compareHelper(testCase, actual, expected, path, extraArgs)
            if isa(expected, 'PlotlyTestCaseAny')
                matchResult = expected.match(actual);
                if ~matchResult.passed
                    diagnostic = sprintf('Path to failure: %s\n%s', path, matchResult.diagnostic);
                    testCase.verifyTrue(false, diagnostic);
                end
                return;
            end
            if isa(actual, 'PlotlyTestCaseAny')
                matchResult = actual.match(expected);
                if ~matchResult.passed
                    diagnostic = sprintf('Path to failure: %s\n%s', path, matchResult.diagnostic);
                    testCase.verifyTrue(false, diagnostic);
                end
                return;
            end

            bothStructs = isstruct(actual) && isstruct(expected);
            onlyOneStruct = isstruct(actual) ~= isstruct(expected);
            bothCells = iscell(actual) && iscell(expected);
            onlyOneCell = iscell(actual) ~= iscell(expected);

            if onlyOneStruct
                diagnostic = sprintf('Path to failure: %s\nType mismatch (one is struct, one is not).', path);
                testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                return;
            end
            if onlyOneCell
                diagnostic = sprintf('Path to failure: %s\nType mismatch (one is cell array, one is not).', path);
                testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                return;
            end

            if bothStructs
                actualFields = fieldnames(actual);
                expectedFields = fieldnames(expected);
                if ~isequal(sort(actualFields), sort(expectedFields))
                    diagnostic = sprintf('Path to failure: %s\nField names do not match.', path);
                    testCase.verifyEqual(sort(actualFields), sort(expectedFields), diagnostic, extraArgs{:});
                    return;
                end
                for i = 1:length(expectedFields)
                    fieldName = expectedFields{i};
                    newPath = sprintf('%s.%s', path, fieldName);
                    testCase.compareHelper(actual.(fieldName), expected.(fieldName), newPath, extraArgs);
                end
            elseif bothCells
                if ~isequal(size(actual), size(expected))
                    diagnostic = sprintf('Path to failure: %s\nCell array sizes do not match.', path);
                    testCase.verifyEqual(size(actual), size(expected), diagnostic, extraArgs{:});
                    return;
                end
                for i = 1:numel(expected)
                    newPath = sprintf('%s{%d}', path, i);
                    testCase.compareHelper(actual{i}, expected{i}, newPath, extraArgs);
                end
            else
                if ~isequal(actual, expected)
                    diagnostic = sprintf('Path to failure: %s', path);
                    testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                end
            end
        end
    end

    methods (Static)
        function obj = Any()
            obj = PlotlyTestCaseAny();
        end
        function obj = AnyColorString()
            obj = PlotlyTestCaseAnyColorString();
        end
        function obj = AnyInteger(positiveOnly)
            if nargin < 1, positiveOnly = false; end
            obj = PlotlyTestCaseAnyInteger(positiveOnly);
        end
        function obj = AnyNumber(positiveOnly)
            if nargin < 1, positiveOnly = false; end
            obj = PlotlyTestCaseAnyNumber(positiveOnly);
        end

        function [absTol, msg] = parseVerifyArgs(varargin)
            absTol = 0;
            msg = '';
            i = 1;
            while i <= numel(varargin)
                arg = varargin{i};
                if ischar(arg)
                    if i + 1 <= numel(varargin) && strcmp(arg, 'AbsTol')
                        absTol = varargin{i+1};
                        i = i + 2;
                        continue;
                    elseif i + 1 <= numel(varargin) && strcmp(arg, 'RelTol')
                        i = i + 2;
                        continue;
                    end
                    msg = arg;
                end
                i = i + 1;
            end
        end

        function ok = isEqualCheck(a, b, tol)
            if isequal(a, b)
                ok = true; return;
            end
            if isequaln(a, b)
                ok = true; return;
            end
            if isnumeric(a) && isnumeric(b) && isequal(size(a), size(b)) && ~isempty(a)
                if any(isnan(a) ~= isnan(b))
                    ok = false; return;
                end
                bothNaN = isnan(a) & isnan(b);
                d = abs(double(a) - double(b));
                d(bothNaN) = 0;
                ok = all(d <= tol);
                return;
            end
            ok = false;
        end

        function s = formatCell(v)
            if isempty(v)
                s = sprintf('%dx%d empty cell', size(v, 1), size(v, 2));
            elseif numel(v) <= 20 && all(cellfun(@ischar, v))
                s = '{';
                for i = 1:numel(v)
                    if i > 1, s = [s ', ']; end
                    s = [s '''' v{i} ''''];
                end
                s = [s '}'];
            else
                sz = size(v);
                dims = '';
                for d = 1:(numel(sz) - 1)
                    dims = [dims num2str(sz(d)) 'x'];
                end
                s = [dims num2str(sz(end)) ' cell'];
            end
        end

        function s = formatStruct(v)
            flds = fieldnames(v);
            if isempty(flds)
                s = 'empty struct';
            else
                s = 'struct(';
                for i = 1:numel(flds)
                    if i > 1, s = [s ', ']; end
                    s = [s flds{i}];
                end
                s = [s ')'];
            end
        end

        function s = formatValue(v)
            cls = class(v);
            sz = size(v);
            dimStr = '';
            for d = 1:numel(sz)
                if d > 1, dimStr = [dimStr 'x']; end
                dimStr = [dimStr num2str(sz(d))];
            end
            dimStr = [dimStr ' '];

            if ischar(v)
                if isempty(v)
                    q = char(39);
                    s = sprintf('%s%s %s%s', dimStr, cls, q, q);
                elseif numel(v) < 200
                    s = sprintf('%s%s ''%s''', dimStr, cls, v);
                else
                    s = sprintf('%s%s', dimStr, cls);
                end
            elseif isstring(v)
                if isscalar(v)
                    s = sprintf('%s "%s"', cls, char(v));
                elseif numel(v) <= 10
                    parts = cell(1, numel(v));
                    for j = 1:numel(v)
                        parts{j} = sprintf('"%s"', char(v(j)));
                    end
                    s = sprintf('%s%s [%s]', dimStr, cls, strjoin(parts, ' '));
                else
                    s = sprintf('%s%s', dimStr, cls);
                end
            elseif isnumeric(v)
                if isscalar(v)
                    s = sprintf('%s%s %s', dimStr, cls, strtrim(sprintf('%.17g', v)));
                else
                    nShow = min(10, numel(v));
                    parts = cell(1, nShow);
                    for j = 1:nShow
                        parts{j} = strtrim(sprintf('%.17g', v(j)));
                    end
                    if numel(v) <= 10
                        s = sprintf('%s%s [%s]', dimStr, cls, strjoin(parts, ' '));
                    else
                        s = sprintf('%s%s [%s ...]', dimStr, cls, strjoin(parts, ' '));
                    end
                end
            elseif islogical(v) && isscalar(v)
                if v, s = sprintf('%s%s true', dimStr, cls); else, s = sprintf('%s%s false', dimStr, cls); end
            elseif iscell(v)
                s = PlotlyTestCase.formatCell(v);
            elseif isstruct(v)
                s = PlotlyTestCase.formatStruct(v);
            else
                s = sprintf('%s%s', dimStr, cls);
            end
        end
    end
end

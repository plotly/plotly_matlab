classdef PlotlyTestCase < handle

    properties
        CurrentTest = ''
        Passed = 0
        Failed = 0
        Failures = {}
    end

    methods
        function recordPass(testCase)
            testCase.Passed = testCase.Passed + 1;
        end

        function recordFail(testCase, diagnostic)
            testCase.Failed = testCase.Failed + 1;
            if isempty(testCase.CurrentTest)
                testCase.Failures{end+1} = diagnostic;
            else
                testCase.Failures{end+1} = [testCase.CurrentTest ': ' diagnostic];
            end
        end

        function verifyEqual(testCase, actual, expected, varargin)
            [absTol, msg] = testCase.parseVerifyArgs(varargin{:});
            ok = testCase.isEqualCheck(actual, expected, absTol);
            if ok
                testCase.recordPass();
            else
                if isempty(msg)
                    msg = sprintf('Values are not equal.\n  Actual  : %s\n  Expected: %s', ...
                        testCase.formatValue(actual), testCase.formatValue(expected));
                end
                testCase.recordFail(msg);
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

        function verifyGreaterThan(testCase, value, floor)
            if value > floor
                testCase.recordPass();
            else
                testCase.recordFail(sprintf( ...
                    'Expected value > %s but got %s.', testCase.formatValue(floor), testCase.formatValue(value)));
            end
        end

        function verifyGreaterThanOrEqual(testCase, value, floor)
            if value >= floor
                testCase.recordPass();
            else
                testCase.recordFail(sprintf( ...
                    'Expected value >= %s but got %s.', testCase.formatValue(floor), testCase.formatValue(value)));
            end
        end

        function verifyLessThan(testCase, value, ceiling)
            if value < ceiling
                testCase.recordPass();
            else
                testCase.recordFail(sprintf( ...
                    'Expected value < %s but got %s.', testCase.formatValue(ceiling), testCase.formatValue(value)));
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
            if isnumeric(a) && isnumeric(b) && isscalar(a) && isscalar(b)
                ok = abs(double(a) - double(b)) <= tol;
                return;
            end
            ok = false;
        end

        function s = formatValue(v)
            if ischar(v) && isscalar(v)
                s = ['''' v ''''];
            elseif isnumeric(v) && isscalar(v)
                s = num2str(v, 16);
            elseif islogical(v) && isscalar(v)
                if v, s = 'true'; else, s = 'false'; end
            else
                try
                    s = num2str(v);
                catch
                    s = '<unprintable>';
                end
            end
        end
    end
end

classdef PlotlyTestCase < matlab.unittest.TestCase
    % PlotlyTestCase Test case class with struct comparison utilities
    %
    % This class extends matlab.unittest.TestCase with additional
    % verification methods for comparing structs recursively.
    %
    % Example:
    %   expected = struct('a', 1, 'b', struct('c', 2));
    %   actual = struct('a', 1, 'b', struct('c', 3));
    %   testCase.verifyEqualStructs(actual, expected);
    %
    % To ignore specific fields, use PlotlyTestCase.Any():
    %   expected = struct('a', 1, 'b', struct('c', PlotlyTestCase.Any()));

    methods
        function verifyEqualStructs(testCase, actual, expected, varargin)
            % verifyEqualStructs Recursively compare two structs
            %
            % Syntax:
            %   verifyEqualStructs(testCase, actual, expected)
            %   verifyEqualStructs(testCase, actual, expected, Name, Value, ...)
            %
            % Description:
            %   Recursively compares all fields in actual and expected structs.
            %   Fails the test if any fields differ, with a diagnostic message
            %   showing the path to the mismatched field.
            %
            %   Use PlotlyTestCase.Any() as a wildcard to skip comparison of
            %   specific fields.
            %
            %   Accepts all name-value arguments supported by verifyEqual,
            %   such as 'AbsTol', 'RelTol', etc.
            %
            % Input Arguments:
            %   testCase - Test case object
            %   actual - Actual struct value
            %   expected - Expected struct value
            %   Name-Value pairs - Additional arguments forwarded to verifyEqual
            %
            % Example:
            %   expected.color = PlotlyTestCase.Any();  % Ignore color field
            %   testCase.verifyEqualStructs(actual, expected, 'AbsTol', 1e-15);

            compareHelper(testCase, actual, expected, '<Value>', varargin);
        end
    end

    methods (Access = private)
        function compareHelper(testCase, actual, expected, path, extraArgs)
            % Recursive helper for struct comparison
            % extraArgs is a cell array of additional arguments to forward

            % Handle Any wildcard - if either side is Any, pass
            if isa(expected, 'PlotlyTestCaseAny') || isa(actual, 'PlotlyTestCaseAny')
                return;
            end

            % Check if both are structs
            bothStructs = isstruct(actual) && isstruct(expected);
            onlyOneStruct = isstruct(actual) ~= isstruct(expected);

            % Check if both are cell arrays
            bothCells = iscell(actual) && iscell(expected);
            onlyOneCell = iscell(actual) ~= iscell(expected);

            if onlyOneStruct
                % Type mismatch: one is struct, one is not
                diagnostic = sprintf('Path to failure: %s\nType mismatch (one is struct, one is not).', path);
                testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                return;
            end

            if onlyOneCell
                % Type mismatch: one is cell array, one is not
                diagnostic = sprintf('Path to failure: %s\nType mismatch (one is cell array, one is not).', path);
                testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                return;
            end

            if bothStructs
                % Both are structs - check field names and recurse
                actualFields = fieldnames(actual);
                expectedFields = fieldnames(expected);

                if ~isequal(sort(actualFields), sort(expectedFields))
                    diagnostic = sprintf('Path to failure: %s\nField names do not match.', path);
                    testCase.verifyEqual(sort(actualFields), sort(expectedFields), diagnostic, extraArgs{:});
                    return;
                end

                % Recursively compare each field
                for i = 1:length(expectedFields)
                    fieldName = expectedFields{i};
                    newPath = sprintf('%s.%s', path, fieldName);
                    compareHelper(testCase, actual.(fieldName), expected.(fieldName), newPath, extraArgs);
                end
            elseif bothCells
                % Both are cell arrays - check size and recurse
                if ~isequal(size(actual), size(expected))
                    diagnostic = sprintf('Path to failure: %s\nCell array sizes do not match.', path);
                    testCase.verifyEqual(size(actual), size(expected), diagnostic, extraArgs{:});
                    return;
                end

                % Recursively compare each cell element
                for i = 1:numel(expected)
                    newPath = sprintf('%s{%d}', path, i);
                    compareHelper(testCase, actual{i}, expected{i}, newPath, extraArgs);
                end
            else
                % Neither is a struct or cell array - compare values directly
                if ~isequal(actual, expected)
                    diagnostic = sprintf('Path to failure: %s', path);
                    testCase.verifyEqual(actual, expected, diagnostic, extraArgs{:});
                end
            end
        end
    end

    methods (Static)
        function obj = Any()
            % Any Create a wildcard matcher for struct comparison
            %
            % Syntax:
            %   obj = PlotlyTestCase.Any()
            %
            % Description:
            %   Returns a wildcard object that matches any value during
            %   struct comparison. Use this to ignore specific fields.
            %
            % Example:
            %   expected.color = PlotlyTestCase.Any();  % Ignore color
            %   testCase.verifyEqualStructs(actual, expected);

            obj = PlotlyTestCaseAny();
        end
    end
end

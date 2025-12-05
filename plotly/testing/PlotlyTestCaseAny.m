classdef PlotlyTestCaseAny
    % PlotlyTestCaseAny Base wildcard matcher for struct comparison
    %
    % This class represents a wildcard that matches any value during
    % struct comparison in PlotlyTestCase.verifyEqualStructs.
    %
    % Do not instantiate this class directly. Use PlotlyTestCase.Any() instead.
    %
    % Subclasses can override the match() method to provide custom validation.
    %
    % Example:
    %   expected.color = PlotlyTestCase.Any();  % Ignore color field
    %   testCase.verifyEqualStructs(actual, expected);

    methods
        function result = match(~, ~)
            % match Check if a value matches this matcher
            %
            % Syntax:
            %   result = matcher.match(actualValue)
            %
            % Description:
            %   Base implementation that matches any value.
            %   Subclasses can override to provide custom validation.
            %
            % Output:
            %   result - Struct with fields:
            %     .passed - true if match succeeded, false otherwise
            %     .diagnostic - String describing why match failed (empty if passed)
            %
            % Example:
            %   matcher = PlotlyTestCase.Any();
            %   result = matcher.match('anything');  % result.passed = true

            result = struct('passed', true, 'diagnostic', '');
        end
    end
end

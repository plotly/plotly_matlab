classdef PlotlyTestCaseAnyInteger < PlotlyTestCaseAny
    % PlotlyTestCaseAnyInteger Matcher for integer values
    %
    % This class validates that a value is an integer (whole number).
    % Optionally can enforce positive integers only.
    %
    % Do not instantiate this class directly. Use PlotlyTestCase.AnyInteger() instead.
    %
    % Example:
    %   expected.width = PlotlyTestCase.AnyInteger();
    %   testCase.verifyEqualStructs(actual, expected);

    properties
        PositiveOnly = false  % If true, only accept positive integers
    end

    methods
        function obj = PlotlyTestCaseAnyInteger(positiveOnly)
            % Constructor
            %
            % Syntax:
            %   obj = PlotlyTestCaseAnyInteger()
            %   obj = PlotlyTestCaseAnyInteger(positiveOnly)
            %
            % Input:
            %   positiveOnly - (Optional) If true, only accept positive integers

            if nargin > 0
                obj.PositiveOnly = positiveOnly;
            end
        end

        function result = match(obj, actualValue)
            % match Check if value is a valid integer
            %
            % Validates that actualValue is a numeric integer value.
            % If PositiveOnly is true, also checks that value > 0.

            result = struct('passed', false, 'diagnostic', '');

            % Check if it's numeric
            if ~isnumeric(actualValue)
                result.diagnostic = sprintf('Expected integer, got %s', class(actualValue));
                return;
            end

            % Check if it's scalar
            if ~isscalar(actualValue)
                result.diagnostic = sprintf('Expected scalar integer, got %s array', mat2str(size(actualValue)));
                return;
            end

            % Check if it's a whole number
            if actualValue ~= floor(actualValue)
                result.diagnostic = sprintf('Expected integer, got %g', actualValue);
                return;
            end

            % Check if positive (if required)
            if obj.PositiveOnly && actualValue <= 0
                result.diagnostic = sprintf('Expected positive integer, got %d', actualValue);
                return;
            end

            result.passed = true;
        end
    end
end

classdef PlotlyTestCaseAnyNumber < PlotlyTestCaseAny
    % PlotlyTestCaseAnyNumber Matcher for numeric values
    %
    % This class validates that a value is numeric.
    % Optionally can enforce positive numbers only.
    %
    % Do not instantiate this class directly. Use PlotlyTestCase.AnyNumber() instead.
    %
    % Example:
    %   expected.ticklen = PlotlyTestCase.AnyNumber();
    %   testCase.verifyEqualStructs(actual, expected);

    properties
        PositiveOnly = false  % If true, only accept positive numbers
    end

    methods
        function obj = PlotlyTestCaseAnyNumber(positiveOnly)
            % Constructor
            %
            % Syntax:
            %   obj = PlotlyTestCaseAnyNumber()
            %   obj = PlotlyTestCaseAnyNumber(positiveOnly)
            %
            % Input:
            %   positiveOnly - (Optional) If true, only accept positive numbers

            if nargin > 0
                obj.PositiveOnly = positiveOnly;
            end
        end

        function result = match(obj, actualValue)
            % match Check if value is a valid number
            %
            % Validates that actualValue is a numeric value.
            % If PositiveOnly is true, also checks that value > 0.

            result = struct('passed', false, 'diagnostic', '');

            % Check if it's numeric
            if ~isnumeric(actualValue)
                result.diagnostic = sprintf('Expected number, got %s', class(actualValue));
                return;
            end

            % Check if it's scalar
            if ~isscalar(actualValue)
                result.diagnostic = sprintf('Expected scalar number, got %s array', mat2str(size(actualValue)));
                return;
            end

            % Check if positive (if required)
            if obj.PositiveOnly && actualValue <= 0
                result.diagnostic = sprintf('Expected positive number, got %g', actualValue);
                return;
            end

            result.passed = true;
        end
    end
end

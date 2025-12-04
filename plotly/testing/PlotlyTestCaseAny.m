classdef PlotlyTestCaseAny
    % PlotlyTestCaseAny Wildcard matcher for struct comparison
    %
    % This class represents a wildcard that matches any value during
    % struct comparison in PlotlyTestCase.verifyEqualStructs.
    %
    % Do not instantiate this class directly. Use PlotlyTestCase.Any() instead.
    %
    % Example:
    %   expected.color = PlotlyTestCase.Any();  % Ignore color field
    %   testCase.verifyEqualStructs(actual, expected);

    % No properties or methods needed - existence is enough
end

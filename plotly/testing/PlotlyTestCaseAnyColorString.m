classdef PlotlyTestCaseAnyColorString < PlotlyTestCaseAny
    % PlotlyTestCaseAnyColorString Matcher for RGB/RGBA color strings
    %
    % This class validates that a value is a color string in the format:
    %   - "rgb(r,g,b)" where r,g,b are integers from 0 to 255
    %   - "rgba(r,g,b,a)" where r,g,b are 0-255 and a is a float from 0 to 1
    %
    % Do not instantiate this class directly. Use PlotlyTestCase.AnyColorString() instead.
    %
    % Example:
    %   expected.color = PlotlyTestCase.AnyColorString();
    %   testCase.verifyEqualStructs(actual, expected);

    methods
        function result = match(~, actualValue)
            % match Check if value is a valid RGB/RGBA color string
            %
            % Validates format: "rgb(r,g,b)" or "rgba(r,g,b,a)"
            % where r,g,b are integers 0-255 and a is float 0-1

            result = struct('passed', false, 'diagnostic', '');

            % Check if it's a string
            if ~(ischar(actualValue) || isstring(actualValue))
                result.diagnostic = sprintf('Expected color string, got %s', class(actualValue));
                return;
            end

            actualValue = char(actualValue);

            % Try to match rgb(r,g,b) pattern
            rgbPattern = '^rgb\((\d+),(\d+),(\d+)\)$';
            tokens = regexp(actualValue, rgbPattern, 'tokens');

            if ~isempty(tokens)
                r = str2double(tokens{1}{1});
                g = str2double(tokens{1}{2});
                b = str2double(tokens{1}{3});

                if r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255
                    result.passed = true;
                    return;
                else
                    result.diagnostic = sprintf('RGB values must be 0-255, got rgb(%d,%d,%d)', r, g, b);
                    return;
                end
            end

            % Try to match rgba(r,g,b,a) pattern
            rgbaPattern = '^rgba\((\d+),(\d+),(\d+),([\d.]+)\)$';
            tokens = regexp(actualValue, rgbaPattern, 'tokens');

            if ~isempty(tokens)
                r = str2double(tokens{1}{1});
                g = str2double(tokens{1}{2});
                b = str2double(tokens{1}{3});
                a = str2double(tokens{1}{4});

                if r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255
                    if a >= 0 && a <= 1
                        result.passed = true;
                        return;
                    else
                        result.diagnostic = sprintf('Alpha value must be 0-1, got rgba(%d,%d,%d,%f)', r, g, b, a);
                        return;
                    end
                else
                    result.diagnostic = sprintf('RGB values must be 0-255, got rgba(%d,%d,%d,%f)', r, g, b, a);
                    return;
                end
            end

            % Didn't match either pattern
            result.diagnostic = sprintf('Invalid color format: "%s". Expected "rgb(r,g,b)" or "rgba(r,g,b,a)"', actualValue);
        end
    end
end

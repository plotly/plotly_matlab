classdef Test_plotlyfig_perf < PlotlyPerfTestCase
% Run as:
%{
res = runperf("Test_plotlyfig_perf");
tb = res.sampleSummary;
%}
    methods
        function testManySubplotsConversionTime(tc)
            % Stress test: many subplots with multiple lines each.
            nAxes = 10;
            nLinesPerAxis = 10;

            fig = figure("Visible", "off");
            for a = 1:nAxes
                subplot(4, 5, a);
                for ln = 1:nLinesPerAxis
                    plot(1:50, rand(1, 50));
                    hold on;
                end
                hold off;
            end

            p = plotlyfig(fig, "visible", "off");
            try
                while tc.keepMeasuring
                    p = plotlyfig(fig, "visible", "off");
                end
            catch
            end

            % Verify correctness: one trace per line
            tc.verifyNumElements(p.data, nAxes * nLinesPerAxis);

            % Verify all traces are scatter type
            for k = 1:numel(p.data)
                tc.verifyEqual(p.data{k}.type, "scatter", ...
                    sprintf("Trace %d should be scatter", k));
            end
        end

        function testCheckescapeLongString(tc)
            % Stress test for checkescape with a long string containing
            % many characters that need escaping. The old char-shift
            % implementation was O(n^2); strrep is O(n).
            n = 100000;
            val = repmat('a"b\c/d', 1, n);

            result = checkescape(val);
            try
                while tc.keepMeasuring
                    result = checkescape(val);
                end
            catch
            end

            % Verify correctness
            tc.verifyEqual(length(result), 10 * n);
            tc.verifyTrue(startsWith(result, 'a\"b\\c\/d'));
        end
    end
end

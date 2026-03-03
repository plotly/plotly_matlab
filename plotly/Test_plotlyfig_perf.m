classdef Test_plotlyfig_perf < PlotlyTestCase
    methods (Test)
        function testManySubplotsConversionTime(tc)
            % Stress test: many subplots with multiple lines each.
            nAxes = 20;
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

            tic;
            p = plotlyfig(fig, "visible", "off");
            elapsed = toc;

            fprintf("\n=== Performance: %d axes x %d lines ===\n", ...
                nAxes, nLinesPerAxis);
            fprintf("Total data traces:  %d\n", numel(p.data));
            fprintf("Conversion time:    %.3f seconds\n", elapsed);

            % Verify correctness: one trace per line
            tc.verifyNumElements(p.data, nAxes * nLinesPerAxis);

            % Verify all traces are scatter type
            for k = 1:numel(p.data)
                tc.verifyEqual(p.data{k}.type, "scatter", ...
                    sprintf("Trace %d should be scatter", k));
            end
        end
    end
end

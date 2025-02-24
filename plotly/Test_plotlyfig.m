classdef Test_plotlyfig < matlab.unittest.TestCase
    methods (Test)
        function testLinePlotData(tc)
            fig = figure("Visible","off");
            y = [0.0301 0.4411 0.7007 0.7030 0.5102 0.6122 0.7464 0.8014 0.3367 0.5641];
            x = 1:10;
            plot(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x1', ...
                "yaxis", 'y1', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'lines', ...
                "x", x, ...
                "y", y, ...
                "line", struct( ...
                    "color", "rgb(0,114,189)", ...
                    "width", 0.5, ...
                    "dash", 'solid' ...
                ), ...
                "marker", struct( ...
                    "size", 3.6, ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ), AbsTol=1e-6);
        end

        function testAreaPlotData(tc)
            fig = figure("Visible","off");
            y = [0.6297 0.9559 0.7551 0.5261 0.8501 0.8160 0.1321 0.7607 0.6172 0.3976];
            x = 1:10;
            area(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "scatter", ...
                "x", x, ...
                "y", y, ...
                "name", '', ...
                "visible", true, ...
                "fill", "tozeroy", ...
                "mode", "lines", ...
                "line", struct( ...
                    "color", "rgba(0,0,0,1.000000)", ...
                    "width", 0.5, ...
                    "dash", "solid" ...
                ), ...
                "fillcolor", "rgba(0,114,189,1.000000)", ...
                "showlegend", true ...
            ));
        end

        function testScatterPlotData(tc)
            fig = figure("Visible","off");
            x = linspace(0,3*pi,200);
            y = cos(x) + rand(1,200);
            scatter(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "type", "scatter", ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "mode", "markers", ...
                "visible", true, ...
                "name", '', ...
                "x", x, ...
                "y", y, ...
                "marker", struct( ...
                    "sizeref", 1, ...
                    "sizemode", 'area', ...
                    "size", 36 * ones(size(x)), ...
                    "line", struct( ...
                        "width", 0.7500, ...
                        "color", 'rgb(0.000000,113.985000,188.955000)' ...
                    ), ...
                    "symbol", 'circle', ...
                    "color", "rgba(0,0,0,0)", ...
                    "opacity", 1 ...
                ), ...
                "showlegend", false ...
            ));
        end

        function testHistogramPlotData(tc)
            fig = figure("Visible","off");
            values = [0.6297 0.9559 0.7551 0.5261 0.8501 0.8160 0.1321 0.7607 0.6172 0.3976];
            histogram(values);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "x", [0.15 0.45 0.75 1.05], ...
                "width", [0.3 0.3 0.3 0.3], ...
                "y", [1 2 6 1], ...
                "name", 'values', ...
                "marker", struct( ...
                    "line", struct( ...
                        "width", 0.5, ...
                        "color", "rgba(0,0,0,1.000000)" ...
                    ), ...
                    "color", "rgba(0,114,189,0.600000)" ...
                ), ...
                "opacity", 0.75, ...
                "visible", true, ...
                "showlegend", true ...
            ), AbsTol=1e-6);
        end

        function testVerticalBarPlotData(tc)
            fig = figure("Visible","off");
            x = 1:12;
            y = [38556 24472 14556 18060 19549 8122 28541 7880 3283 4135 7953 1884];
            bar(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "name", '', ...
                "visible", true, ...
                "orientation", "v", ...
                "x", x, ...
                "y", y, ...
                "marker", struct( ...
                    "line", struct( ...
                        "color", "rgba(0,0,0,1.000000)", ...
                        "width", 0.5, ...
                        "dash", "solid" ...
                    ), ...
                    "color", "rgba(0,114,189,1.000000)" ...
                ), ...
                "showlegend", true ...
            ));
        end

        function testHorizontalBarPlotData(tc)
            fig = figure("Visible","off");
            x = 1:12;
            y = [38556 24472 14556 18060 19549 8122 28541 7880 3283 4135 7953 1884];
            barh(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "name", '', ...
                "visible", true, ...
                "orientation", "h", ...
                "x", y, ...
                "y", x, ...
                "marker", struct( ...
                    "line", struct( ...
                        "color", "rgba(0,0,0,1.000000)", ...
                        "width", 0.5, ...
                        "dash", "solid" ...
                    ), ...
                    "color", "rgba(0,114,189,1.000000)" ...
                ), ...
                "showlegend", true ...
            ));
        end

        function testPieChartPlotData(tc)
            fig = figure("Visible","off");
            count = [35 29 28 40 27 30 34 28 36 29 29 30 31 60 90];
            label = 1:15;
            pie(count,label);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 15);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", 'scatter', ...
                "x", [-0.0196 -0.0196 -0.0761 -0.1324 -0.1883 -0.2437 -0.2984 -0.3522 -0.4049 -0.0196 -0.0196], ...
                "y", [0.0981 1.0981 1.0965 1.0917 1.0837 1.0726 1.0584 1.0411 1.0208 0.0981 0.0981], ...
                "name", '', ...
                "visible", true, ...
                "fill", 'tozeroy', ...
                "mode", 'lines', ...
                "marker", struct( ...
                    "sizeref", 1, ...
                    "sizemode", 'diameter', ...
                    "size", 6, ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,0,0)" ...
                ), ...
                "line", struct( ...
                    "color", "rgb(0,0,0)", ...
                    "width", 0.5, ...
                    "dash", 'solid' ...
                ), ...
                "fillcolor", "rgba(62,38,168,1.000000)", ...
                "showlegend", false ...
            ), AbsTol=1e-4);
        end

        function testDoubleYAxisLinePlotData(tc)
            fig = figure("Visible","off");
            x = linspace(0,10);
            y = sin(3*x);
            yyaxis left
            plot(x,y)
            y2 = sin(3*x).*exp(0.5*x);
            yyaxis right
            plot(x,y2)
            ylim([-150 150])

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 4);
            tc.verifyEqual(p.data{1}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x1', ...
                "yaxis", 'y1', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'lines', ...
                "x", x, ...
                "y", y, ...
                "line", struct( ...
                    "color", "rgb(0,114,189)", ...
                    "width", 0.5, ...
                    "dash", 'solid' ...
                ), ...
                "marker", struct( ...
                    "size", 3.6, ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ), AbsTol=1e-6);
            tc.verifyEqual(p.data{2}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x1', ...
                "yaxis", 'y2', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'lines', ...
                "x", x, ...
                "y", y2, ...
                "line", struct( ...
                    "color", "rgb(217,83,25)", ...
                    "width", 0.5, ...
                    "dash", 'solid' ...
                ), ...
                "marker", struct( ...
                    "size", 3.6, ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(217,83,25)" ...
                ), ...
                "showlegend", false ...
            ), AbsTol=1e-6);
        end

        function testDoubleYAxisAreaPlotData(tc)
            fig = figure("Visible","off");
            x = linspace(0,10);
            y = sin(3*x);
            yyaxis left
            area(x,y)
            y2 = sin(3*x).*exp(0.5*x);
            yyaxis right
            area(x,y2)
            ylim([-150 150])

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 4);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "scatter", ...
                "x", x, ...
                "y", y, ...
                "name", '', ...
                "visible", true, ...
                "fill", "tozeroy", ...
                "mode", "lines", ...
                "line", struct( ...
                    "color", "rgba(0,0,0,1.000000)", ...
                    "width", 0.5, ...
                    "dash", "solid" ...
                ), ...
                "fillcolor", "rgba(0,114,189,1.000000)", ...
                "showlegend", true ...
            ));
            tc.verifyEqual(p.data{2}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y2", ...
                "type", "scatter", ...
                "x", x, ...
                "y", y2, ...
                "name", '', ...
                "visible", true, ...
                "fill", "tozeroy", ...
                "mode", "lines", ...
                "line", struct( ...
                    "color", "rgba(0,0,0,1.000000)", ...
                    "width", 0.5, ...
                    "dash", "solid" ...
                ), ...
                "fillcolor", "rgba(217,83,25,1.000000)", ...
                "showlegend", true ...
            ));
        end
    end
end

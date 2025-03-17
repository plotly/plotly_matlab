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
            ), AbsTol=1e-15);
        end

        function testLinePlotLayout(tc)
            fig = figure("Visible","off");
            y = [0.0301 0.4411 0.7007 0.7030 0.5102 0.6122 0.7464 0.8014 0.3367 0.5641];
            x = 1:10;
            plot(x,y);

            p = plotlyfig(fig,"visible","off");

            tc.verifyEqual(p.layout, struct( ...
                "autosize", false, ...
                "margin", struct( ...
                    "pad", 0, ...
                    "l", 0, ...
                    "r", 0, ...
                    "b", 0, ...
                    "t", 0 ...
                ), ...
                "showlegend", false, ...
                "width", 840, ...
                "height", 630, ...
                "paper_bgcolor", "rgb(255,255,255)", ...
                "hovermode", 'closest', ...
                "xaxis1", struct( ...
                    "side", 'bottom', ...
                    "zeroline", false, ...
                    "autorange", false, ...
                    "linecolor", "rgb(38,38,38)", ...
                    "linewidth", 1, ...
                    "exponentformat", 'none', ...
                    "tickfont", struct( ...
                        "size", 10, ...
                        "family", 'Arial, sans-serif', ...
                        "color", "rgb(38,38,38)" ...
                    ), ...
                    "ticklen", 6.51, ...
                    "tickcolor", "rgb(38,38,38)", ...
                    "tickwidth", 1, ...
                    "tickangle", 0, ...
                    "ticks", "inside", ...
                    "showgrid", false, ...
                    "gridcolor", "rgba(38,38,38,0.150000)", ...
                    "type", 'linear', ...
                    "showticklabels", true, ...
                    "tickmode", "array", ...
                    "tickvals", [1 2 3 4 5 6 7 8 9 10], ...
                    "range", [1 10], ...
                    "mirror", "ticks", ...
                    "ticktext", {{'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '10'}}, ...
                    "titlefont", struct( ...
                        "color", "rgb(38,38,38)", ...
                        "family", 'Arial, sans-serif', ...
                        "size", 11 ...
                    ), ...
                    "showline", true, ...
                    "domain", [0.13 0.905], ...
                    "anchor", "y1" ...
                ), ...
                "scene1", struct( ...
                    "domain", struct( ...
                        "x", [0.13 0.905], ...
                        "y", [0.11 0.925] ...
                    ) ...
                ), ...
                "yaxis1", struct( ...
                    "side", 'left', ...
                    "zeroline", false, ...
                    "autorange", false, ...
                    "linecolor", "rgb(38,38,38)", ...
                    "linewidth", 1, ...
                    "exponentformat", 'none', ...
                    "tickfont", struct( ...
                        "size", 10, ...
                        "family", 'Arial, sans-serif', ...
                        "color", "rgb(38,38,38)" ...
                    ), ...
                    "ticklen", 6.51, ...
                    "tickcolor", "rgb(38,38,38)", ...
                    "tickwidth", 1, ...
                    "tickangle", 0, ...
                    "ticks", "inside", ...
                    "showgrid", false, ...
                    "gridcolor", "rgba(38,38,38,0.150000)", ...
                    "type", 'linear', ...
                    "showticklabels", true, ...
                    "tickmode", "array", ...
                    "tickvals", [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9], ...
                    "range", [0 0.9], ...
                    "mirror", "ticks", ...
                    "ticktext", {{'0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'}}, ...
                    "titlefont", struct( ...
                        "color", "rgb(38,38,38)", ...
                        "family", 'Arial, sans-serif', ...
                        "size", 11 ...
                    ), ...
                    "showline", true, ...
                    "domain", [0.11 0.925], ...
                    "anchor", "x1" ...
                ), ...
                "annotations", {{struct( ...
                    "showarrow", false, ...
                    "xref", "paper", ...
                    "yref", "paper", ...
                    "xanchor", 'center', ...
                    "align", 'center', ...
                    "yanchor", "bottom", ...
                    "text", "<b><b></b></b>", ...
                    "x", 0.5175, ...
                    "y", 0.935, ...
                    "font", struct( ...
                        "color", "rgb(0,0,0)", ...
                        "family", 'Arial, sans-serif', ...
                        "size", 11 ...
                    ), ...
                    "bordercolor", "rgba(0,0,0,0)", ...
                    "textangle", 0, ...
                    "borderwidth", 0.5, ...
                    "borderpad", 3 ...
                )}} ...
            ), AbsTol=1e-15);
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
            ), AbsTol=1e-15);
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

        function testPlotmatrixData(tc)
            fig = figure("Visible","off");
            columns = [ ...
                0.67  0.77  0.42;
                0.43  0.70  0.66;
                0.45  0.13  0.72;
                0.61  0.13  0.53;
                0.06  0.09  0.11;
                0.32  0.01  0.63];
            plotmatrix(columns);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 10); % 3x3 matrix of plots + 1 parent plot
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "scatter", ...
                "mode", "none", ...
                "x", [], ...
                "y", [], ...
                "name", "", ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{2}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x2', ...
                "yaxis", 'y2', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,2)', ...
                "y", columns(:,3)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{3}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x3', ...
                "yaxis", 'y3', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,1)', ...
                "y", columns(:,3)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{4}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x4', ...
                "yaxis", 'y4', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,3)', ...
                "y", columns(:,2)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{5}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x5', ...
                "yaxis", 'y5', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,1)', ...
                "y", columns(:,2)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{6}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x6', ...
                "yaxis", 'y6', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,3)', ...
                "y", columns(:,1)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{7}, struct( ...
                "type", 'scatter', ...
                "xaxis", 'x7', ...
                "yaxis", 'y7', ...
                "visible", true, ...
                "name", '', ...
                "mode", 'markers', ...
                "x", columns(:,2)', ...
                "y", columns(:,1)', ...
                "line", struct(), ...
                "marker", struct( ...
                    "size", 3, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 0.5 ...
                    ), ...
                    "color", "rgb(0,114,189)" ...
                ), ...
                "showlegend", false ...
            ));
            tc.verifyEqual(p.data{8}, struct( ...
                "xaxis", "x8", ...
                "yaxis", "y8", ...
                "type", "bar", ...
                "x", [0.25 0.75], ...
                "width", [0.5 0.5], ...
                "y", [2 4], ...
                "name", '', ...
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
            ));
            tc.verifyEqual(p.data{9}, struct( ...
                "xaxis", "x9", ...
                "yaxis", "y9", ...
                "type", "bar", ...
                "x", [0.25 0.75], ...
                "width", [0.5 0.5], ...
                "y", [4 2], ...
                "name", '', ...
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
            ));
            tc.verifyEqual(p.data{10}, struct( ...
                "xaxis", "x10", ...
                "yaxis", "y10", ...
                "type", "bar", ...
                "x", [0.25 0.75], ...
                "width", [0.5 0.5], ...
                "y", [4 2], ...
                "name", '', ...
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
            ));
        end

        function testContourPlotData(tc)
            fig = figure("Visible","off");
            range = 0:0.1:3;
            [xVals,yVals] = meshgrid(range,range);
            zVals = sin(3*xVals).*cos(xVals+yVals);
            contour(xVals,yVals,zVals);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(rmfield(p.data{1}, "colorscale"), struct( ...
                "type", 'contour', ...
                "xaxis", 'x1', ...
                "yaxis", 'y1', ...
                "name", '', ...
                "visible", true, ...
                "xtype", 'array', ...
                "ytype", 'array', ...
                "x", range, ...
                "y", range', ...
                "z", zVals, ...
                "autocontour", false, ...
                "contours", struct( ...
                    "start", -0.8, ...
                    "end", 0.8, ...
                    "size", 0.2, ...
                    "coloring", 'lines', ...
                    "showlines", true ...
                ), ...
                "zauto", false, ...
                "zmin", -0.8, ...
                "zmax", 0.8, ...
                "showscale", false, ...
                "reversescale", false, ...
                "line", struct( ...
                    "width", 0.75, ...
                    "dash", 'solid', ...
                    "color", 'rgba(0,0,0,0)', ...
                    "smoothing", 0 ...
                ), ...
                "showlegend", false ...
            ), AbsTol=1e-16);
        end

        function testStemPlotData(tc)
            fig = figure("Visible","off");
            x = 1:10;
            y = rand(10,1);
            stem(x, y, 'filled');

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "scatter", ...
                "visible", true, ...
                "name", '', ...
                "mode", "lines+markers", ...
                "line", struct( ...
                    "color", "rgb(0,114,189)", ...
                    "width", 1, ...
                    "dash", 'solid' ...
                ), ...
                "marker", struct( ...
                    "size", 3.6, ...
                    "symbol", "circle", ...
                    "line", struct( ...
                        "width", 1, ...
                        "color", {repmat({"rgba(0,0,0,0)" "rgb(0,114,189)" "rgba(0,0,0,0)"},1,10)'} ...
                    ), ...
                    "color", {repmat({"rgba(0,0,0,0)" "rgba(0, 0.4470, 0.7410,1)" "rgba(0,0,0,0)"},1,10)'} ...
                ), ...
                "x", reshape([x; x; nan(1,length(x))], [], 1), ...
                "y", reshape([zeros(1,length(y)); y'; nan(1,length(y))], [], 1), ...
                "showlegend", false ...
            ), AbsTol=1e-15);
        end

        function testStackedBarData(tc)
            fig = figure("Visible","off");
            data = [10 20 30; 15 25 35; 5 15 25];
            bar(1:3, data, 'stack');

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 3); % One for each stack
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "name", '', ...
                "visible", true, ...
                "orientation", "v", ...
                "x", [1 2 3], ...
                "y", [10 15 5], ...
                "marker", struct( ...
                    "color", "rgba(0,114,189,1.000000)", ...
                    "line", struct( ...
                        "color", "rgba(0,0,0,1.000000)", ...
                        "width", 0.5, ...
                        "dash", "solid" ...
                    ) ...
                ), ...
                "showlegend", true ...
            ));
            tc.verifyEqual(p.data{2}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "name", '', ...
                "visible", true, ...
                "orientation", "v", ...
                "x", [1 2 3], ...
                "y", [20 25 15], ...
                "marker", struct( ...
                    "color", "rgba(217,83,25,1.000000)", ...
                    "line", struct( ...
                        "color", "rgba(0,0,0,1.000000)", ...
                        "width", 0.5, ...
                        "dash", "solid" ...
                    ) ...
                ), ...
                "showlegend", true ...
            ));
            tc.verifyEqual(p.data{3}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "bar", ...
                "name", '', ...
                "visible", true, ...
                "orientation", "v", ...
                "x", [1 2 3], ...
                "y", [30 35 25], ...
                "marker", struct( ...
                    "color", "rgba(237,177,32,1.000000)", ...
                    "line", struct( ...
                        "color", "rgba(0,0,0,1.000000)", ...
                        "width", 0.5, ...
                        "dash", "solid" ...
                    ) ...
                ), ...
                "showlegend", true ...
            ));
        end

        function testHeatmapData(tc)
            fig = figure("Visible","off");
            data = magic(5);
            heatmap(data);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(rmfield(p.data{1}, "colorscale"), struct( ...
                "type", 'heatmap', ...
                "x", {num2cell(num2str((1:5)'))}, ...
                "y", {num2cell(num2str(flip(1:5)'))}, ...
                "z", flip(data), ...
                "connectgaps", false, ...
                "hoverongaps", false, ...
                "hoverinfo", 'text', ...
                "text", flip(data), ...
                "hoverlabel", struct( ...
                    "bgcolor", 'white' ...
                ), ...
                "showscale", true, ...
                "colorbar", struct( ...
                    "x", 0.87, ...
                    "y", 0.52, ...
                    "ypad", 55, ...
                    "xpad", 0, ...
                    "outlinecolor", 'rgb(150,150,150)' ...
                ), ...
                "visible", true, ...
                "opacity", 0.9500, ...
                "showlegend", false, ...
                "name", "" ...
            ));
        end

        function testErrorbarData(tc)
            fig = figure("Visible","off");
            x = 1:10;
            y = rand(1,10);
            err = 0.1*ones(1,10);
            errorbar(x,y,err);

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
                "showlegend", false, ...
                "error_y", struct( ...
                    "visible", true, ...
                    "type", 'data', ...
                    "symmetric", false, ...
                    "array", err, ...
                    "arrayminus", err, ...
                    "thickness", 0.5, ...
                    "width", 6, ...
                    "color", 'rgb(0.000000,113.985000,188.955000)' ...
                ), ...
                "error_x", struct( ...
                    "visible", true, ...
                    "type", 'data', ...
                    "array", zeros(1,0), ...
                    "arrayminus", zeros(1,0), ...
                    "thickness", 0.5, ...
                    "width", 6, ...
                    "color", 'rgb(0.000000,113.985000,188.955000)' ...
                ) ...
            ), AbsTol=1e-15);
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
            ), AbsTol=1e-15);
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
            ), AbsTol=1e-15);
        end

        function testVerticalConstantLinePlotData(tc)
            fig = figure("Visible","off");
            xline(1);

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}, struct( ...
                "xaxis", "x1", ...
                "yaxis", "y1", ...
                "type", "scatter", ...
                "visible", true, ...
                "x", [1 1], ...
                "y", [0 1], ...
                "name", '', ...
                "mode", "lines", ...
                "line", struct( ...
                    "color", "rgb(38,38,38)", ...
                    "width", 0.5, ...
                    "dash", 'solid' ...
                ), ...
                "showlegend", true ...
            ), AbsTol=1e-15);
        end

        function testVerticalConstantLineWithLabel(tc)
            fig = figure("Visible","off");
            label = "label";
            alignemnt = "left";
            width = 3;
            xl = xline(1,'r--',label,LineWidth=width);
            xl.LabelHorizontalAlignment = alignemnt;

            p = plotlyfig(fig,"visible","off");

            tc.verifyNumElements(p.data, 1);
            tc.verifyEqual(p.data{1}.line, struct( ...
                "color", "rgb(255,0,0)", ...
                "width", width, ...
                "dash", 'dash' ...
            ));
            tc.verifyTrue(any(cellfun(@(ann) contains(ann.text,label), p.layout.annotations)));
            tc.verifyTrue(any(cellfun(@(ann) ann.xanchor == alignemnt, p.layout.annotations)));
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

        function testTitleFont(tc)
            fig = figure("Visible","off");
            x = 1:10;
            y = x;
            plot(x,y);
            title("Custom Title","FontSize",24,"Color","g","FontName","Arial");

            p = plotlyfig(fig,"visible","off");

            annotation = p.layout.annotations{1};
            tc.verifyEqual(annotation.text, "<b><b>Custom Title</b></b>");
            tc.verifyEqual(annotation.font, struct( ...
                "color", "rgb(0,255,0)", ...
                "family", 'Arial, sans-serif', ...
                "size", 24 ...
            ));
        end

        function testAxisLabelSizeFont(tc)
            fig = figure("Visible","off");
            x = 1:10;
            y = x;
            plot(x,y);
            xlabel("X Label","FontSize",20,"Color","b", ...
                    "FontName","Comic Sans MS");
            ylabel("Y Label","FontSize",20,"Color","r", ...
                    "FontName","Comic Sans MS");

            p = plotlyfig(fig,"visible","off");

            tc.verifyEqual(p.layout.xaxis1.title, 'X Label');
            tc.verifyEqual(p.layout.xaxis1.titlefont, struct( ...
                "color", "rgb(0,0,255)", ...
                "size", 20, ...
                "family", 'Droid Sans, sans-serif' ...
            ));
            tc.verifyEqual(p.layout.yaxis1.title, 'Y Label');
            tc.verifyEqual(p.layout.yaxis1.titlefont, struct( ...
                "color", "rgb(255,0,0)", ...
                "size", 20, ...
                "family", 'Droid Sans, sans-serif' ...
            ));
        end
    end
end

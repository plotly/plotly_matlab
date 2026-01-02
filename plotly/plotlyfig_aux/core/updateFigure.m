%----UPDATE FIGURE DATA/LAYOUT----%
function obj = updateFigure(obj)
    %--------PLOTLY LAYOUT FIELDS---------%

    % title ..........[HANDLED BY updateAxis]
    % titlefont ..........[HANDLED BY updateAxis]
    % font ..........[HANDLED BY updateAxis]
    % showlegend ..........[HANDLED BY updateAxis]
    % autosize ... DONE
    % width ... DONE
    % height .... DONE
    % xaxis ..........[HANDLED BY updateAxis]
    % yaxis ..........[HANDLED BY updateAxis]
    % legend ..........[HANDLED BY updateAxis]
    % annotations ..........[HANDLED BY updateAnnotation]
    % margin ...DONE
    % paper_bgcolor ...DONE
    % plot_bgcolor ..........[HANDLED BY updateAxis]
    % hovermode ..........[NOT SUPPORTED IN MATLAB]
    % dragmode ..........[NOT SUPPORTED IN MATLAB]
    % separators ..........[NOT SUPPORTED IN MATLAB]
    % barmode ..........[HANDLED BY updateBar]
    % bargap ..........[HANDLED BY updateBar]
    % bargroupgap ..........[HANDLED BY updateBar]
    % boxmode ..........[HANDLED BY updateBox]
    % radialaxis ..........[HANDLED BY updatePolar]
    % angularaxis ..........[HANDLED BY updatePolar]
    % direction ..........[HANDLED BY updatePolar]
    % orientation ..........[HANDLED BY updatePolar]
    % hidesources ..........[NOT SUPPORTED IN MATLAB]


    %-STANDARDIZE UNITS-%
    figunits = obj.State.Figure.Handle.Units;
    obj.State.Figure.Handle.Units = 'pixels';

    %-FIGURE DATA-%
    figure_data = obj.State.Figure.Handle;

    obj.layout.autosize = false;
    obj.layout.margin.pad = obj.PlotlyDefaults.MarginPad;

    if (obj.State.Figure.NumLegends > 1)
        obj.layout.showlegend = true;
    else
        obj.layout.showlegend = false;
    end

    obj.layout.margin.l = 0;
    obj.layout.margin.r = 0;
    obj.layout.margin.b = 0;
    obj.layout.margin.t = 0;

    if obj.PlotOptions.AxisEqual
        wh = min(figure_data.Position(3:4));
        w = wh;
        h = wh;
    else
        w = figure_data.Position(3);
        h = figure_data.Position(4);
    end

    obj.layout.width = w * obj.PlotlyDefaults.FigureIncreaseFactor;
    obj.layout.height = h * obj.PlotlyDefaults.FigureIncreaseFactor;

    col = round(255*figure_data.Color);
    obj.layout.paper_bgcolor = getStringColor(col);

    obj.layout.hovermode = 'closest';

    %-REVERT UNITS-%
    obj.State.Figure.Handle.Units = figunits;
end

%----UPDATE FIGURE DATA/LAYOUT----%

function obj = updateFigure(obj, ~, ~)

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
% barmode ..........[HANDLED BY updateBar - DONE]
% bargap ..........[HANDLED BY updateBar - DONE]
% bargroupgap ..........[HANDLED BY updateBar]
% boxmode ..........[HANDLED BY updateBox]
% radialaxis ..........[HANDLED BY updatePolar]
% angularaxis ..........[HANDLED BY updatePolar]
% direction ..........[HANDLED BY updatePolar]
% orientation ..........[HANDLED BY updatePolar]
% hidesources ..........[NOT SUPPORTED IN MATLAB]

%-----------------------------------------------%

%figure data
figure_data = get(obj.State.Figure.Handle); 

%-STANDARDIZE UNITS-%
figunits = figure_data.Units;
set(obj.State.Figure.Handle,'Units','pixels');

%-MATLAB-PLOTLY DEFAULTS (NEED TO MODIFY SO THAT THESE UPDATE)-%

%-autosize-%
obj.layout.autosize = obj.PlotOptions.Strip;

%-margin pad-%
obj.layout.margin.pad = obj.PlotlyDefaults.MarginPad;

%-show legend-%
if(obj.State.Figure.NumLegends > 1)
    obj.layout.showlegend = true;
else
    obj.layout.showlegend = false;
end

%initialize margins to size of figure
obj.layout.margin.l = figure_data.Position(3);
obj.layout.margin.r = figure_data.Position(3);
obj.layout.margin.b = figure_data.Position(4);
obj.layout.margin.t = figure_data.Position(4);

%-width-%
obj.layout.width = figure_data.Position(3)*obj.PlotlyDefaults.FigureIncreaseFactor;

%-height-%
obj.layout.height = figure_data.Position(4)*obj.PlotlyDefaults.FigureIncreaseFactor;

%-paper_bgcolor-%
col = 255*figure_data.Color;
obj.layout.paper_bgcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

%-REVERT UNITS-%
set(obj.State.Figure.Handle,'Units',figunits);

end



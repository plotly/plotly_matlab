function obj = updateBaseline(obj, baseIndex)

%-------------------------------------------------------------------------%

%-UPDATE LINESERIES-%
updateLineseries(obj, baseIndex); 

%-SHOWLEGEND-%
obj.data{baseIndex}.showlegend = obj.PlotlyDefaults.ShowBaselineLegend; 

end
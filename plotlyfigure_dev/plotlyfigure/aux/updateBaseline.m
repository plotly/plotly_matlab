function obj = updateBaseline(obj, baseIndex)

%-------------------------------------------------------------------------%

%-UPDATE LINESERIES-%
updateLineseries(obj, baseIndex);

%-------------------------------------------------------------------------%

%-SHOWLEGEND-%
obj.data{baseIndex}.showlegend = obj.PlotlyDefaults.ShowBaselineLegend;

%-CHECK FOR MULTIPLE BASELINES-%
if ismultipleBaseline(obj,baseIndex)
    %-hide baseline if mutliple-%
    obj.data{baseIndex}.visible = false;
end

end
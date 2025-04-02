function obj = updateBaseline(obj, baseIndex)
    %-UPDATE LINESERIES-%
    obj.data{baseIndex} = updateLineseries(obj, baseIndex);

    %-baseline showlegend-%
    obj.data{baseIndex}.showlegend = obj.PlotlyDefaults.ShowBaselineLegend;

    %-CHECK FOR MULTIPLE BASELINES-%
    if isMultipleBaseline(obj, baseIndex)
        %-hide baseline if multiple-%
        obj.data{baseIndex}.visible = false;
    end
end

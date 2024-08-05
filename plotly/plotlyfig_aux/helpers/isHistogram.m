function check = isHistogram(obj, dataIndex)
    hist_data = obj.State.Plot(dataIndex).Handle;
    check = ~isempty(histogramOrientation(hist_data));
end

function obj = updateStemseries(obj,dataIndex)
    %-store original stem handle-%
    stem_group = obj.State.Plot(dataIndex).Handle;

    %-get children-%
    stem_child = get(stem_group, 'Children');

    %-update line-%
    obj.State.Plot(dataIndex).Handle = stem_child(1);
    stem_temp_data = updateLineseries(obj,dataIndex);

    %-update marker-%
    stem_marker = stem_temp_data.marker;
    obj.State.Plot(dataIndex).Handle = stem_child(2);
    stem_temp_data = updateLineseries(obj,dataIndex);

    %-scatter mode-%
    stem_temp_data.mode = 'lines+markers';

    stem_temp_data.marker = stem_marker;

    %-hide every other marker-%
    color_temp = cell(1,length(stem_temp_data.x));
    line_color_temp = cell(1,length(stem_temp_data.x));

    for n = 1:3:length(stem_temp_data.x)
        color_temp{n} = 'rgba(0,0,0,0)';
        color_temp{n+1} = stem_temp_data.marker.color;
        color_temp{n+2} = 'rgba(0,0,0,0)';
        line_color_temp{n} = 'rgba(0,0,0,0)';
        line_color_temp{n+1} = stem_temp_data.marker.line.color;
        line_color_temp{n+2} = 'rgba(0,0,0,0)';
    end

    % add new marker/line colors
    stem_temp_data.marker.color = color_temp;
    stem_temp_data.marker.line.color = line_color_temp;

    %-revert handle-%
    obj.State.Plot(dataIndex).Handle = stem_group;
    obj.data{dataIndex} = stem_temp_data;

    %-baseline (y=0 line) for octave stem-%
    %-stem3's baseline is a degenerate object with no data; converting
    %-it would add an empty 2D trace that draws a second axes frame-%
    if isprop(stem_group, 'baseline')
        baseLine = get(stem_group, 'baseline');
        if isempty(get(baseLine, 'XData'))
            return
        end
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        baseIndex = obj.PlotOptions.nPlots;
        obj.State.Plot(dataIndex).Handle = baseLine;
        baseData = updateLineseries(obj, dataIndex);
        baseData.showlegend = false;
        obj.data{baseIndex} = baseData;
        obj.State.Plot(dataIndex).Handle = stem_group;
    end
end

function updateScatterPolar(obj, plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-ASSOCIATE POLAR-AXES LAYOUT-%
    obj.data{plotIndex}.subplot = sprintf('polar%d', xsource+1);

    %-parse plot data-%
    rData = get(plotData, 'RData');
    thetaData = rad2deg(get(plotData, 'ThetaData'));

    thetaData(rData<0) = mod(thetaData(rData<0)+180, 360);
    rData = abs(rData);

    %-scatterpolar trace setting-%
    obj.data{plotIndex}.type = 'scatterpolar';
    obj.data{plotIndex}.mode = 'markers';
    obj.data{plotIndex}.visible = strcmp(get(plotData, 'Visible'),'on');
    obj.data{plotIndex}.name = get(plotData, 'DisplayName');

    %-set scatterpolar data-%
    obj.data{plotIndex}.r = rData;
    obj.data{plotIndex}.theta = thetaData;

    %-trace settings-%
    markerStruct = extractScatterMarker(plotData);

    obj.data{plotIndex}.marker = markerStruct;

    if isscalar(markerStruct.size)
        obj.data{plotIndex}.marker.size = markerStruct.size * 0.2;
    end

    if length(markerStruct.line.color) > 1
        obj.data{plotIndex}.marker.line.color = markerStruct.line.color{1};
    end

    %-legend setting-%
    obj.data{plotIndex}.showlegend = getShowLegend(plotData);

    %-set polar axes-%
    updatePolarAxesLayout(obj, plotIndex);
end

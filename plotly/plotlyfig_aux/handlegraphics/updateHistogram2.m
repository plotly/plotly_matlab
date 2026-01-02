function obj = updateHistogram2(obj,dataIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    xSource = findSourceAxis(obj, axIndex);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;

    colorMap = axisData.Colormap;
    barGap = 0.05;

    %-get trace data-%

    values = plotData.Values;
    if strcmp(plotData.ShowEmptyBins, 'on')
        values = values+1;
    end
    xEdges = plotData.XBinEdges;
    yEdges = plotData.YBinEdges;

    dx = diff(xEdges(2:end-1));
    dy = diff(yEdges(2:end-1));

    if isinf(xEdges(1))
        xEdges(1) = xEdges(2) - dx(1);
    end
    if isinf(yEdges(1))
        yEdges(1) = yEdges(2) - dy(1);
    end

    if isinf(xEdges(end))
        xEdges(end) = xEdges(end-1) + dx(1);
    end
    if isinf(yEdges(end))
        yEdges(end) = yEdges(end-1) + dy(1);
    end

    [xData, yData, zData, iData, jData, kData] = ...
            getPlotlyMesh3d( xEdges, yEdges, values, barGap );

    if strcmp(plotData.ShowEmptyBins, 'on')
        zData = zData-1;
    end

    cData = zeros(size(zData));
    for n = 1:2:length(zData)
        cData(n:n+1) = max(zData(n:n+1));
    end

    %-set trace-%
    updateScene(obj, dataIndex);

    obj.data{dataIndex}.type = 'mesh3d';
    obj.data{dataIndex}.scene = sprintf('scene%d', xSource);
    obj.data{dataIndex}.name = plotData.DisplayName;
    obj.data{dataIndex}.visible = strcmp(plotData.Visible,'on');
    obj.layout.bargap = barGap;

    %-set trace data-%
    obj.data{dataIndex}.x = xData;
    obj.data{dataIndex}.y = yData;
    obj.data{dataIndex}.z = zData;
    obj.data{dataIndex}.i = int16(iData - 1);
    obj.data{dataIndex}.j = int16(jData - 1);
    obj.data{dataIndex}.k = int16(kData - 1);

    %-set trace coloring-%
    faceColor = plotData.FaceColor;

    if isnumeric(faceColor)
        obj.data{dataIndex}.color = getStringColor(round(255*faceColor));
    elseif strcmp(faceColor, 'none')
        obj.data{dataIndex}.color = getStringColor(round(255*zeros(1,3)), 0.1);
    elseif strcmp(faceColor, 'flat')
        obj.data{dataIndex}.intensity = cData;
        obj.data{dataIndex}.colorscale = getColorScale(colorMap);
        obj.data{dataIndex}.cmin = axisData.CLim(1);
        obj.data{dataIndex}.cmax = axisData.CLim(2);
        obj.data{dataIndex}.showscale = false;
    end

    if ~strcmp(plotData.DisplayStyle, 'tile')
        obj.data{dataIndex}.flatshading = true;
        obj.data{dataIndex}.lighting.diffuse = 0.92;
        obj.data{dataIndex}.lighting.ambient = 0.54;
        obj.data{dataIndex}.lighting.specular = 1.42;
        obj.data{dataIndex}.lighting.roughness = 0.52;
        obj.data{dataIndex}.lighting.fresnel = 0.2;
        obj.data{dataIndex}.lighting.vertexnormalsepsilon = 1e-12;
        obj.data{dataIndex}.lighting.facenormalsepsilon = 1e-6;
    else
        obj.data{dataIndex}.lighting.diffuse = 0.92;
        obj.data{dataIndex}.lighting.ambient = 0.92;
    end
end

function updateScene(obj, dataIndex)

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.("scene" + xSource);

    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition;

    rangeXLim = rangeLength(axisData.XLim);
    rangeYLim = rangeLength(axisData.YLim);
    rangeZLim = rangeLength(axisData.ZLim);
    cameraEye = cameraEye./[rangeXLim, rangeYLim rangeZLim];
    eyeNorm = max(abs(cameraEye)) - 1.4;

    if strcmp(plotData.DisplayStyle, 'tile')
        aspectRatio(3) = 1e-6;
    else
        eyeNorm2 = min([norm(aspectRatio([1,3])), norm(aspectRatio([2,3]))]);
        eyeNorm = eyeNorm - eyeNorm2 + 0.6;
    end

    cameraEye = cameraEye / eyeNorm;

    %-aspect ratio-%
    scene.aspectratio.x = aspectRatio(1);
    scene.aspectratio.y = aspectRatio(2);
    scene.aspectratio.z = aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1);
    scene.camera.eye.y = cameraEye(2);
    scene.camera.eye.z = cameraEye(3);

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-get each scene axis-%
    scene.xaxis = getSceneAxis(axisData, 'X');
    scene.yaxis = getSceneAxis(axisData, 'Y');
    scene.zaxis = getSceneAxis(axisData, 'Z');

    if strcmp(plotData.DisplayStyle, 'tile')
        scene.zaxis.visible = false;
    end

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xsource) = scene;
end

function ax = getSceneAxis(axisData, axName)
    %-initializations-%
    axx = axisData.(axName + "Axis");
    ax.zeroline = false;
    ax.showline = true;
    ax.showspikes = true;
    ax.linecolor = getStringColor(round(255*axx.Color));
    ax.range = axisData.(axName + "Lim");

    %-label-%
    label = axisData.(axName + "Label");
    ax.title = label.String;
    if ~isempty(ax.title)
        ax.title = parseString(ax.title);
    end
    ax.titlefont.size = label.FontSize;
    ax.titlefont.color = getStringColor(round(255*label.Color));
    ax.titlefont.family = matlab2plotlyfont(label.FontName);

    %-ticks-%
    ax.tickvals = axx.TickValues;
    ax.ticktext = axx.TickLabels;

    ax.tickcolor = getStringColor(round(255*axx.Color));
    ax.tickfont.size = axx.FontSize;
    ax.tickfont.family = matlab2plotlyfont(axx.FontName);

    switch axx.TickDirection
        case 'in'
            ax.ticks = 'inside';
        case 'out'
            ax.ticks = 'outside';
    end

    %-grid-%
    axGrid = axisData.(axName + "Grid");
    if strcmp(axGrid, 'off')
        ax.showgrid = false;
    end

    %-box-%
    if strcmp(axisData.Box, 'on')
        ax.mirror = true;
    end
end

function bar_ = barData(position3d, size_)
    % position3d - 3-list or array of shape (3,) that represents the point of coords (x, y, 0), where a bar is placed
    % size = a 3-tuple whose elements are used to scale a unit cube to get a paralelipipedic bar
    % returns - an array of shape(8,3) representing the 8 vertices of  a bar at position3d

    if nargin < 2
        size_ = [1, 1, 1];
    end

    bar_ = [...
            0, 0, 0; ...
            1, 0, 0; ...
            1, 1, 0; ...
            0, 1, 0; ...
            0, 0, 1; ...
            1, 0, 1; ...
            1, 1, 1; ...
            0, 1, 1 ...
            ]; % the vertices of the unit cube

    for n =1:size(bar_, 1)
        bar_(n,:) = bar_(n,:) .* size_; % scale the cube to get the vertices of a parallelipipedic bar_
    end


    bar_ = bar_ + position3d; %translate each  bar_ on the directio OP, with P=position3d
end

function [vertices, I, J, K] = triangulateBarFaces(positions, sizes)
    % positions - array of shape (N, 3) that contains all positions in the plane z=0, where a histogram bar is placed
    % sizes -  array of shape (N,3); each row represents the sizes to scale a unit cube to get a bar
    % returns the array of unique vertices, and the lists i, j, k to be used in instantiating the go.Mesh3d class

    if nargin < 2
        sizes = ones(size(positions,1), 3); %[(1,1,1)]*len(positions)
    else
        sizes;
        % if isinstance(sizes, (list, np.ndarray)) and len(sizes) != len(positions):
        %     raise ValueError('Your positions and sizes lists/arrays do not have the same length')
    end

    c = 1;
    for n = 1:size(positions, 1)
        if sizes(n, 3) ~= 0
            all_bars(:,:,c) = barData(positions(n,:), sizes(n,:))';
            c = c+1;
        end
    end

    % all_bars = [barData(pos, size)  for pos, size in zip(positions, sizes) if size[2]!=0]
    [r, q, p] = size(all_bars);

    % extract unique vertices from the list of all bar vertices
    all_bars = reshape(all_bars, [r, p*q])';
    [vertices, ~, ixr] = unique(all_bars, 'rows');

    %for each bar, derive the sublists of indices i, j, k associated to its chosen  triangulation
    I = [];
    J = [];
    K = [];

    for k = 0:p-1
        aux = ixr([1+8*k, 1+8*k+2,1+8*k, 1+8*k+5,1+8*k, 1+8*k+7, 1+8*k+5, 1+8*k+2, 1+8*k+3, 1+8*k+6, 1+8*k+7, 1+8*k+5]);
        I = [ I;  aux(:)];
        aux = ixr([1+8*k+1, 1+8*k+3, 1+8*k+4, 1+8*k+1, 1+8*k+3, 1+8*k+4, 1+8*k+1, 1+8*k+6, 1+8*k+7, 1+8*k+2, 1+8*k+4, 1+8*k+6]);
        J = [ J;  aux(:)];
        aux = ixr([1+8*k+2, 1+8*k, 1+8*k+5, 1+8*k, 1+8*k+7, 1+8*k, 1+8*k+2, 1+8*k+5, 1+8*k+6, 1+8*k+3, 1+8*k+5, 1+8*k+7]);
        K = [ K;  aux(:)];
    end
end

function [X, Y, Z, I, J, K] = getPlotlyMesh3d(xedges, yedges, values, bargap)
    % x, y- array-like of shape (n,), defining the x, and y-coordinates of data set for which we plot a 3d hist

    xsize = xedges(2)-xedges(1)-bargap;
    ysize = yedges(2)-yedges(1)-bargap;
    [xe, ye]= meshgrid(xedges(1:end-1), yedges(1:end-1));
    ze = zeros(size(xe));

    positions = zeros([size(xe), 3]);
    positions(:,:,1) = xe;
    positions(:,:,2) = ye;
    positions(:,:,3) = ze;

    [m, n, p] = size(positions);
    positions = reshape(positions, [m*n, p]);

    h = values'; h = h(:);
    sizes = [];
    for n = 1:length(h)
        sizes = [sizes; xsize, ysize, h(n)];
    end

    [vertices, I, J, K]  = triangulateBarFaces(positions, sizes);
    X = vertices(:,1);
    Y = vertices(:,2);
    Z = vertices(:,3);
end

function colorScale = getColorScale(colorMap)
    nColors = size(colorMap, 1);
    normInd = rescale([1:nColors], 0, 1);
    colorScale = cell(nColors, 1);

    for n = 1:nColors
        colorScale{n} = {normInd(n), getStringColor(round(255*colorMap(n, :)))};
    end
end

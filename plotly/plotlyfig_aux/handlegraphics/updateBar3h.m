function obj = updateBar3h(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    bar_data = obj.State.Plot(surfaceIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-AXIS STRUCTURE-%
    axis_data = ancestor(bar_data.Parent,'axes');

    %-GET SCENE-%
    scene = obj.layout.("scene" + xsource);

    %-associate scene-%
    obj.data{surfaceIndex}.scene = sprintf('scene%d', xsource);

    %-surface type-%
    obj.data{surfaceIndex}.type = 'mesh3d';

    %-FORMAT DATA-%
    xdata = bar_data.XData;
    ydata = bar_data.ZData;
    zdata = bar_data.YData;
    cdata = bar_data.CData;

    %-parse xedges-%
    xedges = xdata(2, 1:2:end);

    %-parse yedges-%
    yedges = ydata(2:6:end, 2);
    yedges = [yedges', mean(diff(yedges(1:2)))];

    %-parse values-%
    values = [];
    for n = 1:6:size(zdata, 1)
        values = [values, diff(zdata(n:n+1, 2))];
    end

    %-parse offsets-%
    offsets = zdata(1:6:end, 2)';

    %-get the values to use plotly's mesh3D-%
    bargap = diff(yedges(1:2)) - diff(ydata(2:3));
    [X, Y, Z, I, J, K] = get_plotly_mesh3d(xedges, yedges, values, bargap);

    %-reformat Z according to offsets-%
    m = 1;
    lz2 = 0.5*length(Z);

    for n = 1:4:lz2
        Z(n:n+3) = Z(n:n+3)+offsets(m);
        Z(n+lz2:n+lz2+3) = Z(n+lz2:n+lz2+3)+offsets(m);
        m = m + 1;
    end

    %-set mesh3d data-%
    obj.data{surfaceIndex}.x = X;
    obj.data{surfaceIndex}.y = Z;
    obj.data{surfaceIndex}.z = Y;
    obj.data{surfaceIndex}.i = int16(I-1);
    obj.data{surfaceIndex}.j = int16(J-1);
    obj.data{surfaceIndex}.k = int16(K-1);

    %-coloring-%
    cmap = figure_data.Colormap;

    if isnumeric(bar_data.FaceColor)
        %-paper_bgcolor-%
        col = round(255*bar_data.FaceColor);
        col = getStringColor(col);
    else
        switch bar_data.FaceColor
            case 'none'
                col = 'rgba(0,0,0,0)';
            case {'flat','interp'}
                switch bar_data.CDataMapping
                    case 'scaled'
                        capCD = max(min(cdata(1,1), axis_data.CLim(2)), ...
                                axis_data.CLim(1));
                        scalefactor = (capCD - axis_data.CLim(1)) ...
                                / diff(axis_data.CLim);
                        col = round(255*(cmap(1+ floor(scalefactor ...
                                *(length(cmap)-1)),:)));
                    case 'direct'
                        col = round(255*(cmap(cdata(1,1),:)));
                end
                col = getStringColor(col);
            case 'auto'
                col = 'rgb(0,113.985,188.955)';
        end
    end

    obj.data{surfaceIndex}.color = col;

    %-some settings-%
    obj.data{surfaceIndex}.contour.show = true;
    obj.data{surfaceIndex}.contour.width = 6;
    obj.data{surfaceIndex}.contour.color = 'rgb(0,0,0)';
    obj.data{surfaceIndex}.flatshading = false;

    %-lighting settings-%
    obj.data{surfaceIndex}.lighting.diffuse = 0.8;
    obj.data{surfaceIndex}.lighting.ambient = 0.65;
    obj.data{surfaceIndex}.lighting.specular = 1.42;
    obj.data{surfaceIndex}.lighting.roughness = 0.52;
    obj.data{surfaceIndex}.lighting.fresnel = 0.2;
    obj.data{surfaceIndex}.lighting.vertexnormalsepsilon = 1e-12;
    obj.data{surfaceIndex}.lighting.facenormalsepsilon = 1e-6;

    obj.data{surfaceIndex}.lightposition.x = 0;
    obj.data{surfaceIndex}.lightposition.y = 0;
    obj.data{surfaceIndex}.lightposition.z = 0;

    %-surface name-%
    obj.data{surfaceIndex}.name = bar_data.DisplayName;

    %-surface visible-%
    obj.data{surfaceIndex}.visible = strcmp(bar_data.Visible,'on');

    switch bar_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{surfaceIndex}.showlegend = true;
        case "off"
            obj.data{surfaceIndex}.showlegend = false;
    end

    %-SETTING SCENE-%

    %-aspect ratio-%
    ar = obj.PlotOptions.AspectRatio;

    if ~isempty(ar)
        if ischar(ar)
            scene.aspectmode = ar;
        elseif isvector(ar) && length(ar) == 3
            xar = ar(1);
            yar = ar(2);
            zar = ar(3);
        end
    else
        %-define as default-%
        xar = max(xedges(:));
        zar = max(yedges(:));
        yar = 0.7*max([xar, zar]);
    end

    scene.aspectratio.x = xar;
    scene.aspectratio.y = yar;
    scene.aspectratio.z = zar;

    %-camera eye-%
    ey = obj.PlotOptions.CameraEye;

    if ~isempty(ey)
        if isvector(ey) && length(ey) == 3
            scene.camera.eye.x = ey(1);
            scene.camera.eye.y = ey(2);
            scene.camera.eye.z = ey(3);
        end
    else
        %-define as default-%
        scene.camera.eye.x = xar + 7;
        scene.camera.eye.y = yar + 0;
        scene.camera.eye.z = zar + 0.5;
    end

    %-axis configuration-%
    scene.xaxis.range = axis_data.XLim(end:-1:1);
    scene.yaxis.range = axis_data.YLim;
    scene.zaxis.range = axis_data.ZLim;

    scene.xaxis.tickvals = axis_data.XTick;
    scene.xaxis.ticktext = axis_data.XTickLabel;

    scene.yaxis.tickvals = axis_data.YTick;
    scene.yaxis.ticktext = axis_data.YTickLabel;

    scene.zaxis.tickvals = axis_data.ZTick;
    scene.zaxis.ticktext = axis_data.ZTickLabel;

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.zaxis.tickcolor = 'rgba(0,0,0,1)';

    scene.xaxis.ticklabelposition = 'outside';
    scene.yaxis.ticklabelposition = 'outside';
    scene.zaxis.ticklabelposition = 'outside';

    scene.xaxis.title = axis_data.XLabel.String;
    scene.yaxis.title = axis_data.YLabel.String;
    scene.zaxis.title = axis_data.ZLabel.String;

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xsource) = scene;
end

function bar_ = bar_data(position3d, size_)
    % position3d - 3-list or array of shape (3,) that represents the point
    %       of coords (x, y, 0), where a bar is placed.
    % size = a 3-tuple whose elements are used to scale a unit cube to get
    %       a paralelipipedic bar.
    % returns - an array of shape(8,3) representing the 8 vertices of a bar
    %       at position3d.

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
        % scale the cube to get the vertices of a parallelipipedic bar_
        bar_(n,:) = bar_(n,:) .* size_;
    end

    %translate each  bar_ on the directio OP, with P=position3d
    bar_ = bar_ + position3d;
end

function [vertices, I, J, K] = triangulate_bar_faces(positions, sizes)
    % positions - array of shape (N, 3) that contains all positions in the
    %       plane z=0, where a histogram bar is placed.
    % sizes - array of shape (N,3); each row represents the sizes to scale
    %       a unit cube to get a bar.
    % returns the array of unique vertices, and the lists i, j, k to be
    %       used in instantiating the go.Mesh3d class.

    if nargin < 2
        sizes = ones(size(positions,1), 3); %[(1,1,1)]*len(positions)
    end

    c = 1;
    for n = 1:size(positions, 1)
        if sizes(n, 3) ~= 0
            all_bars(:,:,c) = bar_data(positions(n,:), sizes(n,:))';
            c = c+1;
        end
    end

    % all_bars = [bar_data(pos, size)  for pos, size in
    % zip(positions, sizes) if size[2]!=0]
    [r, q, p] = size(all_bars);

    % extract unique vertices from the list of all bar vertices
    all_bars = reshape(all_bars, [r, p*q])';
    [vertices, ~, ixr] = unique(all_bars, 'rows');

    %for each bar, derive the sublists of indices i, j, k associated to its chosen  triangulation
    I = [];
    J = [];
    K = [];

    for k = 0:p-1
        aux = ixr([1+8*k, 1+8*k+2,1+8*k, 1+8*k+5,1+8*k, 1+8*k+7, ...
                1+8*k+5, 1+8*k+2, 1+8*k+3, 1+8*k+6, 1+8*k+7, 1+8*k+5]);
        I = [I; aux(:)];
        aux = ixr([1+8*k+1, 1+8*k+3, 1+8*k+4, 1+8*k+1, 1+8*k+3, ...
                1+8*k+4, 1+8*k+1, 1+8*k+6, 1+8*k+7, 1+8*k+2, 1+8*k+4, ...
                1+8*k+6]);
        J = [J; aux(:)];
        aux = ixr([1+8*k+2, 1+8*k, 1+8*k+5, 1+8*k, 1+8*k+7, 1+8*k, ...
                1+8*k+2, 1+8*k+5, 1+8*k+6, 1+8*k+3, 1+8*k+5, 1+8*k+7]);
        K = [K; aux(:)];
    end
end

function [X, Y, Z, I, J, K] = get_plotly_mesh3d(xedges, yedges, values, bargap)
    % x, y- array-like of shape (n,), defining the x, and y-coordinates of data set for which we plot a 3d hist

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
        sizes = [sizes; ysize, ysize, h(n)];
    end

    [vertices, I, J, K]  = triangulate_bar_faces(positions, sizes);
    X = vertices(:,1);
    Y = vertices(:,2);
    Z = vertices(:,3);
end

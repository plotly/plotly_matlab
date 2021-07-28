function obj = updateHistogram2(obj,histIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);

%-HIST DATA STRUCTURE- %
hist_data = get(obj.State.Plot(histIndex).Handle);

%-hist type-%
obj.data{histIndex}.type = 'mesh3d';

%-required parameters-%
values = hist_data.Values;
xedges = hist_data.XBinEdges;
yedges = hist_data.YBinEdges;

%-get the values to use plotly's mesh3D-%
bargap = 0.06;
[X, Y, Z, I, J, K] = get_plotly_mesh3d(xedges, yedges, values, bargap);

%-passing parameters to mesh3D-%
obj.data{histIndex}.x = X;
obj.data{histIndex}.y = Y;
obj.data{histIndex}.z = Z;
obj.data{histIndex}.i = uint16(I-1);
obj.data{histIndex}.j = uint16(J-1);
obj.data{histIndex}.k = uint16(K-1);

%-some settings-%
obj.data{histIndex}.color=[0.8,0.8,0.8];
obj.data{histIndex}.contour.show = true;
obj.data{histIndex}.contour.color = 'black';
obj.data{histIndex}.contour.width = 6;
obj.data{histIndex}.flatshading = true;
obj.data{histIndex}.bordercolor = 'black';
obj.data{histIndex}.borderwidth = 6;

%-layout bargap-%
obj.layout.bargap = bargap;

%-layout barmode-%
obj.layout.barmode = 'group';

%-hist name-%
obj.data{histIndex}.name = hist_data.DisplayName;

%-hist visible-%
obj.data{histIndex}.visible = strcmp(hist_data.Visible,'on');

end


function bar_ = bar_data(position3d, size_)
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

function [vertices, I, J, K] = triangulate_bar_faces(positions, sizes)
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
            all_bars(:,:,c) = bar_data(positions(n,:), sizes(n,:))';
            c = c+1;
        end
    end

    % all_bars = [bar_data(pos, size)  for pos, size in zip(positions, sizes) if size[2]!=0]
    [r, q, p] = size(all_bars);

    % extract unique vertices from the list of all bar vertices
    all_bars = reshape(all_bars, [r, p*q])';
    [vertices, ~, ixr] = unique(all_bars, 'rows');

    %for each bar, derive the sublists of indices i, j, k assocated to its chosen  triangulation
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

function [X, Y, Z, I, J, K] = get_plotly_mesh3d(xedges, yedges, values, bargap)
    % x, y- array-like of shape (n,), defining the x, and y-ccordinates of data set for which we plot a 3d hist

    xsize = xedges(2)-xedges(1)-bargap;
    ysize = yedges(2)-yedges(1)-bargap;
    [xe, ye]= meshgrid(xedges(1:end-1), yedges(1:end-1));
    ze = zeros(size(xe));

    positions = zeros([size(xe), 3]);
    positions(:,:,1) = ye';
    positions(:,:,2) = xe';
    positions(:,:,3) = ze';

    [m, n, p] = size(positions);
    positions = reshape(positions, [m*n, p]);

    h = values'; h = h(:);
    sizes = [];
    for n = 1:length(h)
        sizes = [sizes; xsize, ysize, h(n)];
    end

    [vertices, I, J, K]  = triangulate_bar_faces(positions, sizes);
    X = vertices(:,1);
    Y = vertices(:,2);
    Z = vertices(:,3);

end
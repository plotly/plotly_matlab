function obj = updatePatch(obj, patchIndex)

    %----PATCH FIELDS---%

    % x - [DONE]
    % y - [DONE]
    % r - [HANDLED BY SCATTER]
    % t - [HANDLED BY SCATTER]
    % mode - [DONE]
    % name - [DONE]
    % text - [NOT SUPPORTED IN MATLAB]
    % error_y - [HANDLED BY ERRORBAR]
    % error_x - [HANDLED BY ERRORBAR]
    % marler.color - [DONE]
    % marker.size - [DONE]
    % marker.line.color - [DONE]
    % marker.line.width - [DONE]
    % marker.line.dash - [NOT SUPPORTED IN MATLAB]
    % marker.line.opacity --- [TODO]
    % marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
    % marker.line.shape - [NOT SUPPORTED IN MATLAB]
    % marker.opacity - [NOT SUPPORTED IN MATLAB]
    % marker.colorscale - [NOT SUPPORTED IN MATLAB]
    % marker.sizemode - [NOT SUPPORTED IN MATLAB]
    % marker.sizeref - [NOT SUPPORTED IN MATLAB]
    % marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]
    % line.color - [DONE]
    % line.width - [DONE]
    % line.dash - [DONE]
    % line.opacity --- [TODO]
    % line.smoothing - [NOT SUPPORTED IN MATLAB]
    % line.shape - [NOT SUPPORTED IN MATLAB]
    % connectgaps - [NOT SUPPORTED IN MATLAB]
    % fill - [HANDLED BY PATCH]
    % fillcolor - [HANDLED BY PATCH]
    % opacity --- [TODO]
    % textfont - [NOT SUPPORTED IN MATLAB]
    % textposition - [NOT SUPPORTED IN MATLAB]
    % xaxis [DONE]
    % yaxis [DONE]
    % showlegend [DONE]
    % stream - [HANDLED BY PLOTLYSTREAM]
    % visible [DONE]
    % type [DONE]

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

    %-PATCH DATA STRUCTURE- %
    patch_data = obj.State.Plot(patchIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-patch xaxis and yaxis-%
    obj.data{patchIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{patchIndex}.yaxis = sprintf("y%d", ysource);

    %-patch type-%
    if any(nonzeros(get(patch_data, 'ZData')))
        if obj.PlotOptions.TriangulatePatch
            obj.data{patchIndex}.type = 'mesh3d';
            % update the patch data using reducepatch
            patch_data_red = reducepatch(obj.State.Plot(patchIndex).Handle, 1);
        elseif isprop(patch_data, 'Faces') && isprop(patch_data, 'Vertices') ...
                && ~isempty(get(patch_data, 'Faces'))
            % patches defined by Faces/Vertices (trisurf, trimesh,
            % tetramesh, isosurface, bar3...) render as a colored
            % triangular mesh
            obj.data{patchIndex}.type = 'mesh3d';
            patch_data_red = patch_data;
        else
            obj.data{patchIndex}.type = 'scatter3d';
        end
    else
        obj.data{patchIndex}.type = 'scatter';
    end

    if ~strcmp(obj.data{patchIndex}.type, 'mesh3d')
        %-patch x-%
        xdata = get(patch_data, 'XData');
        if isvector(xdata)
            obj.data{patchIndex}.x = [xdata' xdata(1)];
        else
            obj.data{patchIndex}.x = reshape([xdata; xdata(1,:); ...
                    NaN(1,size(xdata,2))], [], 1);
        end

        %-patch y-%
        ydata = get(patch_data, 'YData');
        if isvector(ydata)
            obj.data{patchIndex}.y = [ydata' ydata(1)];
        else
            obj.data{patchIndex}.y = reshape([ydata; ydata(1,:); ...
                    NaN(1,size(ydata,2))], [], 1);
        end

        %-patch z-%
        if any(nonzeros(get(patch_data, 'ZData')))
            zdata = get(patch_data, 'ZData');
            if isvector(ydata)
                obj.data{patchIndex}.z = [zdata' zdata(1)];
            else
                obj.data{patchIndex}.z = reshape([zdata; zdata(1,:); ...
                        NaN(1,size(zdata,2))], [], 1);
            end
        end

        obj.data{patchIndex}.name = get(patch_data, 'DisplayName');
        obj.data{patchIndex}.visible = strcmp(get(patch_data, 'Visible'),'on');

        %-patch fill-%
        obj.data{patchIndex}.fill = 'tozeroy';

        %-PATCH MODE-%
        if ~strcmpi('none', get(patch_data, 'Marker')) ...
                && ~strcmpi('none', get(patch_data, 'LineStyle'))
            mode = 'lines+markers';
        elseif ~strcmpi('none', get(patch_data, 'Marker'))
            mode = 'markers';
        elseif ~strcmpi('none', get(patch_data, 'LineStyle'))
            mode = 'lines';
        else
            mode = 'none';
        end

        obj.data{patchIndex}.mode = mode;
        obj.data{patchIndex}.marker = extractPatchMarker(patch_data);
        obj.data{patchIndex}.line = extractPatchLine(patch_data);

        %-patch fillcolor-%
        fill = extractPatchFace(patch_data);

        if strcmp(obj.data{patchIndex}.type,'scatter')
            obj.data{patchIndex}.fillcolor = fill.color;
        else
            obj.data{patchIndex}.surfacecolor = fill.color;
        end

        %-surfaceaxis-%
        if strcmp(obj.data{patchIndex}.type,'scatter3d')
            minstd = min([std(get(patch_data, 'XData')) std(get(patch_data, 'YData')) std(get(patch_data, 'ZData'))]);
            ind = find([std(get(patch_data, 'XData')) std(get(patch_data, 'YData')) std(get(patch_data, 'ZData'))] == minstd)-1;
            obj.data{patchIndex}.surfaceaxis = ind;
        end
    else
        % handle vertices
        tmpvertices = get(patch_data_red, 'vertices');
        x_data = tmpvertices(:,1);
        y_data = tmpvertices(:,2);
        z_data = tmpvertices(:,3);

        % specify how vertices connect to form the faces
        tmpfaces = get(patch_data_red, 'faces');

        %-colors stored on the patch (per face or per vertex)-%
        try
            faceVertexCData = get(patch_data, 'FaceVertexCData');
        catch
            faceVertexCData = [];
        end

        %-mesh3d only accepts triangles: fan-triangulate polygonal
        %-faces (bar3/bar3h quads, fill3 polygons) and replicate any
        %-per-face colors across the resulting triangles-%
        tmpfacesOrig = tmpfaces;
        if size(tmpfaces, 2) > 3
            nPolys = size(tmpfaces, 1);
            fvcPerPoly = numel(faceVertexCData) == nPolys;
            fanFaces = cell(1, nPolys);
            fanFVC = cell(1, nPolys);
            for p = 1:nPolys
                v = tmpfaces(p, :);
                nTris = numel(v) - 2;
                fanFaces{p} = [repmat(v(1), nTris, 1), v(2:end-1)', v(3:end)'];
                if fvcPerPoly
                    fanFVC{p} = faceVertexCData(p) * ones(nTris, 1);
                end
            end
            tmpfaces = cell2mat(fanFaces');
            if fvcPerPoly
                faceVertexCData = cell2mat(fanFVC');
            end
        end

        i_data = tmpfaces(:,1)-1;
        j_data = tmpfaces(:,2)-1;
        k_data = tmpfaces(:,3)-1;

        %-which channel carries the data: native patches color either
        %-the faces (trisurf) or the edges (trimesh) flat-%
        faceColor = get(patch_data, 'FaceColor');
        edgeColor = get(patch_data, 'EdgeColor');
        faceIsFlat = ischar(faceColor) && any(strcmp(faceColor, {'flat', 'interp'}));
        edgeIsFlat = ischar(edgeColor) && any(strcmp(edgeColor, {'flat', 'interp'}));
        % patches always draw their faces (white for trimesh); only
        % FaceColor 'none' is edge-only
        wantMesh = ~(ischar(faceColor) && strcmp(faceColor, 'none'));

        %-per-vertex intensity from the patch colors (shared by the
        %-mesh faces and the flat edge colors)-%
        if ~isempty(faceVertexCData) && isnumeric(faceVertexCData) ...
                && numel(faceVertexCData) > 1
            cLim = get(ancestor(get(patch_data, 'Parent'), 'axes'), 'CLim');
            cMap = get(ancestor(get(patch_data, 'Parent'), 'figure'), 'Colormap');
            if numel(faceVertexCData) == size(tmpfaces, 1)
                % per-face colors: average over the incident faces
                intensity = zeros(size(x_data));
                for f = 1:size(tmpfaces, 1)
                    intensity(tmpfaces(f, :)) = ...
                        intensity(tmpfaces(f, :)) + faceVertexCData(f);
                end
                counts = zeros(size(x_data));
                for f = 1:size(tmpfaces, 1)
                    counts(tmpfaces(f, :)) = ...
                        counts(tmpfaces(f, :)) + 1;
                end
                intensity = intensity ./ max(counts, 1);
            else
                intensity = faceVertexCData(:);
            end
        end

        if wantMesh
            %-patch x/y/z-%
            obj.data{patchIndex}.x = x_data;
            obj.data{patchIndex}.y = y_data;
            obj.data{patchIndex}.z = z_data;

            %-patch i/j/k-%
            obj.data{patchIndex}.i = i_data;
            obj.data{patchIndex}.j = j_data;
            obj.data{patchIndex}.k = k_data;

            %-patch fillcolor-%
            fill = extractPatchFace(patch_data);
            obj.data{patchIndex}.color = fill.color;
            if ~faceIsFlat
                % solid-color faces (fill3, tetramesh, trimesh's white
                % faces) render flat: no lighting gradients
                obj.data{patchIndex}.lighting.diffuse = 0;
                obj.data{patchIndex}.lighting.ambient = 1;
            end

            %-per-face or per-vertex colors (trisurf, isosurface...)-%
            if faceIsFlat && ~isempty(faceVertexCData) ...
                    && isnumeric(faceVertexCData) ...
                    && numel(faceVertexCData) > 1
                obj.data{patchIndex}.intensity = intensity;
                obj.data{patchIndex}.cmin = cLim(1);
                obj.data{patchIndex}.cmax = cLim(2);
                len = size(cMap, 1) - 1;
                for c = 1:size(cMap, 1)
                    obj.data{patchIndex}.colorscale{c} = ...
                        {(c-1)/len, getStringColor(round(255*cMap(c, :)))};
                end
                obj.data{patchIndex}.showscale = false;
            end
        else
            % no faces to draw (trimesh): the slot becomes the edge line
            obj.data{patchIndex} = struct();
            obj.data{patchIndex}.type = 'scatter3d';
        end

        %-patch edges: mesh3d draws no lines, so stroke each face
        %-border with its own line trace. plotly's gl3d lines ignore
        %-NaN breaks, so separate faces must not share a trace (the
        %-wireframe would weld into one continuous line)-%
        if ~(ischar(edgeColor) && strcmp(edgeColor, 'none'))
            for fIdx = 1:size(tmpfacesOrig, 1)
                v = tmpfacesOrig(fIdx, :);
                n = numel(v);
                % closed polygon loop: (v1,v2)...(vn,v1)
                ex = zeros(1, n+1);
                ey = zeros(1, n+1);
                ez = zeros(1, n+1);
                for s = 1:n
                    ex(s) = x_data(v(s));
                    ey(s) = y_data(v(s));
                    ez(s) = z_data(v(s));
                end
                ex(n+1) = x_data(v(1));
                ey(n+1) = y_data(v(1));
                ez(n+1) = z_data(v(1));
                if edgeIsFlat && ~isempty(faceVertexCData)
                    % one color per face: the mean z over its vertices
                    meanVal = mean(intensity(v));
                    idx = 1 + round((max(min(meanVal, cLim(2)), cLim(1)) - cLim(1)) ...
                            / max(diff(cLim), eps) * (size(cMap, 1) - 1));
                    idx = max(1, min(idx, size(cMap, 1)));
                    col = getStringColor(round(255*cMap(idx, :)));
                    edgeTrace = struct('type', 'scatter3d', 'mode', 'lines', ...
                        'x', ex, 'y', ey, 'z', ez, ...
                        'scene', sprintf('scene%d', xsource), 'showlegend', false, ...
                        'line', struct('color', col, 'width', 2));
                else
                    edgeTrace = struct('type', 'scatter3d', 'mode', 'lines', ...
                        'x', ex, 'y', ey, 'z', ez, ...
                        'scene', sprintf('scene%d', xsource), 'showlegend', false, ...
                        'line', struct('color', ...
                            getStringColor(round(255*edgeColor)), ...
                            'width', max(1, get(patch_data, 'LineWidth'))));
                end
                if wantMesh
                    obj.PlotlyDefaults.patchEdges{end+1} = edgeTrace;
                elseif fIdx == 1
                    obj.data{patchIndex} = edgeTrace;
                else
                    obj.PlotlyDefaults.patchEdges{end+1} = edgeTrace;
                end
            end
        end
    end

    if strcmp(obj.data{patchIndex}.type, 'mesh3d') ...
            || (numel(obj.data) >= patchIndex ...
                && isfield(obj.data{patchIndex}, 'scene') ...
                && strcmp(obj.data{patchIndex}.type, 'scatter3d'))
        %-associate scene-%
        obj.data{patchIndex}.scene = sprintf('scene%d', xsource);
        obj.data{patchIndex}.name = get(patch_data, 'DisplayName');
        obj.data{patchIndex}.visible = strcmp(get(patch_data, 'Visible'), 'on');
        updateScene(obj, patchIndex, 'setTitleFont', false, ...
            'handleDatetimeTicks', false);
    end

    obj.data{patchIndex}.showlegend = getShowLegend(patch_data);

    obj.data{patchIndex}.showlegend = obj.data{patchIndex}.showlegend & ~isempty(obj.data{patchIndex}.name);
end

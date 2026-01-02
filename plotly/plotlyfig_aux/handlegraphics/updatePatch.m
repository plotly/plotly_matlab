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
    obj.data{patchIndex}.xaxis = "x" + xsource;
    obj.data{patchIndex}.yaxis = "y" + ysource;

    %-patch type-%
    if any(nonzeros(patch_data.ZData))
        if obj.PlotOptions.TriangulatePatch
            obj.data{patchIndex}.type = 'mesh3d';
            % update the patch data using reducepatch
            patch_data_red = reducepatch(obj.State.Plot(patchIndex).Handle, 1);
        else
            obj.data{patchIndex}.type = 'scatter3d';
        end
    else
        obj.data{patchIndex}.type = 'scatter';
    end

    if ~strcmp(obj.data{patchIndex}.type, 'mesh3d')
        %-patch x-%
        xdata = patch_data.XData;
        if isvector(xdata)
            obj.data{patchIndex}.x = [xdata' xdata(1)];
        else
            xnew = [];
            for n = 1:size(xdata,2)
                xnew = [xnew ; xdata(:,n) ; xdata(1,n); NaN];
            end
            obj.data{patchIndex}.x = xnew;
        end

        %-patch y-%
        ydata = patch_data.YData;
        if isvector(ydata)
            obj.data{patchIndex}.y = [ydata' ydata(1)];
        else
            ynew = [];
            for n = 1:size(ydata,2)
                ynew = [ynew ; ydata(:,n) ; ydata(1,n); NaN];
            end
            obj.data{patchIndex}.y = ynew;
        end

        %-patch z-%
        if any(nonzeros(patch_data.ZData))
            zdata = patch_data.ZData;
            if isvector(ydata)
                obj.data{patchIndex}.z = [zdata' zdata(1)];
            else
                znew = [];
                for n = 1:size(zdata,2)
                    znew = [znew ; zdata(:,n) ; zdata(1,n); NaN];
                end
                obj.data{patchIndex}.z = znew;
            end
        end

        obj.data{patchIndex}.name = patch_data.DisplayName;
        obj.data{patchIndex}.visible = strcmp(patch_data.Visible,'on');

        %-patch fill-%
        obj.data{patchIndex}.fill = 'tozeroy';

        %-PATCH MODE-%
        if ~strcmpi('none', patch_data.Marker) ...
                && ~strcmpi('none', patch_data.LineStyle)
            mode = 'lines+markers';
        elseif ~strcmpi('none', patch_data.Marker)
            mode = 'markers';
        elseif ~strcmpi('none', patch_data.LineStyle)
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
            minstd = min([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)]);
            ind = find([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)] == minstd)-1;
            obj.data{patchIndex}.surfaceaxis = ind;
        end
    else
        % handle vertices
        x_data = patch_data_red.vertices(:,1);
        y_data = patch_data_red.vertices(:,2);
        z_data = patch_data_red.vertices(:,3);

        % specify how vertices connect to form the faces
        i_data = patch_data_red.faces(:,1)-1;
        j_data = patch_data_red.faces(:,2)-1;
        k_data = patch_data_red.faces(:,3)-1;

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
    end

    switch patch_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{patchIndex}.showlegend = true;
        case "off"
            obj.data{patchIndex}.showlegend = false;
    end

    obj.data{patchIndex}.showlegend = obj.data{patchIndex}.showlegend & ~isempty(obj.data{patchIndex}.name);
end

function annotation = updateAnnotation(obj,anIndex)
    %-------X/YLABEL FIELDS--------%
    % title...[DONE]
    % titlefont.size...[DONE]
    % titlefont.family...[DONE]
    % titlefont.color...[DONE]

    %------ANNOTATION FIELDS-------%
    % x: ...[DONE]
    % y: ...[DONE]
    % xref: ...[DONE]
    % yref: ...[DONE]
    % text: ...[DONE]
    % showarrow: ...[HANDLED BY CALL TO ANNOTATION];
    % font: ...[DONE]
    % xanchor: ...[DONE]
    % yanchor: ...[DONE]
    % align: ...[DONE]
    % arrowhead: ...[HANDLED BY CALL FROM ANNOTATION];
    % arrowsize: ...[HANDLED BY CALL FROM ANNOTATION];
    % arrowwidth: ...[HANDLED BY CALL FROM ANNOTATION];
    % arrowcolor: ...[HANDLED BY CALL FROM ANNOTATION];
    % ax: ...[HANDLED BY CALL FROM ANNOTATION];
    % ay: ...[HANDLED BY CALL FROM ANNOTATION];
    % textangle: ...[DONE]
    % bordercolor: ...[DONE]
    % borderwidth: ...[DONE]
    % borderpad: ...[DONE]
    % bgcolor: ...[DONE]
    % opacity: ...[NOT SUPPORTED IN MATLAB]

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Text(anIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-STANDARDIZE UNITS-%
    textunits = get(obj.State.Text(anIndex).Handle, 'Units');
    fontunits = get(obj.State.Text(anIndex).Handle, 'FontUnits');
    set(obj.State.Text(anIndex).Handle, 'Units', "data");
    set(obj.State.Text(anIndex).Handle, 'FontUnits', "points");

    %-TEXT DATA STRUCTURE-%
    text_data = obj.State.Text(anIndex).Handle;

    annotation.showarrow = false;

    %-anchor title to paper-%
    if obj.State.Text(anIndex).Title
        annotation.xref = "paper";
        annotation.yref = "paper";
    else
        annotation.xref = sprintf("x%d", xsource);
        annotation.yref = sprintf("y%d", ysource);
    end

    annotation.xanchor = get(text_data, 'HorizontalAlignment');
    annotation.align = get(text_data, 'HorizontalAlignment');

    switch get(text_data, 'VerticalAlignment')
        case {"top", "cap"}
            annotation.yanchor = "top";
        case "middle"
            annotation.yanchor = "middle";
        case {"baseline","bottom"}
            annotation.yanchor = "bottom";
    end

    if obj.State.Text(anIndex).Title
        annotation.text = parseString( ...
                get(text_data, 'String'), get(text_data, 'Interpreter'));
        if isempty(get(text_data, 'String'))
            annotation.text = "<b></b>"; %empty string annotation
        else
            annotation.text = sprintf('<b>%s</b>', strjoin(cellstr(annotation.text), '<br>'));
        end
    else
        if ~strcmpi(obj.PlotOptions.TreatAs, "pie3")
            annotation.text = parseString( ...
                    get(text_data, 'String'), get(text_data, 'Interpreter'));
        else
            annotation.text = "<b></b>";
        end
    end

    %-optional code flow-%
    % if ~strcmpi(obj.PlotOptions.TreatAs, "pie3")
    %     annotation.text = parseString(text_data.String,text_data.Interpreter);
    %     if obj.State.Text(anIndex).Title && isempty(text_data.String)
    %         annotation.text = "<b></b>"; %empty string annotation
    %     end
    % else
    %     annotation.text = "<b></b>";
    % end

    if obj.State.Text(anIndex).Title
        %-AXIS DATA-%
        xaxis = obj.layout.(sprintf("xaxis%d", xsource));
        yaxis = obj.layout.(sprintf("yaxis%d", xsource));

        annotation.x = mean(xaxis.domain);
        annotation.y = (yaxis.domain(2) + obj.PlotlyDefaults.TitleHeight);
    else
        tmpPosition = get(text_data, 'Position');
        annotation.x = tmpPosition(1);
        annotation.y = tmpPosition(2);
    end

    col = round(255*get(text_data, 'Color'));
    annotation.font.color = getStringColor(col);

    annotation.font.family = matlab2plotlyfont(get(text_data, 'FontName'));

    annotation.font.size = get(text_data, 'FontSize');

    switch get(text_data, 'FontWeight')
        case {"bold","demi"}
            %-bold text-%
            annotation.text = sprintf('<b>%s</b>', annotation.text);
        otherwise
    end

    %-background color-%
    if ~ischar(get(text_data, 'BackgroundColor'))
        switch get(text_data, 'BackgroundColor')
            case "ne"
                annotation.bgcolor = "rgba(0,0,0,0)";
            otherwise
        end
    end

    if ~ischar(get(text_data, 'EdgeColor'))
        col = round(255*get(text_data, 'EdgeColora'));
        annotation.bordercolor = getStringColor(col);
    else
        %-none-%
        annotation.bordercolor = "rgba(0,0,0,0)";
    end

    %-text rotation (plotly CW positive, MATLAB CCW positive)-%
    rotation = get(text_data, 'Rotation');
    if rotation > 180
        rotation = rotation - 360;
    end
    parentAxis = obj.State.Text(anIndex).AssociatedAxis;
    if ~isempty(findall(parentAxis, "Type", "graphplot", "-depth", 1))
        rotation = -rotation;
    end
    annotation.textangle = rotation;

    annotation.borderwidth = get(text_data, 'LineWidth');
    annotation.borderpad = get(text_data, 'Margin');

    %-hide text (a workaround)
    if strcmp(get(text_data, 'Visible'),"off")
        annotation.text = " ";
    end

    %-REVERT UNITS-%
    set(obj.State.Text(anIndex).Handle, 'Units', textunits);
    set(obj.State.Text(anIndex).Handle, 'FontUnits', fontunits);
end

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
    textunits = obj.State.Text(anIndex).Handle.Units;
    fontunits = obj.State.Text(anIndex).Handle.FontUnits;
    obj.State.Text(anIndex).Handle.Units = "data";
    obj.State.Text(anIndex).Handle.FontUnits = "points";

    %-TEXT DATA STRUCTURE-%
    text_data = obj.State.Text(anIndex).Handle;

    annotation.showarrow = false;

    %-anchor title to paper-%
    if obj.State.Text(anIndex).Title
        annotation.xref = "paper";
        annotation.yref = "paper";
    else
        annotation.xref = "x" + xsource;
        annotation.yref = "y" + ysource;
    end

    annotation.xanchor = text_data.HorizontalAlignment;
    annotation.align = text_data.HorizontalAlignment;

    switch text_data.VerticalAlignment
        case {"top", "cap"}
            annotation.yanchor = "top";
        case "middle"
            annotation.yanchor = "middle";
        case {"baseline","bottom"}
            annotation.yanchor = "bottom";
    end

    if obj.State.Text(anIndex).Title
        annotation.text = parseString( ...
                text_data.String,text_data.Interpreter);
        if isempty(text_data.String)
            annotation.text = "<b></b>"; %empty string annotation
        else
            annotation.text = "<b>" + join( ...
                    string(annotation.text), "<br>") + "</b>";
        end
    else
        if ~strcmpi(obj.PlotOptions.TreatAs, "pie3")
            annotation.text = parseString( ...
                    text_data.String,text_data.Interpreter);
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
        xaxis = obj.layout.("xaxis" + xsource);
        yaxis = obj.layout.("yaxis" + xsource);

        annotation.x = mean(xaxis.domain);
        annotation.y = (yaxis.domain(2) + obj.PlotlyDefaults.TitleHeight);
    else
        annotation.x = text_data.Position(1);
        annotation.y = text_data.Position(2);
    end

    col = round(255*text_data.Color);
    annotation.font.color = getStringColor(col);

    annotation.font.family = matlab2plotlyfont(text_data.FontName);

    annotation.font.size = text_data.FontSize;

    switch text_data.FontWeight
        case {"bold","demi"}
            %-bold text-%
            annotation.text = "<b>" + annotation.text + "</b>";
        otherwise
    end

    %-background color-%
    if ~ischar(text_data.BackgroundColor)
        switch text_data.BackgroundColor
            case "ne"
                annotation.bgcolor = "rgba(0,0,0,0)";
            otherwise
        end
    end

    if ~ischar(text_data.EdgeColor)
        col = round(255*text_data.EdgeColora);
        annotation.bordercolor = getStringColor(col);
    else
        %-none-%
        annotation.bordercolor = "rgba(0,0,0,0)";
    end

    annotation.textangle = text_data.Rotation;
    if text_data.Rotation > 180
        annotation.textangle = text_data.Rotation - 360;
    end

    annotation.borderwidth = text_data.LineWidth;
    annotation.borderpad = text_data.Margin;

    %-hide text (a workaround)
    if strcmp(text_data.Visible,"off")
        annotation.text = " ";
    end

    %-REVERT UNITS-%
    obj.State.Text(anIndex).Handle.Units = textunits;
    obj.State.Text(anIndex).Handle.FontUnits = fontunits;
end

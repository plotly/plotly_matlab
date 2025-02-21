function obj = updateHeatmapAnnotation(obj,anIndex)
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
    nanns = length(obj.layout.annotations);
    axIndex = nanns + obj.getAxisIndex(obj.State.Text(anIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,anIndex);

    %-get heatmap title name-%
    title_name = obj.State.Text(anIndex).Handle;

    obj.layout.annotations{axIndex}.showarrow = false;

    %-anchor title to paper-%
    if obj.State.Text(anIndex).Title
        obj.layout.annotations{axIndex}.xref = "paper";
        obj.layout.annotations{axIndex}.yref = "paper";
    else
        obj.layout.annotations{axIndex}.xref = "x" + xsource;
        obj.layout.annotations{axIndex}.yref = "y" + ysource;
    end

    obj.layout.annotations{axIndex}.xanchor = "middle";
    obj.layout.annotations{axIndex}.align = "middle";
    obj.layout.annotations{axIndex}.yanchor = "top";
    obj.layout.annotations{axIndex}.text = sprintf("<b>%s</b>", title_name);
    obj.layout.annotations{axIndex}.font.size = 14;

    if obj.State.Text(anIndex).Title
        %-AXIS DATA-%
        xaxis = obj.layout.("xaxis" + xsource);
        yaxis = obj.layout.("yaxis" + ysource);

        obj.layout.annotations{axIndex}.x = mean(xaxis.domain);
        obj.layout.annotations{axIndex}.y = (yaxis.domain(2) + 0.04);
    else
        obj.layout.annotations{axIndex}.x = text_data.Position(1);
        obj.layout.annotations{axIndex}.y = text_data.Position(2);
    end
end

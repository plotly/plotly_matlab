function ann = getHeatmapTitleAnnotation(obj,anIndex)
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

    [xsource, ysource] = findSourceAxis(obj,anIndex);

    title_name = obj.State.Text(anIndex).Handle;
    ann.showarrow = false;

    %-anchor title to paper-%
    if obj.State.Text(anIndex).Title
        ann.xref = "paper";
        ann.yref = "paper";
    else
        ann.xref = "x" + xsource;
        ann.yref = "y" + ysource;
    end

    ann.xanchor = "middle";
    ann.align = "middle";
    ann.yanchor = "top";
    ann.text = sprintf("<b>%s</b>", title_name);
    ann.font.size = 14;

    if obj.State.Text(anIndex).Title
        %-AXIS DATA-%
        xaxis = obj.layout.("xaxis" + xsource);
        yaxis = obj.layout.("yaxis" + ysource);

        ann.x = mean(xaxis.domain);
        ann.y = (yaxis.domain(2) + 0.04);
    else
        ann.x = text_data.Position(1);
        ann.y = text_data.Position(2);
    end
end

function obj = updateTiledLayoutAnnotation(obj, tiledLayoutData)
    %-INITIALIZATIONS-%
    anIndex = obj.State.Figure.NumTexts + 1;
    titleStruct = tiledLayoutData.Title;

    obj.layout.annotations{anIndex}.showarrow = false;
    obj.layout.annotations{anIndex}.xref = 'paper';
    obj.layout.annotations{anIndex}.yref = 'paper';
    obj.layout.annotations{anIndex}.align = titleStruct.HorizontalAlignment;

    %-anchors-%
    obj.layout.annotations{anIndex}.xanchor = titleStruct.HorizontalAlignment;

    switch titleStruct.VerticalAlignment
        case {'top', 'cap'}
            obj.layout.annotations{anIndex}.yanchor = 'top';
        case 'middle'
            obj.layout.annotations{anIndex}.yanchor = 'middle';
        case {'baseline','bottom'}
            obj.layout.annotations{anIndex}.yanchor = 'bottom';
    end

    %-text-%
    titleString = titleStruct.String;
    titleInterpreter = titleStruct.Interpreter;

    if isempty(titleString)
        titleTex = titleString;
    else
        titleTex = parseString(titleString, titleInterpreter);
    end

    obj.layout.annotations{anIndex}.text = titleTex;

    %-text location-%
    obj.layout.annotations{anIndex}.x = 0.5;
    obj.layout.annotations{anIndex}.y = 0.95;

    %-font properties-%
    titleColor = getStringColor(round(255*titleStruct.Color));
    titleSize = titleStruct.FontSize;
    titleFamily = matlab2plotlyfont(titleStruct.FontName);

    obj.layout.annotations{anIndex}.font.color = titleColor;
    obj.layout.annotations{anIndex}.font.size = 1.2*titleSize;
    obj.layout.annotations{anIndex}.font.family = titleFamily;

    switch titleStruct.FontWeight
        case {'bold','demi'}
            titleString = sprintf('<b>%s</b>', titleString);
            obj.layout.annotations{anIndex}.text = titleString;
        otherwise
    end

    %-title angle-%
    textAngle = titleStruct.Rotation;
    if textAngle > 180
        textAngle = textAngle - 360;
    end
    obj.layout.annotations{anIndex}.textangle = textAngle;

    %-hide text (a workaround)-%
    if strcmp(titleStruct.Visible,'off')
        obj.layout.annotations{anIndex}.text = ' ';
    end
end

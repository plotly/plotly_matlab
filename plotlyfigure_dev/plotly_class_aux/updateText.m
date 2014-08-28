function obj = updateText(obj,src,event,prop)
% x: ............[TODO]
% y: ............[TODO]
% xref: ............[TODO]
% yref: ............[TODO]
% text: ...[DONE]
% showarrow: ............[TODO]
% font: ...[DONE]
% xanchor: ............[TODO]
% yanchor: ............[TODO]
% align: ............[TODO]
% arrowhead: ............[TODO]
% arrowsize: ............[TODO]
% arrowwidth: ............[TODO]
% arrowcolor: ............[TODO]
% ax: ............[TODO]
% ay: ............[TODO]
% textangle: ............[TODO]
% bordercolor: ...[DONE]
% borderwidth: ............[TODO]
% borderpad: ............[TODO]
% bgcolor: ...[DONE]
% opacity: ............[TODO]


%-AXIS STRUCTURE-%
text_data = get(event.AffectedObject);

%-STANDARDIZE UNITS-%
axisunits = text_data.Units;
fontunits = text_data.FontUnits;
set(event.AffectedObject,'Units','normalized');
set(event.AffectedObject,'FontUnits','points');

%-AXIS TITLE-%
if eq(event.AffectedObject,get(obj.State.Axis.Handle,'Title')) && (obj.State.Figure.NumAxes == 1)
    
    switch prop
        case {'String','Interpreter'}
            %-title-%
            if ~isempty(text_data.String)
                obj.layout.title = parseString(text_data.String,text_data.Interpreter);
            else
                obj.layout.title = 'untitled'; 
            end
        case 'Color'
            %-title font color-%
            col = 255*text_data.Color;
            obj.layout.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        case 'FontSize'
            %-title font size-%
            obj.layout.titlefont.size = text_data.FontSize;
        case 'FontName'
            %-title font family-%
            obj.layout.titlefont.family = matlab2plotlyfont(text_data.FontName);
    end
    
    %-AXIS XLABEL-%
elseif eq(event.AffectedObject,get(obj.State.Axis.Handle,'XLabel'))
    
    switch prop
        case {'String','Interpreter'}
            %-title-%
            if ~isempty(text_data.String)
                obj.layout.title = parseString(text_data.String,text_data.Interpreter);
            end
        case 'Color'
            %-title font color-%
            col = 255*text_data.Color;
            obj.layout.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        case 'FontSize'
            %-title font size-%
            obj.layout.titlefont.size = text_data.FontSize;
        case 'FontName'
            %-title font family-%
            obj.layout.titlefont.family = matlab2plotlyfont(text_data.FontName);
    end
    
    %-AXIS YLABEL-%
elseif eq(event.AffectedObject,get(obj.State.Axis.Handle,'YLabel'))
    
    switch prop
        case {'String','Interpreter'}
            %-title-%
            if ~isempty(text_data.String)
                obj.layout.title = parseString(text_data.String,text_data.Interpreter);
            end
        case 'Color'
            %-title font color-%
            col = 255*text_data.Color;
            obj.layout.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        case 'FontSize'
            %-title font size-%
            obj.layout.titlefont.size = text_data.FontSize;
        case 'FontName'
            %-title font family-%
            obj.layout.titlefont.family = matlab2plotlyfont(text_data.FontName);
    end
    
    %-AXIS ZLABEL-%
elseif eq(event.AffectedObject,get(obj.State.Axis.Handle,'ZLabel'))
    
    switch prop
        case {'String','Interpreter'}
            %-title-%
            if ~isempty(text_data.String)
                obj.layout.title = parseString(text_data.String,text_data.Interpreter);
            end
        case 'Color'
            %-title font color-%
            col = 255*text_data.Color;
            obj.layout.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        case 'FontSize'
            %-title font size-%
            obj.layout.titlefont.size = text_data.FontSize;
        case 'FontName'
            %-title font family-%
            obj.layout.titlefont.family = matlab2plotlyfont(text_data.FontName);
    end
    
    %-ANNOTATION-%
else
    %-UPDATE TEXT HANDLE-%
    obj.State.Text.Handle = event.AffectedObject;
    
    if ~isempty(get(obj.State.Text.Handle,'String'))
        
        %-CURRENT ANNOTATION INDEX-%
        anIndex = obj.getCurrentAnnotationIndex;
        
        switch prop
            case 'String'
                obj.layout.annotations{anIndex}.text = text_data.String;
            case 'Color'
                col = 255*text_data.Color;
                obj.layout.annotations{anIndex}.font.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
            case 'FontName'
                obj.layout.annotations{anIndex}.font.family = matlab2plotlyfont(text_data.FontName);
            case 'FontSize'
                obj.layout.annotations{anIndex}.font.size = text_data.FontSize;
            case 'BackgroundColor'
                switch text_data.BackgroundColor
                    case 'none'
                        obj.layout.annotations{anIndex}.bgcolor = 'rgba(0,0,0,0)';
                    otherwise
                        col = 255*text_data.BackgroundColor;
                        obj.layout.annotations{anIndex}.bgcolor =  ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                end
            case 'EdgeColor'
                switch text_data.EdgeColor
                    case 'none'
                        obj.layout.annotations{anIndex}.bordercolor = 'rgba(0,0,0,0)';
                    otherwise
                        col = 255*text_data.EdgeColor;
                        obj.layout.annotations{anIndex}.bordercolor =  ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                end
            case 'FontWeight'
                switch text_data.FontWeight
                    case {'bold','demi'}
                        obj.layout.annotations{anIndex}.text = ['<b>' text_data.String '<b>'];
                    otherwise
                end
            case 'Extent'
                obj.layout.annotations{anIndex}.x = text_data.Extent(1);
                obj.layout.annotations{anIndex}.y = text_data.Extent(2);
            case 'Horizontal Alignment'
            case 'HandleVisibility'
                %             %-delete hidden handles (for now)-%
                %             if strcmp(text_data.HandleVisibility,'off')
                %                 delete(event.AffectedObject);
                %             end
            case 'Interpreter'
            case 'LineStyle'
            case 'LineWidth'
            case 'Margin'
            case 'Position'
            case 'Visible'
        end
    end
end

%-REVERT UNITS-%
set(obj.State.Text.Handle,'Units',axisunits);
set(obj.State.Text.Handle,'FontUnits',fontunits);

end

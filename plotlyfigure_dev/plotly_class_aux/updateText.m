function obj = updateText(obj,src,event,prop)
% x: ............[TODO]
% y: ............[TODO]
% xref: ............[TODO]
% yref: ............[TODO]
% text: ............[TODO]
% showarrow: ............[TODO]
% font: ............[TODO]
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

%-UPDATE TEXT HANDLE-%
obj.State.Text.Handle = event.AffectedObject;

%-AXIS STRUCTURE-%
text_data = get(obj.State.Text.Handle);

%-CURRENT ANNOTATION INDEX-%
anIndex = obj.getCurrentAnnotationIndex; 

%-STANDARDIZE UNITS-%
axisunits = text_data.Units;
fontunits = text_data.FontUnits;
set(obj.State.Text.Handle,'Units','normalized');
set(obj.State.Text.Handle,'FontUnits','points');

switch prop
    case 'String'
        obj.layout.annotations{anIndex} = text_data.String;
    case 'Color'
        col = 255*text_data.Color;
        obj.layout.annotations{anIndex}.font.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']; 
    case 'FontName'
        obj.layout.annotations{anIndex}.font.family = matlab2plotlyfont(text_data.FontName); 
    case 'FontSize'
        obj.layout.annotations{anIndex}.font.size = text_data.FontSize; 
    case 'BackgroundColor'
        col = 255*text_data.BackgroundColor;
        obj.layout.annotations{anIndex}.bgcolor =  ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];  
    case 'EdgeColor'
        col = 255*text_data.EdgeColor;
        obj.layout.annotations{anIndex}.borderColor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];  
    case 'Horizontal Alignment'
    case 'Interpreter'
    case 'LineStyle'
    case 'LineWidth'
    case 'Margin'
    case 'Position'
    case 'Visible'     
end

%-REVERT UNITS-%
set(obj.State.Text.Handle,'Units',axisunits);
set(obj.State.Text.Handle,'FontUnits',fontunits);

end

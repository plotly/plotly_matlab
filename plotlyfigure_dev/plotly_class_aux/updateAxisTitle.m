function obj = updateAxisTitle(obj,~,event,prop)
%title ...[DONE]
%family..........[TODO]
%size..........[TODO]
%color..........[TODO]
%outlinecolor..........[TODO]

%-GET TITLE HANDLE-%
titleHandle = event.AffectedObject;

%-AXIS STRUCTURE-%
title_data = get(titleHandle);

%-STANDARDIZE UNITS-%
titleunits = title_data.Units;
fontunits = title_data.FontUnits;
set(titleHandle,'Units','normalized');
set(titleHandle,'FontUnits','points');

switch prop
    case {'String','Interpreter'}
        %-title-%
        if ~isempty(title_data.String)
            obj.layout.title = parseString(title_data.String,title_data.Interpreter);
        end
    case 'Color'
        %-title font color-%
        col = 255*title_data.Color;
        obj.layout.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    case 'FontSize'
        %-title font size-%
        obj.layout.titlefont.size = title_data.FontSize;
    case 'FontName'
        %-title font family-%
        obj.layout.titlefont.family = matlab2plotlyfont(title_data.FontName);
end

%-REVERT UNITS-%
set(titleHandle,'Units',titleunits);
set(titleHandle,'FontUnits',fontunits);
end


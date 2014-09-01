function obj = updateText(obj, src, event, varargin)

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

%-TEXT FIELD-%
prop = varargin{1};
tag = varargin{2};

% update axis handle
obj.State.Axis.Handle = event.AffectedObject.Parent;

%-STANDARDIZE UNITS-%
textunits = event.AffectedObject.Units;
fontunits = event.AffectedObject.FontUnits;
set(event.AffectedObject,'Units','data');
set(event.AffectedObject,'FontUnits','points');

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(obj.getCurrentAxisIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(obj.getCurrentAxisIndex) ';']);

%-TEXT STRUCTURE-%
text_data = event.AffectedObject;

switch tag
    
    %-AXIS XLABEL-%
    case 'XLabel'
        
        %-CONVERT TO PLOTLY AXIS NOTATION-%
        if isfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)])
            xaxis = getfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)]);
        end
        
        switch prop
            case {'String','Interpreter'}
                %-title-%
                if ~isempty(text_data.String)
                    xaxis.title = parseString(text_data.String,text_data.Interpreter);
                end
            case 'Color'
                %-title font color-%
                col = 255*text_data.Color;
                xaxis.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
            case 'FontSize'
                %-title font size-%
                xaxis.titlefont.size = text_data.FontSize;
            case 'FontName'
                %-title font family-%
                xaxis.titlefont.family = matlab2plotlyfont(text_data.FontName);
        end
        
        %set axis
        obj.layout = setfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)],xaxis);
        
        %-AXIS YLABEL-%
    case 'YLabel'
        
        %-CONVERT TO PLOTLY AXIS NOTATION-%
        if isfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)])
            yaxis = getfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)]);
        end
        
        switch prop
            case {'String','Interpreter'}
                %-title-%
                if ~isempty(text_data.String)
                    yaxis.title = parseString(text_data.String,text_data.Interpreter);
                end
            case 'Color'
                %-title font color-%
                col = 255*text_data.Color;
                yaxis.titlefont.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
            case 'FontSize'
                %-title font size-%
                yaxis.titlefont.size = text_data.FontSize;
            case 'FontName'
                %-title font family-%
                yaxis.titlefont.family = matlab2plotlyfont(text_data.FontName);
        end
        
        %set axis
        obj.layout = setfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)],yaxis);
        
        %-AXIS ZLABEL-%
    case 'ZLabel'
        
        %TO COME - DO NOTHING (FOR NOW)
        
        %-TITLE/GENERIC gANNOTATION SANS ARROW-%
    case {'Title','Annotation'}
        
        %-UPDATE TEXT HANDLE-%
        obj.State.Text.Handle = event.AffectedObject;
        
        %-CURRENT ANNOTATION INDEX-%
        anIndex = obj.getCurrentAnnotationIndex;
        
        %-MATLAB-PLOTLY DEFAULTS-%
        
        %-hide arrow-%
        obj.layout.annotations{anIndex}.showarrow = false;
        
        %-anchor title to paper-%
        if strcmp(tag,'Title')
            %-xref-%
            obj.layout.annotations{anIndex}.xref = 'paper';
            %-yref-%
            obj.layout.annotations{anIndex}.yref = 'paper';
        else
            %-xref-%
            obj.layout.annotations{anIndex}.xref = ['x' num2str(obj.getCurrentAxisIndex)];
            %-yref-%
            obj.layout.annotations{anIndex}.yref = ['y' num2str(obj.getCurrentAxisIndex)];
        end
        
        switch prop
            case 'String'
                %-text-%
                obj.layout.annotations{anIndex}.text = parseString(text_data.String,text_data.Interpreter);
                if strcmp(tag,'Title') && isempty(text_data.String)
                    obj.layout.annotations{anIndex}.text = '<b></b>'; %empty string annotation workaround 
                end
            case 'Color'
                %-font color-%
                col = 255*text_data.Color;
                obj.layout.annotations{anIndex}.font.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
            case 'FontName'
                %-font family-%
                obj.layout.annotations{anIndex}.font.family = matlab2plotlyfont(text_data.FontName);
            case 'FontSize'
                %-font size-%
                obj.layout.annotations{anIndex}.font.size = text_data.FontSize;
            case 'BackgroundColor'
                %-background color-%
                if ~ischar(text_data.BackgroundColor)
                    switch text_data.BackgroundColor
                        
                        case 'ne'
                            obj.layout.annotations{anIndex}.bgcolor = 'rgba(0,0,0,0)';
                        otherwise
                            
                    end
                end
            case 'EdgeColor'
                %-border color-%
                if ~ischar(text_data.EdgeColor)
                    col = 255*text_data.EdgeColora;
                    obj.layout.annotations{anIndex}.bordercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                else
                    %-none-%
                    obj.layout.annotations{anIndex}.bordercolor = 'rgba(0,0,0,0)';
                end
            case 'FontWeight'
                switch text_data.FontWeight
                    case {'bold','demi'}
                        %-bold text-%
                        obj.layout.annotations{anIndex}.text = ['<b>' text_data.String '</b>'];
                    otherwise
                end
            case 'HorizontalAlignment'
                %-xanchor-%
                obj.layout.annotations{anIndex}.xanchor = text_data.HorizontalAlignment;
                %-align-%
                obj.layout.annotations{anIndex}.align = text_data.HorizontalAlignment; 
            case 'VerticalAlignment'
                switch text_data.VerticalAlignment
                    %-yanchor-%
                    case {'top', 'cap'}
                        obj.layout.annotations{anIndex}.yanchor = 'top';
                    case 'middle'
                        obj.layout.annotations{anIndex}.yanchor = 'middle';
                    case {'baseline','bottom'}
                        obj.layout.annotations{anIndex}.yanchor = 'bottom';
                end
            case 'Rotation'
                %-textangle-%
                obj.layout.annotations{anIndex}.textangle = text_data.Rotation;
                if text_data.Rotation > 180
                    obj.layout.annotations{anIndex}.textangle = text_data.Rotation - 360;
                end
            case 'LineWidth'
                %-borderpad-%
                obj.layout.annotations{anIndex}.borderwidth = text_data.LineWidth;
            case 'Margin'
                %-borderpad-%
                obj.layout.annotations{anIndex}.borderpad = text_data.Margin;
            case 'Position'
                if strcmp(tag,'Title')
                    %-x position-%
                    obj.layout.annotations{anIndex}.x = mean(xaxis.domain);
                    %-y position-%
                    obj.layout.annotations{anIndex}.y = (yaxis.domain(2) + obj.PlotlyDefaults.TitleHeight);
                else
                    %-x position-%
                    obj.layout.annotations{anIndex}.x = text_data.Position(1);
                    %-y position-%
                    obj.layout.annotations{anIndex}.y = text_data.Position(2);
                end
            case 'Visible'
                %hide text (a workaround)
                if strcmp(text_data.Visible,'off')
                    obj.layout.annotations{anIndex}.text = ' ';
                else
                    obj.layout.annotations{anIndex}.text = obj.layout.annotations{anIndex}.text;
                end
        end
        
end

%-REVERT UNITS-%
set(event.AffectedObject,'Units',textunits);
set(event.AffectedObject,'FontUnits',fontunits);

end

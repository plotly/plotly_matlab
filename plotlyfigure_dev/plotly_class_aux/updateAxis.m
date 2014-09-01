%----UPDATE AXIS DATA/LAYOUT----%
function obj = updateAxis(obj,~,event,prop)
% title: ...[DONE]
% titlefont:...[DONE]
% range:...[DONE]
% domain:...[DONE]
% type:...[DONE]
% rangemode:...[NOT HANDLED IN MATLAB]
% autorange:...[DONE]
% showgrid:...[DONE]
% zeroline:...[DONE]
% showline:...[DONE]
% autotick:...[DONE]
% nticks:...[DONE]
% ticks:...[DONE]
% showticklabels:...[DONE]
% tick0:...[DONE]
% dtick:...[DONE]
% ticklen:...[DONE]
% tickwidth:...[DONE]
% tickcolor:...[DONE]
% tickangle:...[NOT SUPPORTED IN MATLAB]
% tickfont:...[DONE]
% tickfont.family...[DONE]
% tickfont.size...[DONE]
% tickfont.color...[DONE]
% tickfont.outlinecolor...[NOT SUPPORTED IN MATLAB]
% exponentformat:.................[TODO]
% showexponent:...[NOT SUPPORTED IN MATLAB]
% mirror:...[DONE]
% gridcolor:...[DONE]
% gridwidth:...[DONE]
% zerolinecolor:...[NOT SUPPORTED IN MATLAB]
% zerolinewidth:...[NOT SUPPORTED IN MATLAB]
% linecolor:...[DONE]
% linewidth:...[DONE]
% anchor:...[DONE]
% overlaying:...[NOT SUPPORTED IN MATLAB]
% side:...[DONE]
% position:...[DONE]

%-UPDATE AXIS HANDLE-%
obj.State.Axis.Handle = event.AffectedObject;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strip = obj.PlotOptions.Strip;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-CONVERT TO PLOTLY AXIS NOTATION-%
if isfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)])
    xaxis = getfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)]);
else
    xaxis.anchor = ['y' num2str(obj.getCurrentAxisIndex)];
end

if isfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)])
    yaxis = getfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)]);
else
    yaxis.anchor = ['x' num2str(obj.getCurrentAxisIndex)];
end

%-STANDARDIZE UNITS-%
axisunits = event.AffectedObject.Units;
fontunits = event.AffectedObject.FontUnits;
set(event.AffectedObject,'Units','normalized');
set(event.AffectedObject,'FontUnits','points');

%-AXIS STRUCTURE-%
axis_data = event.AffectedObject;

switch prop
    
    case 'Box'
        
        switch axis_data.Box
            case 'on'
                %-xaxis mirror-%
                xaxis.mirror = true;
                %-yaxis mirror-%
                yaxis.mirror = true;
                
            case 'off'
                xaxis.mirror = false;
                yaxis.mirror = false;
        end
        
    case 'FontSize'
        
        %-xaxis tick font size-%
        xaxis.tickfont.size = axis_data.FontSize;
        
        %-yaxis tick font size-%
        yaxis.tickfont.size = axis_data.FontSize;
        
    case 'FontName'
        
        %-xaxis tick font family-%
        xaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);
        
        %-yaxis tick font family-%
        yaxis.tickfont.family = matlab2plotlyfont(axis_data.FontName);
        
    case 'Position'
        
        if ~strip
            %-margin-%
            templ = axis_data.Position(1)*obj.layout.width;
            obj.layout.margin.l = min(obj.layout.margin.l,templ);
            obj.layout.margin.r = obj.layout.margin.l;
            tempb = axis_data.Position(2)*obj.layout.height;
            obj.layout.margin.b = min(obj.layout.margin.b,tempb);
            tempt = obj.layout.height - (axis_data.Position(2) + axis_data.Position(4))*obj.layout.height;
            obj.layout.margin.t = max(obj.PlotlyDefaults.MinTitleMargin,min(obj.layout.margin.t,tempt));
        end
        
        %assumes units are normalized (we force this)
        xaxis.domain = min([axis_data.Position(1) axis_data.Position(1)+axis_data.Position(3)],1);
        yaxis.domain = min([axis_data.Position(2) axis_data.Position(2)+axis_data.Position(4)],1);
        
    case 'XAxisLocation'
        
        %-xaxis-side-%
        xaxis.side = axis_data.XAxisLocation;
        
    case 'YAxisLocation'
        
        %-yaxis-side-%
        yaxis.side = axis_data.YAxisLocation;
        
    case 'TickDir'
        
        %-xaxis tick font size-%
        switch axis_data.TickDir
            case 'in'
                xaxis.ticks = 'inside';
                yaxis.ticks = 'inside';
            case 'out'
                xaxis.ticks = 'outside';
                yaxis.ticks = 'outside';
        end
        
    case 'TickLength'
        
        ticklength = min(obj.PlotlyDefaults.MaxTickLength,...
            max(axis_data.TickLength(1)*axis_data.Position(3)*obj.layout.width,...
            axis_data.TickLength(1)*axis_data.Position(4)*obj.layout.height));
        %-xaxis ticklen-%
        xaxis.ticklen = ticklength;
        %-yaxis ticklen-%
        yaxis.ticklen = ticklength;
        
    case 'XColor'
        
        col = 255*axis_data.XColor;
        xaxiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
        %-xaxis linecolor-%
        xaxis.linecolor = xaxiscol;
        %-xaxis tickcolor-%
        xaxis.tickcolor = xaxiscol;
        %-xaxis tickfont-%
        xaxis.tickfont.color = xaxiscol;
        %-xaxis grid color-%
        xaxis.gridcolor = xaxiscol;
        
    case 'YColor'
        
        col = 255*axis_data.XColor;
        yaxiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
        %-yaxis linecolor-%
        yaxis.linecolor = yaxiscol;
        %-yaxis tickcolor-%
        yaxis.tickcolor = yaxiscol;
        %-yaxis tickfont-%
        yaxis.tickfont.color = yaxiscol;
        %-yaxis grid color-%
        yaxis.gridcolor = yaxiscol;
        
    case 'Visible'
        
        if strcmp(axis_data.Visible,'on')
            %-xaxis showline-%
            xaxis.showline = true;
            %-xaxis showticklabels-%
            xaxis.showticklabels = true;
            %-yaxis showline-%
            yaxis.showline = true;
            %-yaxis showticklabels-%
            yaxis.showticklabels = true;
        else
            %-xaxis showline-%
            xaxis.showline = false;
            %-xaxis showticklabels-%
            xaxis.showticklabels = false;
            %-yaxis showline-%
            yaxis.showline = false;
            %-yaxis showticklabels-%
            yaxis.showticklabels = false;
        end
        
    case {'XGrid', 'XMinorGrid'}
        
        if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
            %-xaxis show grid-%
            xaxis.showgrid = true;
        else
            xaxis.showgrid = false;
        end
        
    case {'YGrid', 'YMinorGrid'}
        
        if strcmp(axis_data.YGrid,'on') || strcmp(axis_data.YMinorGrid,'on')
            %yaxis show grid-%
            yaxis.showgrid = true;
        else
            yaxis.showgrid = false;
        end
        
    case 'LineWidth'
        %-xaxis line width-%
        xaxis.linewidth = axis_data.LineWidth; 
        %-yaxis line width-%
        yaxis.linewidth = axis_data.LineWidth;
        %-xaxis tick width-%
        xaxis.tickwidth = axis_data.LineWidth;
        %-yaxis tick width-%
        yaxis.tickwidth = axis_data.LineWidth;
        %-xaxis grid width-%
        xaxis.gridwidth = axis_data.LineWidth;
        %-yaxis grid width-%
        yaxis.gridwidth = axis_data.LineWidth;
        
    case 'Title'
        
        %text handle
        obj.State.Text.Handle = axis_data.Title;
        %update the text index
        obj.State.Figure.NumTexts = obj.State.Figure.NumTexts + 1;
        %update the HandleIndexMap
        obj.State.Text.HandleIndexMap{obj.State.Figure.NumTexts} = obj.State.Text.Handle;
        %add to titles list
        obj.State.Text.Titles{obj.State.Figure.NumTexts} = obj.State.Text.Handle;
        % add axis title listener
        for n = 1:length(obj.State.Text.ListenFields)
            obj.State.Text.Listeners{obj.getCurrentAnnotationIndex,n} = addlistener(axis_data.Title,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'Title'));
            textlist = addlistener(axis_data.Title,obj.State.Text.ListenFields{n},'PostGet',@(src,event,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'Title'));
            %notify the listener
            get(axis_data.Title,obj.State.Text.ListenFields{n});
            %delete the listener
            delete(textlist);
        end
        
    case 'XLabel'
        
        % add axis XLabel listener
        for n = 1:length(obj.State.Text.ListenFields)
            addlistener(axis_data.XLabel,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'XLabel'));
            textlist = addlistener(axis_data.XLabel,obj.State.Text.ListenFields{n},'PostGet',@(src,event,prop,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'XLabel'));
            %notify the listener
            get(axis_data.XLabel,obj.State.Text.ListenFields{n});
            %delete the listener
            delete(textlist);
        end
        
    case 'YLabel'
        
        % add axis XLabel listener
        for n = 1:length(obj.State.Text.ListenFields)
            addlistener(axis_data.YLabel,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'YLabel'));
            textlist = addlistener(axis_data.YLabel,obj.State.Text.ListenFields{n},'PostGet',@(src,event,prop,tag)updateText(obj,src,event,obj.State.Text.ListenFields{n},'YLabel'));
            %notify the listener
            get(axis_data.XLabel,obj.State.Text.ListenFields{n});
            %delete the listener
            delete(textlist);
        end
        
    case{'XLim','XDir','XScale','XTick', 'XTickLabel', 'XTickLabelMode'}
        
        %-xaxis type-%
        xaxis.type = axis_data.XScale;
        
        %-xaxis show tick labels-%
        xaxis.showticklabels = true;
        
        %-xaxis showtick labels / ticks-%
        if isempty(axis_data.XTick)
           
            %-xaxis ticks-%
            xaxis.ticks = '';
            xaxis.showticklabels = false;
       
        else
            
            if strcmp(xaxis.type,'log')
                
                %-xaxis range-%
                xaxis.range = log10(axis_data.XLim);
                %-xaxis autotick-%
                xaxis.autotick = true;
                %-xaxis nticks-%
                xaxis.nticks = length(axis_data.XTick);
                
            elseif strcmp(xaxis.type,'linear')
                
                %-xaxis range-%
                xaxis.range = axis_data.XLim;
                
                if strcmp(axis_data.XTickLabelMode,'auto')
                    %-xaxis tick0-%
                    xaxis.tick0 = axis_data.XTick(1);
                    %-xaxis dtick-%
                    xaxis.dtick = axis_data.XTick(2)-axis_data.Xtick(1);
                    %-xaxis autotick-%
                    xaxis.autotick = false;
                else
                    %-xaxis show tick labels-%
                    if isempty(axis_data.XTickLabel)
                        xaxis.showticklabels = false;
                    else
                        try datenum(axis_data.XTickLabel(1,:));
                            %-xaxis type date-%
                            xaxis.type = 'date';
                            %-range (overwrite)-%
                            xaxis.range = [convertDate(datenum(axis_data.XTickLabel(1,:))) convertDate(datenum(axis_data.XTickLabel(end,:)))];
                            %-xaxis autotick-%
                            xaxis.autotick = true;
                            %-xaxis numticks-%
                            xaxis.nticks = length(axis_data.XTick);
                        catch
                            %-xaxis tick0-%
                            xaxis.tick0 = str2double(axis_data.XTickLabel(1));
                            %-xaxis dtick-%
                            xaxis.dtick = str2double(axis_data.XTickLabel(2))-num2str(axis_data.XtickLabel(1));
                            %-xaxis autotick-%
                            xaxis.autotick = false;
                        end
                    end
                end
            end
        end
        
        if strcmp(axis_data.XDir,'reverse')
            xaxis.range = [xaxis.range(2) xaxis.range(1)];
        end
        
        
    case{'YLim','YDir','YScale','YTick', 'YTickLabel', 'YTickLabelMode'}
        
    %-yaxis type-%
        yaxis.type = axis_data.YScale;
        
        %-yaxis range-%
        yaxis.range = axis_data.YLim;
        
        %-yaxis show tick labels-%
        yaxis.showticklabels = true;
        
        %-yaxis showtick labels / ticks-%
        if isempty(axis_data.YTick)
            
            %-yaxis ticks-%
            yaxis.ticks = '';
            yaxis.showticklabels = false;
       
        else
            
            if strcmp(yaxis.type,'log')
                
                %-yaxis autotick-%
                yaxis.autotick = true;
                %-yaxis nticks-%
                yaxis.nticks = length(axis_data.YTick);
                
            elseif strcmp(yaxis.type,'linear')
                
                if strcmp(axis_data.YTickLabelMode,'auto')
                    %-yaxis tick0-%
                    yaxis.tick0 = axis_data.YTick(1);
                    %-yaxis dtick-%
                    yaxis.dtick = axis_data.YTick(2)-axis_data.YTick(1);
                    %-yaxis autotick-%
                    yaxis.autotick = false;
                else
                    %-yaxis show tick labels-%
                    if isempty(axis_data.YTickLabel)
                        yaxis.showticklabels = false;
                    else
                        try datenum(axis_data.YTickLabel(1,:));
                            %-yaxis type date-%
                            yaxis.type = 'date';
                            %-range (overwrite)-%
                            yaxis.range = [convertDate(datenum(axis_data.YTickLabel(1,:))) convertDate(datenum(axis_data.YTickLabel(end,:)))];
                            %-yaxis autotick-%
                            yaxis.autotick = true;
                            %-yaxis numticks-%
                            yaxis.nticks = length(axis_data.YTick);
                        catch
                            %-yaxis tick0-%
                            yaxis.tick0 = str2double(axis_data.YTickLabel(1));
                            %-yaxis dtick-%
                            yaxis.dtick = str2double(axis_data.YTickLabel(2))-num2str(axis_data.YTickLabel(1));
                            %-yaxis autotick-%
                            yaxis.autotick = false;
                        end
                    end
                end
            end
        end
        
        if strcmp(axis_data.YDir,'reverse')
            yaxis.range = [yaxis.range(2) yaxis.range(1)];
        end
        
        
end

%-MATLAB-PLOTLY DEFAULTS-%

%-xaxis zeroline-%
xaxis.zeroline = false;

%-yaxis zeroline-%
yaxis.zeroline = false;

%-exponent format-%
xaxis.exponentformat = 'none';
yaxis.exponentformat = 'none';

%SET AXES USING PLOTLY SYNTAX
obj.layout = setfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)],xaxis);
obj.layout = setfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)],yaxis);

%-REVERT UNITS-%
set(event.AffectedObject,'Units',axisunits);
set(event.AffectedObject,'FontUnits',fontunits);

end

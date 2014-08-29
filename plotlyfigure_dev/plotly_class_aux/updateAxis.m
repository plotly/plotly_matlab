%----UPDATE AXIS DATA/LAYOUT----%
function obj = updateAxis(obj,~,event,prop)
% title: ...[DONE]
% titlefont:...[DONE]
% range:.................[TODO]
% domain:...[DONE]
% type:.................[TODO]
% rangemode:.................[TODO]
% autorange:.................[TODO]
% showgrid:...[DONE]
% zeroline:...[DONE]
% showline:...[DONE]
% autotick:.................[TODO]
% nticks:.................[TODO]
% ticks:...[DONE]
% showticklabels:.................[TODO]
% tick0:.................[TODO]
% dtick:.................[TODO]
% ticklen:...[DONE]
% tickwidth:...[DONE]
% tickcolor:...[DONE]
% tickangle:...[NOT SUPPORTED IN MATLAB]
% tickfont:.................[TODO]
% tickfont.family..........[TODO]
% tickfont.size...[DONE]
% tickfont.color............[TODO]
% tickfont.outlinecolor............[TODO]
% exponentformat:.................[TODO]
% showexponent:.................[TODO]
% mirror:...[DONE]
% gridcolor:.................[TODO]
% gridwidth:.................[TODO]
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

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Axis.Handle);

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
axisunits = axis_data.Units;
fontunits = axis_data.FontUnits;
set(obj.State.Axis.Handle,'Units','normalized');
set(obj.State.Axis.Handle,'FontUnits','points');

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
        
    case 'YColor'
        
        col = 255*axis_data.XColor;
        yaxiscol = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
        %-yaxis linecolor-%
        yaxis.linecolor = yaxiscol;
        %-yaxis tickcolor-%
        yaxis.tickcolor = yaxiscol;
        %-yaxis tickfont-%
        yaxis.tickfont.color = yaxiscol;
        
    case 'Visible'
        %-xaxis showline-%
        xaxis.showline = true;
        %-yaxis showline-%
        yaxis.showline = true;
        
    case {'XGrid', 'XMinorGrid'}
        
        if strcmp(axis_data.XGrid, 'on') || strcmp(axis_data.XMinorGrid, 'on')
            %-xaxis show grid-%
            xaxis.showgrid = true;
        else
            xaxis.showgrid = false;
        end
        
    case {'YGrid', 'YMinorGrid'}
        
        if strcmp(axis_data.YGrid,'on') || strcmp(axis_data.YMinorGrid,'on')
            %y-axis show grid-%
            yaxis.showgrid = true;
        else
            yaxis.showgrid = false;
        end
        
    case 'LineWidth'
        %-xaxis tick width-%
        xaxis.tickwidth = axis_data.LineWidth;
        %-yaxis tick width-%
        yaxis.tickwidth = axis_data.LineWidth;
        
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
            obj.State.Text.Listeners{obj.getCurrentAnnotationIndex,n} = addlistener(axis_data.Title,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop)updateText(obj,src,event,obj.State.Text.ListenFields{n}));
            textlist = addlistener(axis_data.Title,obj.State.Text.ListenFields{n},'PostGet',@(src,event,prop)updateText(obj,src,event,obj.State.Text.ListenFields{n}));
            %notify the listener
            get(axis_data.Title,obj.State.Text.ListenFields{n});
            %delete the listener
            delete(textlist);
        end
        
        %
        %     case 'XLabel'
        %
        %         if strcmp(event.Type,'PropertyPostSet')
        %             % add axis title listener
        %             for n = 1:length(obj.State.Text.ListenFields)
        %                 addlistener(axis_data.XLabel,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop)updateAxisXLabel(obj,src,event,obj.State.Text.ListenFields{n}));
        %             end
        %         elseif strcmp(event.Type,'PropertyPostGet')
        %             %notify the axis title listeners
        %             textfields = obj.State.Text.ListenFields;
        %             for n = 1:length(textfields)
        %                 textlist = addlistener(axis_data.XLabel,textfields{n},'PostGet',@(src,event,prop)updateAxisXLabel(obj,src,event,textfields{n}));
        %                 %notify the listener
        %                 get(axis_data.XLabel,textfields{n});
        %                 %delete the listener
        %                 delete(textlist);
        %             end
        %         end
        %
        %     case 'YLabel'
        
        
        
        %     case{'XScale'}
        %
        %         xaxis.type = axis_data.XScale; %linear or log
        %
        %     case{'YScale'}
        %
        %         yaxis.type = axis_data.YScale; %linear or log
        %
        %     case{'XLim'}
        %
        %         xaxis.range = axis_data.XLim;
        %
        %     case{'YLim'}
        %
        %         yaxis.range = axis_data.YLim;
        %
        %     case{'XDir'}
        %
        %         if strcmp(axis_data.XDir,'reverse')
        %             xaxis.range = [a.XLim(2) a.XLim(1)];
        %         end
        %
        %         if strcmp(axis_data.YDir,'reverse')
        %             yaxis.range = [a.YLim(2) a.YLim(1)];
        %         end
        %
        %     case{'YDir'}
        
end

%-MATLAB-PLOTLY DEFAULTS-%

%-xaxis zeroline-%
xaxis.zeroline = false;
%-yaxis zeroline-%
yaxis.zeroline = false;

obj.layout = setfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)],xaxis);
obj.layout = setfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)],yaxis);

%-REVERT UNITS-%
set(obj.State.Axis.Handle,'Units',axisunits);
set(obj.State.Axis.Handle,'FontUnits',fontunits);

end







% % % %     %COLORS
% % % %     xaxes.linecolor = parseColor(a.XColor);
% % % %     xaxes.tickcolor = parseColor(a.XColor);
% % % %     xaxes.tickfont.color = parseColor(a.XColor);
% % % %     yaxes.linecolor = parseColor(a.YColor);
% % % %     yaxes.tickcolor = parseColor(a.YColor);
% % % %     yaxes.tickfont.color = parseColor(a.YColor);
% % % %
% % % %     %FONT NAME
% % % %     xaxes.tickfont.family = extractFont(a.FontName);
% % % %     yaxes.tickfont.family = extractFont(a.FontName);
% % % %
% % % % end
% % % %
% % % % %SCALE
% % % % xaxes.type = a.XScale;
% % % % yaxes.type = a.YScale;
% % % % xaxes.range = a.XLim;
% % % % yaxes.range = a.YLim;
% % % % if strcmp(a.XDir, 'reverse')
% % % %     xaxes.range = [a.XLim(2) a.XLim(1)];
% % % % end
% % % % if strcmp(a.YDir, 'reverse')
% % % %     yaxes.range = [a.YLim(2) a.YLim(1)];
% % % % end
% % % %
% % % % if strcmp('log', xaxes.type)
% % % %     xaxes.range = log10(xaxes.range);
% % % % end
% % % % if strcmp('log', yaxes.type)
% % % %     yaxes.range = log10(yaxes.range);
% % % % end
% % % % if strcmp('linear', xaxes.type)
% % % %     if numel(a.XTick)>1
% % % %         xaxes.tick0 = a.XTick(1);
% % % %         xaxes.dtick = a.XTick(2)-a.XTick(1);
% % % %         xaxes.autotick = false;
% % % %
% % % %         try
% % % %             ah = axhan;
% % % %             xtl = get(ah,'XTickLabel');
% % % %             if(strcmp(get(ah,'XTickLabelMode'),'manual'))
% % % %                 if(iscell(xtl))
% % % %                     xaxes.tick0 = str2double(xtl{1});
% % % %                     xaxes.dtick = str2double(xtl{2})-str2double(xtl{1});
% % % %                 end
% % % %                 if(ischar(xtl))
% % % %                     xaxes.tick0 = str2double(xtl(1,:));
% % % %                     xaxes.dtick = str2double(xtl(2,:))- str2double(xtl(1,:));
% % % %                 end
% % % %                 xaxes.autotick = false;
% % % %                 xaxes.autorange = true;
% % % %             end
% % % %         end
% % % %
% % % %     else
% % % %         xaxes.autotick = true;
% % % %     end
% % % % end
% % % % if strcmp('linear', yaxes.type)
% % % %     if numel(a.YTick)>1
% % % %         yaxes.tick0 = a.YTick(1);
% % % %         yaxes.dtick = a.YTick(2)-a.YTick(1);
% % % %         yaxes.autotick = false;
% % % %     else
% % % %         yaxes.autotick = true;
% % % %     end
% % % % end
% % % % %TOIMPROVE: check if the axis is a datetime. There is no implementatin for
% % % % %type category yet.
% % % % if numel(a.XTickLabel)>0
% % % %     try datenum(a.XTickLabel);
% % % %         [start, finish, t0, tstep] = extractDateTicks(a.XTickLabel, a.XTick);
% % % %         if numel(start)>0
% % % %             xaxes.type = 'date';
% % % %             xaxes.range = [start, finish];
% % % %             xaxes.tick0 = t0;
% % % %             xaxes.dtick = tstep;
% % % %             xaxes.autotick = true;
% % % %         end
% % % %     catch
% % % %         %it was not a date...
% % % %     end
% % % % end
% % % % if numel(a.YTickLabel)>0
% % % %     try datenum(a.YTickLabel);
% % % %         [start, finish, t0, tstep] = extractDateTicks(a.YTickLabel, a.YTick);
% % % %         if numel(start)>0
% % % %             yaxes.type = 'date';
% % % %             yaxes.range = [start, finish];
% % % %             yaxes.tick0 = t0;
% % % %             yaxes.dtick = tstep;
% % % %             yaxes.autotick = true;
% % % %         end
% % % %     catch
% % % %         %it was not a date...
% % % %     end
% % % % end
% % % %
% % % % %LABELS
% % % % if ishandle(a.XLabel)
% % % %
% % % %     m_title = get(a.XLabel);
% % % %
% % % %     if ~strip_style
% % % %         if strcmp(m_title.FontUnits, 'points')
% % % %             xaxes.titlefont.size = 1.3*m_title.FontSize;
% % % %         end
% % % %
% % % %         xaxes.titlefont.color = parseColor(m_title.Color);
% % % %
% % % %         %FONT TYPE
% % % %         try
% % % %             xaxes.titlefont.family = extractFont(m_title.FontName);
% % % %         catch
% % % %             display(['We could not find the font family you specified.',...
% % % %                 'The default font: Open Sans, sans-serif will be used',...
% % % %                 'See https://www.plot.ly/matlab for more information.']);
% % % %             xaxes.titlefont.family = 'Open Sans, sans-serif';
% % % %         end
% % % %     end
% % % %
% % % %     if numel(m_title.String)>0
% % % %         xaxes.title = parseLatex(m_title.String,m_title);
% % % %         %xaxes.title = parseText(m_title.String);
% % % %     else
% % % %
% % % %         if(isappdata(axhan,'MWBYPASS_xlabel')) %look for bypass
% % % %             ad = getappdata(axhan,'MWBYPASS_ylabel');
% % % %             try
% % % %                 adAx = get(ad{2});
% % % %                 m_title.String = adAx.XLabel;
% % % %                 xaxes.title = parseLatex(m_title.String,m_title);
% % % %             end
% % % %         end
% % % %     end
% % % % end
% % % %
% % % %
% % % % if ishandle(a.YLabel)
% % % %
% % % %     m_title = get(a.YLabel);
% % % %
% % % %     if ~strip_style
% % % %         if strcmp(m_title.FontUnits, 'points')
% % % %             yaxes.titlefont.size = 1.3*m_title.FontSize;
% % % %         end
% % % %
% % % %         yaxes.titlefont.color = parseColor(m_title.Color);
% % % %
% % % %         %FONT TYPE
% % % %         try
% % % %             yaxes.titlefont.family = extractFont(m_title.FontName);
% % % %         catch
% % % %             display(['We could not find the font family you specified.',...
% % % %                 'The default font: Open Sans, sans-serif will be used',...
% % % %                 'See https://www.plot.ly/matlab for more information.']);
% % % %             yaxes.titlefont.family = 'Open Sans, sans-serif';
% % % %         end
% % % %
% % % %     end
% % % %
% % % %     if numel(m_title.String)>0
% % % %         yaxes.title = parseLatex(m_title.String,m_title);
% % % %         % yaxes.title = parseText(m_title.String);
% % % %     else
% % % %         if(isappdata(axhan,'MWBYPASS_ylabel'))
% % % %             ad = getappdata(axhan,'MWBYPASS_ylabel');
% % % %             try
% % % %                 adAx = get(ad{2});
% % % %                 m_title.String = adAx.YLabel;
% % % %                 yaxes.title = parseLatex(m_title.String,m_title);
% % % %             end
% % % %         end
% % % %     end
% % % % end
% % % %






%----UPDATE AXIS DATA/LAYOUT----%
function obj = updateAxis(obj,~,event,prop)
% title: .................[TODO]
% titlefont:.................[TODO]
% range:.................[TODO]
% domain:...[DONE]
% type:.................[TODO]
% rangemode:.................[TODO]
% autorange:.................[TODO]
% showgrid:...[DONE]
% zeroline:.................[TODO]
% showline:...[DONE]
% autotick:.................[TODO]
% nticks:.................[TODO]
% ticks:...[DONE]
% showticklabels:.................[TODO]
% tick0:.................[TODO]
% dtick:.................[TODO]
% ticklen:.................[TODO]
% tickwidth:.................[TODO]
% tickcolor:...[DONE]
% tickangle:.................[TODO]
% tickfont:.................[TODO]
% tickfont.familty..........[TODO]
% tickfont.size.............[TODO]
% tickfont.color............[TODO]
% tickfont.outlinecolor............[TODO]
% exponentformat:.................[TODO]
% showexponent:.................[TODO]
% mirror:...[DONE]
% gridcolor:.................[TODO]
% gridwidth:.................[TODO]
% zerolinecolor:.................[TODO]
% zerolinewidth:.................[TODO]
% linecolor:...[DONE]
% linewidth:.................[TODO]
% anchor:.................[TODO]
% overlaying:.................[TODO]
% side:.................[TODO]
% position:.................[TODO]

%-UPDATE AXIS HANDLE-%
obj.State.Axis.Handle = event.AffectedObject;

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Axis.Handle);

%-CONVERT TO PLOTLY AXIS NOTATION-%
if isfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)])
    xaxis = getfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)]);
end

if isfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)])
    yaxis = getfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)]);
end

xaxis.anchor = ['y' num2str(obj.getCurrentAxisIndex)];
yaxis.anchor = ['x' num2str(obj.getCurrentAxisIndex)];

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
        
        %-xaxis domain-%
        obj.notifyNewFigure({'Position'});
        
        %small domain offsets due to top margin (needed for title)
        titleOffset = length(obj.State.Figure.NumAxes == 1)*(obj.layout.margin.t)/obj.layout.height;
        
        %assumes units are normalized (we force this)
        xaxis.domain = max([axis_data.Position(1) axis_data.Position(1)+axis_data.Position(3)],1);
        yaxis.domain = max([axis_data.Position(2) axis_data.Position(2)+axis_data.Position(4)+titleOffset],1);
        
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
        
    case 'Title'
        
        %if one plot add as plot title
        
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
        
    case{'XScale'}
        
        xaxis.type = axis_data.XScale; %linear or log
    
    case{'YScale'}
       
        yaxis.type = axis_data.YScale; %linear or log
        
    case{'XLim'}
        
        xaxis.range = axis_data.XLim; 
        
    case{'YLim'}
        
        yaxis.range = axis_data.YLim; 
        
    case{'XDir'}
        
        if strcmp(axis_data.XDir,'reverse')
            xaxis.range = [a.XLim(2) a.XLim(1)]; 
        end
        
        if strcmp(axis_data.YDir,'reverse')
            yaxis.range = [a.YLim(2) a.YLim(1)]; 
        end
        
    case{'YDir'}
        
end

obj.layout = setfield(obj.layout,['xaxis' num2str(obj.getCurrentAxisIndex)],xaxis);
obj.layout = setfield(obj.layout,['yaxis' num2str(obj.getCurrentAxisIndex)],yaxis);

%-REVERT UNITS-%
set(obj.State.Axis.Handle,'Units',axisunits);
set(obj.State.Axis.Handle,'FontUnits',fontunits);

end











% end
%
% %SCALE
% xaxes.type = a.XScale;
% yaxes.type = a.YScale;
% xaxes.range = a.XLim;
% yaxes.range = a.YLim;
% if strcmp(a.XDir, 'reverse')
%     xaxes.range = [a.XLim(2) a.XLim(1)];
% end
% if strcmp(a.YDir, 'reverse')
%     yaxes.range = [a.YLim(2) a.YLim(1)];
% end
%
% if strcmp('log', xaxes.type)
%     xaxes.range = log10(xaxes.range);
% end
% if strcmp('log', yaxes.type)
%     yaxes.range = log10(yaxes.range);
% end
% if strcmp('linear', xaxes.type)
%     if numel(a.XTick)>1
%         xaxes.tick0 = a.XTick(1);
%         xaxes.dtick = a.XTick(2)-a.XTick(1);
%         xaxes.autotick = false;
%
%         try
%             ah = axhan;
%             xtl = get(ah,'XTickLabel');
%             if(strcmp(get(ah,'XTickLabelMode'),'manual'))
%                 if(iscell(xtl))
%                     xaxes.tick0 = str2double(xtl{1});
%                     xaxes.dtick = str2double(xtl{2})-str2double(xtl{1});
%                 end
%                 if(ischar(xtl))
%                     xaxes.tick0 = str2double(xtl(1,:));
%                     xaxes.dtick = str2double(xtl(2,:))- str2double(xtl(1,:));
%                 end
%                 xaxes.autotick = false;
%                 xaxes.autorange = true;
%             end
%         end
%
%     else
%         xaxes.autotick = true;
%     end
% end
% if strcmp('linear', yaxes.type)
%     if numel(a.YTick)>1
%         yaxes.tick0 = a.YTick(1);
%         yaxes.dtick = a.YTick(2)-a.YTick(1);
%         yaxes.autotick = false;
%     else
%         yaxes.autotick = true;
%     end
% end


% %TOIMPROVE: check if the axis is a datetime. There is no implementatin for
% %type category yet.



% if numel(a.XTickLabel)>0
%     try datenum(a.XTickLabel);
%         [start, finish, t0, tstep] = extractDateTicks(a.XTickLabel, a.XTick);
%         if numel(start)>0
%             xaxes.type = 'date';
%             xaxes.range = [start, finish];
%             xaxes.tick0 = t0;
%             xaxes.dtick = tstep;
%             xaxes.autotick = true;
%         end
%     catch
%         %it was not a date...
%     end
% end



% if numel(a.YTickLabel)>0
%     try datenum(a.YTickLabel);
%         [start, finish, t0, tstep] = extractDateTicks(a.YTickLabel, a.YTick);
%         if numel(start)>0
%             yaxes.type = 'date';
%             yaxes.range = [start, finish];
%             yaxes.tick0 = t0;
%             yaxes.dtick = tstep;
%             yaxes.autotick = true;
%         end
%     catch
%         %it was not a date...
%     end
% end





% % %LABELS
% % if numel(a.XLabel)==1
% %     
% %     m_title = get(a.XLabel);
% %     
% %     if numel(m_title.String)>0
% %         xaxes.title = parseLatex(m_title.String,m_title);
% %         %xaxes.title = parseText(m_title.String);
% %         if ~strip_style
% %             if strcmp(m_title.FontUnits, 'points')
% %                 xaxes.titlefont.size = 1.3*m_title.FontSize;
% %             end
% %             xaxes.titlefont.color = parseColor(m_title.Color);
% %             
% %             %FONT TYPE
% %             try
% %                 xaxes.font.family = extractFont(m_title.FontName);
% %             catch
% %                 display(['We could not find the font family you specified.',...
% %                     'The default font: Open Sans, sans-serif will be used',...
% %                     'See https://www.plot.ly/matlab for more information.']);
% %                 xaxes.font.family = 'Open Sans, sans-serif';
% %             end
% %         end
% %     else
% %         
% %         if(isappdata(axhan,'MWBYPASS_xlabel')) %look for bypass
% %             ad = getappdata(axhan,'MWBYPASS_ylabel');
% %             try
% %                 adAx = get(ad{2});
% %                 m_title.String = adAx.XLabel;
% %                 xaxes.title = parseLatex(m_title.String,m_title);
% %             catch exception
% %                 disp('Had trouble locating XLabel');
% %                 return
% %             end
% %         end
% %     end
% % end
% % 
% % 
% % if numel(a.YLabel)==1
% %     
% %     m_title = get(a.YLabel);
% %     
% %     if numel(m_title.String)>0
% %         yaxes.title = parseLatex(m_title.String,m_title);
% %         % yaxes.title = parseText(m_title.String);
% %         if ~strip_style
% %             if strcmp(m_title.FontUnits, 'points')
% %                 yaxes.titlefont.size = 1.3*m_title.FontSize;
% %             end
% %             
% %             yaxes.titlefont.color = parseColor(m_title.Color);
% %             
% %             %FONT TYPE
% %             try
% %                 xaxes.font.family = extractFont(m_title.FontName);
% %             catch
% %                 display(['We could not find the font family you specified.',...
% %                     'The default font: Open Sans, sans-serif will be used',...
% %                     'See https://www.plot.ly/matlab for more information.']);
% %                 xaxes.font.family = 'Open Sans, sans-serif';
% %             end
% %             
% %         end
% %     else
% %         if(isappdata(axhan,'MWBYPASS_ylabel'))
% %             ad = getappdata(axhan,'MWBYPASS_ylabel');
% %             try
% %                 adAx = get(ad{2});
% %                 m_title.String = adAx.YLabel;
% %                 yaxes.title = parseLatex(m_title.String,m_title);
% %             catch exception
% %                 disp('Had trouble locating YLabel');
% %                 return
% %             end
% %         end
% %     end
% % end
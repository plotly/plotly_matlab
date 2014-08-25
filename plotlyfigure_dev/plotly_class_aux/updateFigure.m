%----UPDATE FIGURE DATA/LAYOUT----%
function obj = updateFigure(obj,~,~,prop)

%--------PLOTLY LAYOUT FIELDS---------%

% title ..........[HANDLED BY updateAxis]
% titlefont ..........[HANDLED BY updateAxis]
% font ..........[HANDLED BY updateAxis]
% showlegend ..........[HANDLED BY updateAxis]

% autosize .......... DONE
% width .......... DONE 
% height .......... DONE

% xaxis ..........[HANDLED BY updateAxis]
% yaxis ..........[HANDLED BY updateAxis]
% legend ..........[HANDLED BY updateAxis]
% annotations ..........[HANDLED BY extractAnnotation]

% margin .......... DONE
% paper_bgcolor ..........DONE

% plot_bgcolor ..........[HANDLED BY updateAxis]
% hovermode ..........[NOT SUPPORTED IN MATLAB]
% dragmode ..........[NOT SUPPORTED IN MATLAB]
% separators ..........[NOT SUPPORTED IN MATLAB]
% barmode ..........[HANDLED BY extractBar]
% bargap ..........[HANDLED BY extractBar]
% bargroupgap ..........[HANDLED BY extractBar]
% boxmode ..........[HANDLED BY extractBox]
% radialaxis ..........[HANDLED BY extractPolar]
% angularaxis ..........[HANDLED BY extractPolar]
% direction ..........[HANDLED BY extractPolar]
% orientation ..........[HANDLED BY extractPolar]
% hidesources ..........[NOT SUPPORTED IN MATLAB]

%-----------------------------------------------%

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strip = obj.PlotOptions.Strip;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-STANDARDIZE UNITS-% 
figunits = figure_data.Units;
set(obj.State.Figure.Handle,'Units','pixels');

switch prop
    
    case 'Color'
        
        %-pagper_bgcolor-%
        col = 255*figure_data.Color;
        obj.layout.paper_bgcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
    case 'Position'
        
        %-margin-%
        
        if strip
            obj.layout.margin.l=40;
            obj.layout.margin.r=40;
            obj.layout.margin.t=50;
            obj.layout.margin.b=40;
        else
            
            % set temporary margins to size of figure
            l = figure_data.Position(3);
            r = figure_data.Position(3);
            b = figure_data.Position(4);
            t = figure_data.Position(4);
            
            for c = 1:length(obj.State.Axis.HandleIndexMap)
                
                % set children units to pixels
                axunits = get(obj.State.Axis.HandleIndexMap{c},'Units');
                set(obj.State.Axis.HandleIndexMap{c},'Units','pixels');
                
                % get the current axes
                currentAxis = get(obj.State.Axis.HandleIndexMap{c});
                templ = currentAxis.Position(1);
                l = min(l,templ);
                tempr = (figure_data.Position(3) -  currentAxis.Position(1) - currentAxis.Position(3));
                r = min(r,tempr);
                tempb = currentAxis.Position(2);
                b = min(b,tempb);
                tempt = (figure_data.Position(4) - currentAxis.Position(2) - currentAxis.Position(4));
                t = min(t,tempt);
                
                % revert axes units
                set(obj.State.Axis.HandleIndexMap{c},'Units',axunits);
                
            end
            
            obj.layout.margin.l=l;
            obj.layout.margin.r=l; %add symmetry to avoid title misalignment
            obj.layout.margin.t=max(t,obj.PlotlyDefaults.MinTitleMargin);
            obj.layout.margin.b=b;
            
        end
        
        %width
        obj.layout.width = figure_data.Position(3)*obj.PlotlyDefaults.FigureIncreaseFactor;
        
        %height
        obj.layout.height = figure_data.Position(4)*obj.PlotlyDefaults.FigureIncreaseFactor;
 
    otherwise
        
        %-autosize-%
        obj.layout.autosize = strip;
        obj.layout.margin.pad = obj.PlotlyDefaults.MarginPad;
end

%-REVERT UNITS-% 
set(obj.State.Figure.Handle,'Units',figunits);

end

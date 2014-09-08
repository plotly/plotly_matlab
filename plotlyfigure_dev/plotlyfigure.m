classdef plotlyfigure < handle
    
    %----CLASS PROPERTIES----%
    properties
        data; % data of the plot
        layout; % layout of the plot
        PlotOptions; % filename,fileopt,world_readable
        PlotlyDefaults; % plotly specific conversion defualts
        UserData; % credentials/configuration/verbose
        Response; % response of making post request
        State; % state of plot (FIGURE/AXIS/PLOTS)
    end
    
    %----CLASS METHODS----%
    methods
        
        %----CONSTRUCTOR---%
        function obj = plotlyfigure(varargin)
            %check input structure
            if nargin > 1
                if mod(nargin,2) ~= 0 && ~ishandle(varargin{1})
                    error(['Oops! It appears that you did not initialize the Plotly figure object using the required ',...
                        '(,..''key'',''value'',...) input structure. Please try again or contact chuck@plot.ly',...
                        ' for any additional help!']);
                end
            end
            
            % core Plotly elements
            obj.data = {};
            obj.layout = struct();
            
            % plot options
            obj.PlotOptions.FileName = 'PLOTLYFIGURE';
            obj.PlotOptions.FileOpt = 'overwrite';
            obj.PlotOptions.WorldReadable = true;
            obj.PlotOptions.Open_URL = false;
            obj.PlotOptions.Strip = false;
            obj.PlotOptions.Visible = 'on';
            
            % plot option defaults (edit these for custom conversions)
            obj.PlotlyDefaults.MinTitleMargin = 80;
            obj.PlotlyDefaults.FigureIncreaseFactor = 1.5;
            obj.PlotlyDefaults.AxisLineIncreaseFactor = 1.5;
            obj.PlotlyDefaults.MarginPad = 0;
            obj.PlotlyDefaults.MaxTickLength = 20;
            obj.PlotlyDefaults.TitleHeight = 0.01;
            obj.PlotlyDefaults.ExponentFormat = 'none';
                       
            % check for some key/vals
            for a = 1:2:nargin
                if(strcmpi(varargin{a},'filename'))
                    obj.PlotOptions.Filename = varargin{a+1};
                end
                if(strcmpi(varargin{a},'fileopt'))
                    obj.PlotOptions.Fileopt= varargin{a+1};
                end
                if(strcmpi(varargin{a},'World_readable'))
                    obj.PlotOptions.World_readable = varargin{a+1};
                end
                if(strcmpi(varargin{a},'open'))
                    obj.PlotOptions.Open_URL = varargin{a+1};
                end
                if(strcmpi(varargin{a},'strip'))
                    obj.PlotOptions.Strip = varargin{a+1};
                end
                if(strcmpi(varargin{a},'visible'))
                    obj.PlotOptions.Visible = varargin{a+1};
                end
                if(strcmpi(varargin{a},'layout'))
                    obj.layout= varargin{a+1};
                end
                if(strcmpi(varargin{a},'data'))
                    obj.data = varargin{a+1};
                end
            end
            
            % user data
            try
                [obj.UserData.Credentials.Username,...
                    obj.UserData.Credentials.Api_Key,...
                    obj.UserData.Configuration.Plotly_Domain] = signin;
            catch
                error('Whoops! you must be signed in to initialize a plotlyfigure object!');
            end
                  
            % user experience
            obj.UserData.Verbose = false;
            
            % generate figure and handle
            fig = figure;
            
            % default figure
            set(fig,'Name','PLOTLY FIGURE','Color',[1 1 1],'ToolBar','none','NumberTitle','off','Visible',obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Figure.Handle = fig;
            obj.State.Figure.NumAxes = 0;
            obj.State.Figure.NumPlots = 0;
            obj.State.Figure.NumLegends = 0;
            obj.State.Figure.NumColorbars = 0;
            obj.State.Figure.NumAnnotations = 0;
            
            % new child added listener (axes)
            addlistener(obj.State.Figure.Handle,'ObjectChildAdded',@(src,event)figureAddAxis(obj,src,event));
            % old child removed listener
            addlistener(obj.State.Figure.Handle,'ObjectChildRemoved',@(src,event)figureRemoveAxis(obj,src,event));
            
            % axis state
            obj.State.Axis = [];
            
            % plot state
            obj.State.Plot = [];
            
            % text state
            obj.State.Text = [];
            
            % legend state
            obj.State.Legend = [];
            
            % colorbar state
            obj.State.Colorbar = [];
            
            % check to see if the first argument is a figure
            if nargin > 0
                if ishandle(varargin{1})
                    obj.State.Figure.Reference = [];
                    obj.State.Figure.Reference.Handle = varargin{1};
                    set(obj.State.Figure.Handle,'Color',get(obj.State.Figure.Reference.Handle,'Color'),'Position',get(obj.State.Figure.Reference.Handle,'Position'));
                    obj.convertFigure;
                else
                    % add default axis
                    axes;
                end
            else
                % add default axis
                axes;
            end
            
            % plot response
            obj.Response = {};
        end
        
        
        %----------------------EXTRACT PLOTLY INDICES---------------------%
        
        %----GET CURRENT AXIS INDEX ----%
        function currentAxisIndex = getAxisIndex(obj,axishan)
            currentAxisIndex = find(arrayfun(@(x)(eq(x.Handle,axishan)),obj.State.Axis));
        end
        
        %----GET CURRENT DATA INDEX ----%
        function currentDataIndex = getDataIndex(obj,plothan)
            currentDataIndex = find(arrayfun(@(x)(eq(x.Handle,plothan)),obj.State.Plot));
        end
        
        %----GET CURRENT ANNOTATION INDEX ----%
        function currentAnnotationIndex = getAnnotationIndex(obj,annothan)
            currentAnnotationIndex = find(arrayfun(@(x)(eq(x.Handle,annothan)),obj.State.Text));
        end
        
        %-------------------------USER METHODS----------------------------%
        
        %----GET OBJ.STATE.FIGURE.HANDLE ----%
        function plotlyFigureHandle = gpf(obj)
            plotlyFigureHandle = obj.State.Figure.Handle;
            set(0,'CurrentFigure', plotlyFigureHandle);
        end

        %----SEND PLOT REQUEST (NO UPDATE)----%
        function obj = plotly(obj)
            
            %args
            args.filename = obj.PlotOptions.FileName;
            args.fileopt = obj.PlotOptions.FileOpt;
            args.world_readable = obj.PlotOptions.WorldReadable;
            
            %layout
            args.layout = obj.layout;
            
            %send to plotly
            response = plotly(obj.data,args);
            
            %update response
            obj.Response = response;
            
            %ouput url as hyperlink in command window if possible
            try
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                editor = desktop.getGroupContainer('Editor');
                if(~strcmp(response.url,'') && ~isempty(editor));
                    fprintf(['\nLet''s have a look: <a href="matlab:openurl(''%s'')">' response.url '</a>\n\n'],response.url)
                end
            end
            
        end
        
        %--------------------------TITLE CHECKS---------------------------%
        
        function check = isTitle(obj,annothan)
            try
                check = obj.State.Text(obj.getAnnotationIndex(annothan)).Title;
            catch
                check = false;
            end
        end
        
        
        function titleIndex= getTitleIndex(obj,axhan)
            titleIndex = find(arrayfun(@(x)(eq(x.AssociatedAxis,axhan)&&(x.Title)),obj.State.Text));
        end
        
        %-----------------------FIGURE CONVERSION-------------------------%
        
        %automatic figure conversion
        function obj = convertFigure(obj)
            % create temp figure
            tempfig = figure('Visible','off');
            % find axes of reference figure
            ax = findobj(obj.State.Figure.Reference.Handle,'Type','axes');
            for a = 1:length(ax)
                % copy them to tempfigure
                axtemp = copyobj(ax(a),tempfig);
                % clear the children
                cla(axtemp,'reset');
                % add axtemp to figure
                axnew = copyobj(axtemp,obj.State.Figure.Handle);
                % copy ax children to axtemp
                copyobj(allchild(ax(a)),axnew);
            end
            delete(tempfig);
            close(obj.State.Figure.Reference.Handle);
            %update plotlyfigure object
            obj.update; 
        end
        
        
        %----------------------UPDATE PLOTLY FIGURE-----------------------%
        
        function obj = update(obj)
            
            %update figure
            updateFigure(obj);
            
            %update axes
            for n = 1:obj.State.Figure.NumAxes
                updateAxis(obj,n);
            end
            
            %update plots (must update before colorbars) 
            for n = 1:obj.State.Figure.NumPlots
                updateData(obj,n);
            end
            
            %update annotations
            for n = 1:obj.State.Figure.NumAnnotations
                updateAnnotation(obj,n);
            end
            
            %update legends
            for n = 1:obj.State.Figure.NumLegends
                updateLegend(obj,n);
            end
            
            %update colorbars
            for n = 1:obj.State.Figure.NumColorbars
                updateColorbar(obj,n);
            end
            
        end
        
        %--------------------CALLBACK FUNCTIONS---------------------------%
        
        %----ADD AN AXIS TO THE FIGURE----%
        function obj = figureAddAxis(obj,~,event)
            % check for type axes
            if strcmp(get(event.Child,'Type'),'axes')
                %check tag
                switch lower(event.Child.classhandle.name)
                    case 'legend'
                        % update the number of legends
                        obj.State.Figure.NumLegends = obj.State.Figure.NumLegends + 1;
                        obj.State.Legend(obj.State.Figure.NumLegends).Handle = event.Child;
                    case 'colorbar'
                        % update the number of colorbars
                        obj.State.Figure.NumColorbars = obj.State.Figure.NumColorbars + 1;
                        obj.State.Colorbar(obj.State.Figure.NumColorbars).Handle = event.Child;
                    otherwise
                        % update the number of axes
                        obj.State.Figure.NumAxes = obj.State.Figure.NumAxes + 1;
                        %update the axis handle
                        obj.State.Axis(obj.State.Figure.NumAxes).Handle = event.Child;
                        %new child added
                        addlistener(obj.State.Axis(obj.State.Figure.NumAxes).Handle,'ObjectChildAdded',@(src,event)axisAddPlot(obj,src,event));
                        %old child removed
                        addlistener(obj.State.Axis(obj.State.Figure.NumAxes).Handle,'ObjectChildRemoved',@(src,event)axisRemovePlot(obj,src,event));
                        
                        %----add title----%
                        
                        %update the text index
                        obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations + 1;
                        %text handle
                        obj.State.Text(obj.State.Figure.NumAnnotations).Handle = event.Child.Title;
                        obj.State.Text(obj.State.Figure.NumAnnotations).AssociatedAxis = event.Child;
                        obj.State.Text(obj.State.Figure.NumAnnotations).Title = true;
                        %add title listener
                        addlistener(event.Child,'Title','PostSet',@(src,event)axisAddTitle(obj,src,event));
                end
            end
        end
        
        %----ADD A PLOT TO AN AXIS----%
        
        function obj = axisAddPlot(obj,~,event)
            % separate text from non-text
            if strcmpi(event.Child.Type,'text')
                % ignore empty string text 
                if (validText(event.Child));
                    %update the text index
                    obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations + 1;
                    %text handle
                    obj.State.Text(obj.State.Figure.NumAnnotations).Handle = event.Child;
                    obj.State.Text(obj.State.Figure.NumAnnotations).AssociatedAxis = event.Child.Parent;
                    obj.State.Text(obj.State.Figure.NumAnnotations).Title = false;
                end
            else
                % update the plot index
                obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                % plot handle
                obj.State.Plot(obj.State.Figure.NumPlots).Handle = event.Child;
                obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = event.Child.Parent;
                obj.State.Plot(obj.State.Figure.NumPlots).Class = event.Child.classhandle.name;
            end
        end
        
        %----ADD TITLE TO AN AXIS----%
        
        function obj = axisAddTitle(obj,~,event)
            
            %----remove old title---_%
            
            % get current title index
            titleIndex = obj.getTitleIndex(event.AffectedObject);
            % update the text index
            obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations - 1;
            % update the HandleIndexMap
            obj.State.Text(titleIndex) = [];
            
            %----replace with new title----%
            
            % update the text index
            obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations + 1;
            % text handle
            obj.State.Text(obj.State.Figure.NumAnnotations).Handle = event.AffectedObject.Title;
            obj.State.Text(obj.State.Figure.NumAnnotations).AssociatedAxis = event.AffectedObject;
            obj.State.Text(obj.State.Figure.NumAnnotations).Title = true;
            
        end
        
        %----REMOVE AN AXIS FROM THE FIGURE----%
        
        function obj = figureRemoveAxis(obj,~,event)
            
            if strcmp(event.Child.Type,'axes')
                
                % check for legends/colorbars
                switch lower(event.Child.classhandle.name)
                    case 'legend'
                        %update the number of legends
                        obj.State.Legend(obj.State.Figure.NumLegends).Handle = [];
                        obj.State.Figure.NumLegends = obj.State.Figure.NumLegends - 1;
                    case 'colorbar'
                        %update the number of colorbars
                        obj.State.Colorbar(obj.State.Figure.NumColorbars).Handle = [];
                        obj.State.Figure.NumColorbars = obj.State.Figure.NumColorbars - 1;
                    otherwise
                        %get current axis index
                        currentAxis = obj.getAxisIndex(event.Child);
                        % update the number of axes
                        obj.State.Figure.NumAxes = obj.State.Figure.NumAxes - 1;
                        % update the axis HandleIndexMap
                        obj.State.Axis(currentAxis) = [];
                        
                        %-----remove title-----%
                        
                        % get current title index
                        titleIndex = obj.getTitleIndex(event.Child);
                        % update the text index
                        obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations - 1;
                        % update the HandleIndexMap
                        obj.State.Text(titleIndex) = [];
                end
            end
        end
        
        %----REMOVE A PLOT FROM AN AXIS----%
        function obj = axisRemovePlot(obj,~,event)
            if ~strcmpi(event.Child.Type,'text')
                % get current plot index
                currentPlot = obj.getDataIndex(event.Child);
                % update the plot index
                obj.State.Figure.NumPlots = obj.State.Figure.NumPlots - 1;
                % update the HandleIndexMap
                obj.State.Plot(currentPlot) = [];
                % not(empty annotation or title/label)
            elseif ~(isempty(get(event.Child,'String')) || eq(event.Child,event.Source.Title) || ...
                    eq(event.Child,event.Source.ZLabel) || eq(event.Child,event.Source.XLabel) || ...
                    eq(event.Child,event.Source.YLabel))
                % get current annotation index
                currentAnnotation = obj.getAnnotationIndex(event.Child);
                % update the text index
                obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations - 1;
                % update the HandleIndexMap
                obj.State.Text(currentAnnotation) = [];
            end
        end
    end
end


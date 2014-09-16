classdef plotlyfigure < handle
    
    %----CLASS PROPERTIES----%
    properties (SetObservable)
        data; % data of the plot
        layout; % layout of the plot
    end
    
    properties
        PlotOptions; % filename,fileopt,world_readable
        PlotlyDefaults; % plotly specific conversion defualts
        UserData; % credentials/configuration/verbose
        Response; % response of making post request
        State; % state of plot (FIGURE/AXIS/PLOTS)
        LiveEdit;
    end
    
    %---CLASS EVENTS---%
    events
        liveedit;
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
            
            % add live edit listeners
            addlistener(obj,'data','PostSet',@obj.editLive);
            addlistener(obj,'layout','PostSet',@obj.editLive);
            
            % plot options
            obj.PlotOptions.FileName = 'PlotlyFigure';
            obj.PlotOptions.FileOpt = 'overwrite';
            obj.PlotOptions.WorldReadable = true;
            obj.PlotOptions.Open_URL = false;
            obj.PlotOptions.Strip = false;
            obj.PlotOptions.Visible = 'on';
            
            % plot option defaults (edit these for custom conversions)
            obj.PlotlyDefaults.MinTitleMargin = 80;
            obj.PlotlyDefaults.TitleHeight = 0.01;
            obj.PlotlyDefaults.FigureIncreaseFactor = 1.5;
            obj.PlotlyDefaults.AxisLineIncreaseFactor = 1.5;
            obj.PlotlyDefaults.MarginPad = 0;
            obj.PlotlyDefaults.MaxTickLength = 20;
            obj.PlotlyDefaults.ExponentFormat = 'none';
            obj.PlotlyDefaults.ErrorbarWidth = 6;
            obj.PlotlyDefaults.MarkerOpacity = 1;
            obj.PlotlyDefaults.ShowBaselineLegend = false;
            
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
            
            % live editing
            obj.LiveEdit = false;
            
            % figure state
            obj.State.Figure = [];
            
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
            
            % initialize emtpy fig handle
            fig = [];
            
            % check to see if the first argument is a figure
            if nargin > 0
                if ishandle(varargin{1})
                    fig = varargin{1};
                end
            end
            
            if isempty(fig)
                
                % create new figure
                fig = figure;
                
                % add default axis
                axes;
                
            end
            
            % plotly figure default style
            set(fig,'Name','Plotly Figure','Color',[1 1 1],'ToolBar','none','NumberTitle','off', 'Visible', obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Figure.Handle = fig;
            
            % convert figure
            obj.update;
            
        end
        
        %-------------------------USER METHODS----------------------------%
        
        %----SET LIVE EDIT PROPERTY----%
        function startlive(obj)
            obj.LiveEdit = true;
        end
        
        %----SET LIVE EDIT PROPERTY----%
        function stoplive(obj)
            obj.LiveEdit = false;
        end
        
        %----GET OBJ.STATE.FIGURE.HANDLE ----%
        function plotlyFigureHandle = gpf(obj)
            plotlyFigureHandle = obj.State.Figure.Handle;
            set(0,'CurrentFigure', plotlyFigureHandle);
        end
        
        %----STRIP THE STYLE DEFAULTS----%
        function obj = strip(obj)
            obj.PlotOptions.Strip = true;
            obj.update;
        end
        
        %----GET PLOTLY FIGURE-----%
        function obj = grab(obj, file_owner, file_id)
            plotlyfig = getplotlyfig(file_owner, file_id);
            obj.data = plotlyfig.data; 
            obj.layout = plotlyfig.layout; 
        end
        
        %----SAVE STATIC PLOTLY IMAGE-----%
        function obj = saveas(obj, filename, varargin)
            
            % create image figure
            imgfig.data = obj.data;
            imgfig.layout = obj.layout;
            
            % save image
            saveplotlyfig(imgfig, filename, varargin{:});
        end
        
        %----SAVE STATIC JPEG IMAGE-----%
        function obj = jpeg(obj, filename)
            if nargin > 1
                obj.saveas(filename,'jpeg');
            else
                obj.saveas(obj.PlotOptions.FileName,'jpeg');
            end
        end
        
        %----SAVE STATIC PDF IMAGE-----%
        function obj = pdf(obj, filename)
            if nargin > 1
                obj.saveas(filename,'pdf');
            else
                obj.saveas(obj.PlotOptions.FileName,'pdf');
            end
        end
        
        %----SAVE STATIC PNG IMAGE-----%
        function obj = png(obj, filename)
            if nargin > 1
                obj.saveas(filename,'png');
            else
                obj.saveas(obj.PlotOptions.FileName,'png');
            end
        end
        
        %----SAVE STATIC SVG IMAGE-----%
        function obj = svg(obj, filename)
            if nargin > 1
                obj.saveas(filename,'svg');
            else
                obj.saveas(obj.PlotOptions.FileName,'svg');
            end
        end
        
        %----SEND PLOT REQUEST (NO UPDATE)----%
        function obj = plotly(obj,showlink)
            
            if nargin == 1
                showlink = true;
            end
            
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
            if showlink
                try
                    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                    editor = desktop.getGroupContainer('Editor');
                    if(~strcmp(response.url,'') && ~isempty(editor));
                        fprintf(['\nLet''s have a look: <a href="matlab:openurl(''%s'')">' response.url '</a>\n\n'],response.url)
                    end
                end
            end
        end
        
        %-----------------------FIGURE CONVERSION-------------------------%
        
        %automatic figure conversion
        function obj = update(obj)
            
            % reset figure object count
            obj.State.Figure.NumAxes = 0;
            obj.State.Figure.NumPlots = 0;
            obj.State.Figure.NumLegends = 0;
            obj.State.Figure.NumColorbars = 0;
            obj.State.Figure.NumAnnotations = 0;
            
            % find axes of figure
            ax = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','');
            obj.State.Figure.NumAxes = length(ax);
            
            % update number of annotations (one title per axis)
            obj.State.Figure.NumAnnotations = length(ax);
            
            % find children of figure axes
            for a = 1:length(ax)
                
                obj.State.Axis(a).Handle = ax(a);
                
                %add title
                obj.State.Text(a).Handle = get(ax(a),'Title');
                obj.State.Text(a).AssociatedAxis = handle(ax(a));
                obj.State.Text(a).Title = true;
                
                % find plots of figure
                plots = findobj(ax(a),'-not','Type','Text','-not','Type','axes','-depth',1);
                
                % add baseline objects
                baselines = findobj(ax(a),'-property','BaseLine');
                baselinehan = cell2mat(get(baselines,'BaseLine'));
                plots = [baselinehan ; plots];
                
                for np = length(plots):-1:1
                    % update the plot fields
                    obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                    obj.State.Plot(obj.State.Figure.NumPlots).Handle = handle(plots(np));
                    obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = handle(ax(a));
                    obj.State.Plot(obj.State.Figure.NumPlots).Class = handle(plots(np)).classhandle.name;
                end
            end
            
            % find text of figure
            texts = findobj(ax(a),'Type','text','-depth',1);
            obj.State.Figure.NumAnnotations = obj.State.Figure.NumAnnotations + length(texts);
            
            for t = 1:length(texts)
                obj.State.Text(t).Handle = handle(texts(t));
                obj.State.Text(t).Title = false;
                obj.State.Text(t).AssociatedAxis = handle(ax(a));
            end
            
            
            % find legends of figure
            legs = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','legend');
            obj.State.Figure.NumLegends = length(legs);
            
            for g = 1:length(legs)
                obj.State.Legend(g).Handle = handle(legs(g));
                
                % find associated axis
                legendAxis = findLegendAxis(obj, handle(legs(g)));
                
                % update colorbar associated axis
                obj.State.Legend(g).AssociatedAxis = legendAxis;
            end
            
            % find colorbar of figure
            cols = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','Colorbar');
            obj.State.Figure.NumColorbars = length(cols);
            
            for c = 1:length(cols)
                
                % update colorbar handle
                obj.State.Colorbar(c).Handle = handle(cols(c));
                
                % find associated axis
                colorbarAxis = findColorbarAxis(obj, handle(cols(c)));
                
                % update colorbar associated axis
                obj.State.Colorbar(c).AssociatedAxis = colorbarAxis;
                
            end
            
            %--------------------UPDATE PLOTLY FIGURE---------------------%
            
            %reset dataget(obj.State.Figure.Handle,'Children')
            obj.data = {};
            
            %reset layout
            obj.layout = struct();
            
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
        
        %----LIVE EDIT (NOT USED FOR NOW)----%
        
        function obj = editLive(obj,~,~)
            if obj.LiveEdit
                % switch off liveedit
                obj.LiveEdit = false;
                % send to plotly without link
                showlink = false;
                obj.plotly(showlink);
                % switch on liveedit
                obj.LiveEdit = true;
            end
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
        
        %-------------------OVERLOADED FUNCTIONS--------------------------%
        
        function han = image(obj, varargin)
            %call bar
            han = image(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = imagesc(obj, varargin)
            %call bar
            han = imagesc(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = line(obj, varargin)
            %call bar
            han = line(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = patch(obj, varargin)
            %call bar
            han = patch(varargin{:});
            %update object
            obj.update;
        end
        
        function han = rectangle(obj, varargin)
            %call bar
            han = rectangle(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = area(obj,varargin)
            %call area
            han = area(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = bar(obj,varargin)
            %call bar
            han = bar(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = contour(obj,varargin)
            %call plot
            han = contour(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = plot(obj,varargin)
            %call plot
            han = plot(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = errorbar(obj,varargin)
            %call plot
            han = errorbar(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = quiver(obj,varargin)
            %call plot
            han = quiver(varargin{:});
            %update object
            obj.update;
        end
        
        function han = scatter(obj, varargin)
            %call bar
            han = scatter(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = stairs(obj,varargin)
            %call plot
            han = stairs(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = stem(obj,varargin)
            %call plot
            han = stem(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = boxplot(obj,varargin)
            %call plot
            han = boxplot(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
    end
end


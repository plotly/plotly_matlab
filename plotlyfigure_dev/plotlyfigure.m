classdef plotlyfigure < handle
    
    %----CLASS PROPERTIES----%
    properties
        data; % data of the plot
        layout; % layout of the plot
        PlotlyDefaults; % plotly specific conversion defualts
        Response; % response of making post request
        State; % state of plot (FIGURE/AXIS/PLOTS)
    end
    
    properties (SetObservable)
        UserData;% credentials/configuration/verbose
        PlotOptions; % filename,fileopt,world_readable
    end
    
    properties (Access = private)
        PlotlyReference; % load the plotly reference
        InitialState; % inital userdata 
    end
    
    
    %----CLASS METHODS----%
    methods
        
        %----CONSTRUCTOR---%
        function obj = plotlyfigure(varargin)
            
            %check input structure
            if nargin > 1
                if mod(nargin,2) ~= 0 && any(~ishandle(varargin{1}))
                    error('plotlyfigureConstructor:invalidInputs' , ['\nOops! It appears that you did not initialize the Plotly figure object using\n', ...
                        'the required: >>  plotlyfigure(handle [optional],..''key'',''value'',...) input \n',...
                        'structure. Please try again or contact chuck@plot.ly for any additional help!']);
                end
            end
            
            % core Plotly elements
            obj.data = {};
            obj.layout = struct();
            
            % plotly reference 
            obj.PlotlyReference = []; 
            
            % plot options
            obj.PlotOptions.FileName = 'myplotlyfigure';
            obj.PlotOptions.FileOpt = 'overwrite';
            obj.PlotOptions.WorldReadable = true;
            obj.PlotOptions.OpenURL = true;
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
            obj.PlotlyDefaults.ShowBaselineLegend = false;
            obj.PlotlyDefaults.Bargap = 0;
            
            % check for some key/vals
            for a = 1:2:nargin
                if(strcmpi(varargin{a},'filename'))
                    obj.PlotOptions.FileName = varargin{a+1};
                end
                if(strcmpi(varargin{a},'fileopt'))
                    obj.PlotOptions.FileOpt= varargin{a+1};
                end
                if(strcmpi(varargin{a},'world_readable'))
                    obj.PlotOptions.WorldReadable = varargin{a+1};
                end
                if(strcmpi(varargin{a},'open'))
                    obj.PlotOptions.OpenURL = varargin{a+1};
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
                [obj.UserData.Username,...
                    obj.UserData.ApiKey,...
                    obj.UserData.PlotlyDomain] = signin;
                
                % save the initial state
                obj.InitialState.Username = obj.UserData.Username;
                obj.InitialState.ApiKey = obj.UserData.ApiKey;
                obj.InitialState.PlotlyDomain = obj.UserData.PlotlyDomain;
            catch
                error('Whoops! you must be signed in to initialize a plotlyfigure object!');
            end
            
            % user experience
            obj.UserData.Verbose = true;
            
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
            set(fig,'Name',obj.PlotOptions.FileName,'Color',[1 1 1],'NumberTitle','off', 'Visible', obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Figure.Handle = fig;
            
            % convert figure
            obj.update;
            
            % add listeners
            addlistener(obj,'PlotOptions','PostSet',@(src,event)updatePlotOptions(obj,src,event));
           
            % add listeners
            addlistener(obj,'UserData','PostSet',@(src,event)updateUserData(obj,src,event));
        end
        
        %-------------------------USER METHODS----------------------------%
        
        %----GET OBJ.STATE.FIGURE.HANDLE ----%
        function plotlyFigureHandle = gpf(obj)
            plotlyFigureHandle = obj.State.Figure.Handle;
            set(0,'CurrentFigure', plotlyFigureHandle);
        end
        
        %----LOAD PLOTLY REFERENCE-----%
        function obj = loadplotlyref(obj)
            if isempty(obj.PlotlyReference)
                % plotly reference
                plotlyref = load('plotly_reference.mat');
                % update the PlotlyRef property
                obj.PlotlyReference = plotlyref.pr;  
            end
        end
        
        %----STRIP THE FIELDS OF A SPECIFIED KEY-----%
        function stripped = stripkeys(obj, fields, fieldname, key)
            
            %plorlt reference
            pr = obj.PlotlyReference;
            
            % initialize output
            stripped = fields;
            
            % get fieldnames
            fn = fieldnames(stripped);
            fnmod = fn;
            
            try
                
                for d = 1:length(fn);
                    
                    % clean up axis keys
                    if any(strfind(fn{d},'xaxis')) || any(strfind(fn{d},'yaxis'))
                        fnmod{d} = fn{d}(1:length('_axis'));
                    end
                    
                    % keys:(object, style, plot_info, data)
                    keytype = getfield(pr,fieldname,fnmod{d},'key_type');
                    
                    % check for objects
                    if strcmp(keytype,'object')
                        
                        % clean up font keys
                        if any(strfind(fn{d},'font'))
                            fnmod{d} = 'font';
                        end
                        
                        % handle annotations
                        if strcmp(fn{d},'annotations')
                            annot = getfield(stripped, fn{d});
                            fnmod{d} = 'annotation';
                            for a = 1:length(annot)
                                %recursive call to stripkeys
                                stripped.annotations{a} = obj.stripkeys(annot{a}, fnmod{d}, key);
                            end
                        else
                            %recursive call to stripkeys
                            stripped = setfield(stripped, fn{d}, obj.stripkeys(getfield(stripped, fn{d}), fnmod{d}, key));
                        end
                        
                        % look for desired key
                    elseif any(strcmp(keytype, key))
                        stripped = rmfield(stripped, fn{d});
                    end
                    
                end
                
                %----CLEAN UP----%
                remfn = fieldnames(stripped);
                
                for n = 1:length(remfn)
                    if isstruct(getfield(stripped,remfn{n}))
                        if isempty(fieldnames(getfield(stripped,remfn{n})))
                            stripped = rmfield(stripped,remfn{n});
                        end
                    elseif isempty(getfield(stripped,remfn{n}))
                        stripped = rmfield(stripped,remfn{n});
                    end
                end
                
                %---HANDLE ERRORS---%
            catch exception
                if obj.UserData.Verbose
                    fprintf(['\nWhoops! ' exception.message(1:end-1) ' in ' fieldname '\n\n']);
                end
                
            end
        end
            
       %----STRIP THE STYLE DEFAULTS----%
        function obj = strip(obj)
            
            % load plotly reference
            obj.loadplotlyref;
            
            % update the data/layout
            obj.update;
            
            % strip the style keys from data
            for d = 1:length(obj.data)
                obj.data{d} = obj.stripkeys(obj.data{d}, obj.data{d}.type, 'style');
            end
            
            % strip the style keys from layout
            obj.layout = obj.stripkeys(obj.layout, 'layout', 'style');
            
        end
        
        %----GET THE FIELDS OF TYPE DATA----%
        function datafield = getdata(obj)
            
            % load plotly reference
            obj.loadplotlyref;
            
            % remove style / plot_info types in data
            for d = 1:length(obj.data)
                datafield = obj.stripkeys(obj.data{d}, obj.data{d}.type, {'style','plot_info'});
            end
            
        end
        
        %----VALIDATE THE DATA/LAYOUT KEYS----%
        function validate(obj)
            
            % load plotly reference
            obj.loadplotlyref;
            
            % validate data fields
            for d = 1:length(obj.data)
                obj.stripkeys(obj.data{d}, obj.data{d}.type, {'style','plot_info'});
            end
            
            % validate layout fields
            obj.stripkeys(obj.layout, 'layout', 'style');
            
        end
              
        %----GET PLOTLY FIGURE-----%
        function obj = grab(obj, file_owner, file_id)
            plotlyfig = getplotlyfig(file_owner, file_id);
            obj.data = plotlyfig.data;
            obj.layout = plotlyfig.layout;
        end
        
        %---------------------STATIC IMAGE METHODS------------------------%
        
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
        
        
        %------------------------REST API CALL----------------------------%
        
        %----SEND PLOT REQUEST (NO UPDATE)----%
        function obj = plotly(obj)
            
            % validate keys
            validate(obj); 
            
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
            if obj.PlotOptions.OpenURL
                openurl(response.url);
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
            obj.State.Figure.NumTexts = 0;
            
            % find axes of figure
            ax = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','');
            obj.State.Figure.NumAxes = length(ax);
            
            % update number of annotations (one title per axis)
            obj.State.Figure.NumTexts = length(ax);
            
            % find children of figure axes
            for a = 1:length(ax)
                
                % reverse axes
                axrev = length(ax) - a + 1;
                
                % set axis handle field
                obj.State.Axis(a).Handle = ax(axrev);
                
                % add title
                obj.State.Text(a).Handle = get(ax(axrev),'Title');
                obj.State.Text(a).AssociatedAxis = handle(ax(axrev));
                obj.State.Text(a).Title = true;
                
                % find plots of figure
                plots = findobj(ax(axrev),'-not','Type','Text','-not','Type','axes','-depth',1);
                
                % add baseline objects
                baselines = findobj(ax(axrev),'-property','BaseLine');
                
                % get baseline handles
                baselinehan = get(baselines,'BaseLine');
                
                if iscell(baselinehan)
                    baselinehan = cell2mat(baselinehan);
                end
                
                % update plots
                plots = [plots ; baselinehan];
                
                for np = 1:length(plots)
                    
                    % reverse plots
                    nprev = length(plots) - np + 1; 
                    
                    % update the plot fields
                    obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                    obj.State.Plot(obj.State.Figure.NumPlots).Handle = handle(plots(nprev));
                    obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = handle(ax(axrev));
                    obj.State.Plot(obj.State.Figure.NumPlots).Class = handle(plots(nprev)).classhandle.name;
                end
                
                % find text of figure
                texts = findobj(ax(axrev),'Type','text','-depth',1);
                
                for t = 1:length(texts)
                    obj.State.Text(obj.State.Figure.NumTexts + t).Handle = handle(texts(t));
                    obj.State.Text(obj.State.Figure.NumTexts + t).Title = false;
                    obj.State.Text(obj.State.Figure.NumTexts + t).AssociatedAxis = handle(ax(axrev));
                end
                
                % update number of annotations
                obj.State.Figure.NumTexts = obj.State.Figure.NumTexts + length(texts);
                
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
            
            % reset dataget(obj.State.Figure.Handle,'Children')
            obj.data = {};
            
            % reset layout
            obj.layout = struct();
            
            % update figure
            updateFigure(obj);
            
            % update axes
            for n = 1:obj.State.Figure.NumAxes
                updateAxis(obj,n);
            end
            
             % update plots
            for n = 1:obj.State.Figure.NumPlots
                updateData(obj,n);
            end
            
            % update annotations
            for n = 1:obj.State.Figure.NumTexts
                updateAnnotation(obj,n);
            end
            
            % update legends
            for n = 1:obj.State.Figure.NumLegends
                updateLegend(obj,n);
            end
            
            % update colorbars
            for n = 1:obj.State.Figure.NumColorbars
                updateColorbar(obj,n);
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
        
        
        %-------------------CALLBACK FUNCTIONS--------------------------%
        
        %----UPDATE PLOT OPTIONS----%
        function obj = updatePlotOptions(obj,~,~)
            set(obj.State.Figure.Handle,'Name',obj.PlotOptions.FileName, 'Visible', obj.PlotOptions.Visible);
        end
        
        %----UPDATE USER DATA----%
        function obj = updateUserData(obj,~,~)
            signin(obj.UserData.Username,...
                   obj.UserData.ApiKey,...
                   obj.UserData.PlotlyDomain);
               disp('here'); 
        end
        
        %-------------------OVERLOADED FUNCTIONS--------------------------%
        
        %----PLOT FUNCTIONS----%
        function han = image(obj, varargin)
            %call image
            han = image(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = imagesc(obj, varargin)
            %call imagesc
            han = imagesc(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = line(obj, varargin)
            %call line
            han = line(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = patch(obj, varargin)
            %call patch
            han = patch(varargin{:});
            %update object
            obj.update;
        end
        
        function han = rectangle(obj, varargin)
            %call rectangle
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
            %call contour
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
            %call errorbar
            han = errorbar(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = quiver(obj,varargin)
            %call quiver
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
            %call stairs
            han = stairs(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = stem(obj,varargin)
            %call stem
            han = stem(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = boxplot(obj,varargin)
            %call boxplot
            han = boxplot(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        function han = mesh(obj,varargin)
            %call mesh
            han = mesh(varargin{:});
            %update object
            obj.update;
            %send to plotly
            obj.plotly;
        end
        
        %----OTHER----%
        function delete(obj)
            % reset persistent USERNAME, KEY, and DOMAIN
            % of signin to original state
            signin(obj.InitialState.Username, ...
                   obj.InitialState.ApiKey,...
                   obj.InitialState.PlotlyDomain); 
        end
    end
end


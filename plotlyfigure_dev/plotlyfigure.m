classdef plotlyfigure < handle
    
    % plotlyfigure constructs an online Plotly plot.
    % There are three modes of use. The first is the
    % most base level approach of initializing a
    % plotlyfigure object and specify the data and layout
    % properties using Plotly declarartive syntax.
    % The second is a mid level useage which is based on
    % overloading the MATLAB plotting commands, such as
    % 'plot', 'scatter', 'subplot', ...
    % Lastly we have the third level of use
    
    %----CLASS PROPERTIES----%
    properties
        Data; % data of the plot
        Layout; % layout of the plot
        PlotOptions; % filename,fileopt,world_readable
        UserData; % credentials/configuration
        Response; % response of making post request
        State; % state of plot (FIGURE/AXIS/PLOTS)
        Verbose; % output procedural steps
        HandleGen; %object figure handle generator properties
    end
    
    %----CLASS METHODS----%
    methods
        
        %----CONSTRUCTOR---%
        function obj = plotlyfigure(varargin)
            if mod(nargin,2) ~= 0
                error(['Oops! It appears that you did not initialize the Plotly figure object using the required ',...
                    '(,..''key'',''value'',...) input structure. Please try again or contact chuck@plot.ly',...
                    ' for any additional help!']);
            end
            
            % core Plotly elements
            obj.Data = cell(1,1);
            obj.Layout = {};
            
            % user experience
            obj.Verbose = false;
            
            % plot options
            obj.PlotOptions.Filename = 'PLOTLYFIGURE';
            obj.PlotOptions.Fileopt = 'new';
            obj.PlotOptions.World_readable = true;
            obj.PlotOptions.Open_URL = false;
            obj.PlotOptions.Strip = true;
            obj.PlotOptions.Visible = 'on';
            
            % figure handle generation properties
            obj.HandleGen.Offset = 30000;
            obj.HandleGen.MaxAttempts = 10000;
            obj.HandleGen.Size = 4;
            
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
                    obj.Layout= varargin{a+1};
                end
                if(strcmpi(varargin{a},'data'))
                    obj.Data = varargin{a+1};
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
            
            % generate figure and handle
            fig = figure(obj.generateUniqueHandle);
            
            % default figure
            set(fig,'Name','PLOTLY FIGURE','color',[1 1 1],'ToolBar','none','NumberTitle','off','Visible',obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Figure.Handle = fig;
            obj.State.Figure.NumAxis = 0;
            
            % add figure listeners
            obj.addFigureListeners;
            
            % add default axis
            axes;
            
            %addlistener(obj.State.Figure.Handle,'Name','PreSet',@(src,event,test)updateTest(obj,src,event,'hello'));
            
            % destroy obj upon figure deletion
            set(obj.State.Figure.Handle,'DeleteFcn',@obj.deletePlotlyFigure);
            
            % plot response
            obj.Response = {};
        end
    end
    
    methods (Access = private)
        
        %----GENERATE UNIQUE FIGURE HANDLE----%
        function figureHandle = generateUniqueHandle(obj)
            attempts = 1;
            figureHandle = obj.HandleGen.Offset + floor((10^obj.HandleGen.Size)*rand);
            obj.State.Figure.Handle = figureHandle;
            %make sure the handle is unique
            while ishandle(figureHandle)
                figureHandle = obj.HandleGen.Offset + floor((10^obj.HandleGen.Size)*rand);
                obj.State.Figure.Handle = figureHandle;
                attempts = attempts + 1;
                if attempts > maxAttempts
                    error(['Sorry! A unique figure handle was not generated in ' maxAttempts ' attempts.',...
                        'Please close any unused plotlyfigures and try again!']);
                end
            end
        end

        %----GET CURRENT AXIS INDEX----%
        function currentAxisIndex = getCurrentAxisIndex(obj)
            currentAxisIndex = find([obj.State.Axis(:).Handle] == get(obj.State.Figure.Handle,'CurrentAxes'));
        end
        
        %----GET CURRENT AXIS HANDLE----%
        function currentAxisHandle = getCurrentAxisHandle(obj)
            currentAxisHandle = get(obj.State.Figure.Handle,'CurrentAxes');
        end
        
        %----GET CURRENT PLOT HANDLE----%
        function currentPlotHandle = getCurrentPlotHandle(obj)
            currentPlotHandle = obj.State.Plot.Handle;
        end
        
        %----DELETE PLOTLY FIGURE OBJECT----%
        function obj = deletePlotlyFigure(obj,~,~)
            delete(obj);
        end
        
        %----SEND PLOT REQUEST----%
        function obj = plotly(obj)
            %args
            args = obj.PlotOptions;
            %data
            data = obj.Data;
            %layout
            args.layout = obj.Layout;
            %send to plotly
            response = plotly(data,args);
            %update response
            obj.Response = response;
        end
        
        %----GET OBJ.STATE.FIGURE.HANDLE ----%
        function plotlyFigureHandle = gpf(obj)
            plotlyFigureHandle = obj.State.Figure.Handle;
            set(0,'CurrentFigure', plotlyFigureHandle);
        end
        
        %----ADD FIGURE LISTENERS----%
        function obj = addFigureListeners(obj)
            %new child added (axes)
            addlistener(obj.State.Figure.Handle,'ObjectChildAdded',@obj.figureAddAxis);
            %figure field names
            figfields = fieldnames(get(obj.State.Figure.Handle));
            %add listeners to the figure fields
            for n = 1:length(figfields)
                addlistener(obj.State.Figure.Handle,figfields{n},'PreSet',@(src,event,prop)updateFigure(obj,src,event,figfields{n}));
            end
        end
        
        %----ADD AXES LISTENERS----%
        function obj = addAxisListeners(obj)
            %new child added
            addlistener(obj.getCurrentAxisHandle,'ObjectChildAdded',@(src,event)axisAddPlot(obj,src,event));
            %old child removed 
            addlistener(obj.getCurrentAxisHandle,'ObjectChildRemoved',@(src,event)axisRemovePlot(obj,src,event));
            %figure field names
            axisfields = fieldnames(get(obj.getCurrentAxisHandle));
            %add listeners to the figure fields
            for n = 1:length(axisfields)
                addlistener(obj.getCurrentAxisHandle,axisfields{n},'PreSet',@(src,event,prop)updateAxis(obj,src,event,axisfields{n}));
            end
        end
        
         %----ADD PLOT LISTENERS----%
        function obj = addPlotListeners(obj)
            %new child added
            addlistener(obj.getCurrentPlotHandle,'ObjectChildAdded',@(src,event)axisAddPlot(obj,src,event));
            %old child removed 
            addlistener(obj.getCurrentAxisHandle,'ObjectChildRemoved',@(src,event)axisRemovePlot(obj,src,event));
            %figure field names
            plotfields = fieldnames(get(obj.getCurrentPlotHandle));
            %add listeners to the figure fields
            for n = 1:length(plotfields)
                addlistener(obj.getCurrentPlotHandle,plotfields{n},'PreSet',@(src,event,prop)updatePlot(obj,src,event,plotfields{n}));
            end
        end
        
        %----CALLBACK FUNCTIONS---%
        
        %----ADD AN AXIS TO THE FIGURE----%
        function obj = figureAddAxis(obj,~,~)
            obj.State.Figure.NumAxis = obj.State.Figure.NumAxis + 1;
            obj.State.Axis(obj.State.Figure.NumAxis).Handle = get(obj.State.Figure.Handle,'CurrentAxes');
            % add listeners to the axis
            obj.addAxisListeners;
        end
        
        %----REMOVE AN AXIS FROM THE FIGURE----%
        function obj = figureRemoveAxis(obj,~,~)
        end

        %----ADD A PLOT TO AN AXIS----%
        function obj = axisAddPlot(obj,~,event)
            % update obj.Data
            obj.State.Plot.Handle = event.Child;
            obj.State.Plot.Call = event.Child.classhandle.Name;
            % add listeners to the plot 
            obj.addPlotListeners; 
        end
                
        %----REMOVE A PLOT FROM AN AXIS----%
        function obj = axisRemovePlot(obj,src,event)
        end
        
        %----UPDATE FIGURE DATA/LAYOUT----%
        function obj = updateFigure(obj,~,~,prop)
            switch prop
                case 'Name'
                    disp('GOT NAME CHANGE');
                otherwise
                    %  disp(prop);
            end
        end
        
        %----UPDATE AXIS DATA/LAYOUT----%
        function obj = updateAxis(obj,~,~,prop)
            switch prop
                case 'Color'
                    disp('GOT COLOR CHANGE');
                otherwise
                    % disp(prop);
            end
        end
        
        %----UPDATE PLOT DATA/STYLE----%
        function obj = updatePlot(obj,~,~,prop)
            switch prop
                case 'Color'
                    disp('GOT COLOR CHANGE');
                otherwise
                    % disp(prop);
            end
        end
        
    end
end


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
        data; % data of the plot
        layout; % layout of the plot
        PlotOptions; % filename,fileopt,world_readable
        PlotlyDefaults;
        UserData; % credentials/configuration
        Response; % response of making post request
        State; % state of plot (FIGURE/AXIS/PLOTS)
        Verbose; % output procedural steps
        HandleGen; %object figure handle generator properties
    end
    
    events
        %hiddenText
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
            
            % user experience
            obj.Verbose = false;
            
            % plot options
            obj.PlotOptions.Filename = 'PLOTLYFIGURE';
            obj.PlotOptions.Fileopt = 'new';
            obj.PlotOptions.World_readable = true;
            obj.PlotOptions.Open_URL = false;
            obj.PlotOptions.Strip = false;
            obj.PlotOptions.Visible = 'on';
            
            % plot option defaults (edit these for custom conversions)
            obj.PlotlyDefaults.MinTitleMargin = 80;
            obj.PlotlyDefaults.FigureIncreaseFactor = 1.5;
            obj.PlotlyDefaults.MarginPad = 0;
            obj.PlotlyDefaults.MaxTickLength = 20;
            
            % intialize Axis HandleIndexMap
            obj.State.Axis.HandleIndexMap = {};
            
            % intialize Plot HandleIndexMap
            obj.State.Plot.HandleIndexMap = {};
            
            % intialize Text HandleIndexMap
            obj.State.Text.HandleIndexMap = {};
            
            % figure handle generation properties
            obj.HandleGen.Offset = 30000;
            obj.HandleGen.MaxAttempts = 10000;
            obj.HandleGen.Size = 4;
            
            % initialize reference figure
            obj.State.Figure.Reference = [];
            
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
            
            % generate figure and handle
            fig = figure(obj.generateUniqueHandle);
            
            % default figure
            set(fig,'Name','PLOTLY FIGURE','color',[1 1 1],'ToolBar','none','NumberTitle','off','Visible',obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Figure.Handle = fig;
            obj.State.Figure.NumAxes = 0;
            obj.State.Figure.NumPlots = 0;
            obj.State.Figure.NumLegends = 0;
            obj.State.Figure.NumTexts = 0;
            obj.State.Figure.ListenFields = {'Position','Color'};
            
            %add hidden text listener
            %addlistener(obj,'hiddenText',@(src,event)removeHiddenAnnotation(obj,src,event));
            
            % add figure listeners
            obj.addFigureListeners;
            
            % notify new figure upon creation
            obj.notifyNewFigure(fieldnames(get(obj.State.Figure.Handle)));
            
            % axis state
            obj.State.Axis.ListenFields = {'Box','Position', 'XAxisLocation',...
                'YAxisLocation', 'TickDir', 'Title',...
                'XColor', 'YColor','FontSize','XGrid',...
                'XMinorGrid','YGrid','YMinorGrid',...
                'TickLength','Visible'};
            
            % text state
            obj.State.Text.ListenFields = {'String','Color','FontName',...
                'FontSize','BackgroundColor',...
                'EdgeColor','HorizontalAlignment',...
                'Interpreter','LineStyle','LineWidth',...
                'Margin','Position','Visible'};
            
            % check to see if the first argument is a figure
            if nargin > 0
                if ishandle(varargin{1})
                    obj.State.Figure.Reference.Handle = varargin{1};
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
    end
    
    methods
        
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
        
        %----GET CURRENT AXIS INDEX ----%
        function currentAxisIndex = getCurrentAxisIndex(obj)
            currentAxisIndex = find(cellfun(@(h)eq(h,obj.State.Axis.Handle),obj.State.Axis.HandleIndexMap));
        end
        
        %----GET CURRENT DATA INDEX ----%
        function currentDataIndex = getCurrentDataIndex(obj)
            currentDataIndex = find(cellfun(@(h)eq(h,obj.State.Plot.Handle),obj.State.Plot.HandleIndexMap));
        end
        
        %----GET CURRENT ANNOTATION INDEX ----%
        function currentAnnotationIndex = getCurrentAnnotationIndex(obj)
            currentAnnotationIndex = find(cellfun(@(h)eq(h,obj.State.Text.Handle),obj.State.Text.HandleIndexMap));
        end
        
        %----SEND PLOT REQUEST----%
        function obj = fig2plotly(obj)
            %args
            args = obj.PlotOptions;
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
        
        %----GET OBJ.STATE.FIGURE.HANDLE ----%
        function plotlyFigureHandle = gpf(obj)
            plotlyFigureHandle = obj.State.Figure.Handle;
            set(0,'CurrentFigure', plotlyFigureHandle);
        end
        
        %----ADD FIGURE LISTENERS----%
        function obj = addFigureListeners(obj)
            % new child added (axes)
            addlistener(obj.State.Figure.Handle,'ObjectChildAdded',@(src,event)figureAddAxis(obj,src,event));
            % old child removed
            addlistener(obj.State.Figure.Handle,'ObjectChildRemoved',@(src,event)figureRemoveAxis(obj,src,event));
            % add listeners to the figure fields
            for n = 1:length(obj.State.Figure.ListenFields)
                addlistener(obj.State.Figure.Handle,obj.State.Figure.ListenFields{n},'PostSet',@(src,event,prop)updateFigure(obj,src,event,obj.State.Figure.ListenFields{n}));
            end
        end
        
        %----ADD AXES LISTENERS----%
        function obj = addAxisListeners(obj)
            %new child added
            addlistener(obj.State.Axis.Handle,'ObjectChildAdded',@(src,event)axisAddPlot(obj,src,event));
            %old child removed
            addlistener(obj.State.Axis.Handle,'ObjectChildRemoved',@(src,event)axisRemovePlot(obj,src,event));
            %add listeners to the axis fields
            for n = 1:length(obj.State.Axis.ListenFields)
               addlistener(obj.State.Axis.Handle,obj.State.Axis.ListenFields{n},'PostSet',@(src,event,prop)updateAxis(obj,src,event,obj.State.Axis.ListenFields{n}));
            end
        end
        
        %----ADD PLOT LISTENERS----%
        function obj = addPlotListeners(obj)
            %plot field names
            plotfields = fieldnames(get(obj.State.Plot.Handle));
            %add listeners to the figure fields
            for n = 1:length(plotfields)
                addlistener(obj.State.Plot.Handle,plotfields{n},'PostSet',@(src,event,prop)updatePlot(obj,src,event,plotfields{n}));
            end
        end
        
        %----ADD LEGEND LISTENERS----%
        function obj = addLegendListeners(obj)
            %axisfields = fieldnames(get(obj.State.Axis.Handle));
            addlistener(obj.State.Legend.Handle,'Position','PostSet',@(src,event,prop)updateLegend(obj,src,event,'Position'));
            %             %add listeners to the figure fields
            %             for n = 1:length(axisfields)
            %                 addlistener(obj.State.Axis.Handle,axisfields{n},'PostSet',@(src,event,prop)updateAxis(obj,src,event,axisfields{n}));
            %             end
        end
        
        %----ADD TEXT LISTENERS----%
        function obj = addTextListeners(obj)
            %add listeners to the text fields
            for n = 1:length(obj.State.Text.ListenFields)
                addlistener(obj.State.Text.Handle,obj.State.Text.ListenFields{n},'PostSet',@(src,event,prop)updateText(obj,src,event,obj.State.Text.ListenFields{n}));
            end
        end
        
        %----NOTIFY THE FIGURE PROPERTIES----%
        function obj = notifyNewFigure(obj,prop)
            %axis field names
            figfields = prop;
            %add listeners to the figure fields
            for n = 1:length(figfields)
                fl = addlistener(obj.State.Figure.Handle,figfields{n},'PostGet',@(src,event,prop)updateFigure(obj,src,event,figfields{n}));
                %notify the listener
                get(obj.State.Figure.Handle,figfields{n});
                %delete the listener
                delete(fl);
            end
        end
        
        %----NOTIFY THE AXIS PROPERTIES----%
        function obj = notifyNewAxis(obj,prop)
            axisfields = prop;
            %add listeners to the figure fields
            for n = 1:length(axisfields)
                axlist = addlistener(obj.State.Axis.Handle,axisfields{n},'PostGet',@(src,event,prop)updateAxis(obj,src,event,axisfields{n}));
                %notify the listener
                get(obj.State.Axis.Handle,axisfields{n});
                %delete the listener
                delete(axlist);
            end
        end
        
        %----NOTIFY THE PLOT PROPERTIES----%
        function obj = notifyNewPlot(obj,prop)
            % plot field names
            plotfields = prop;
            %add listeners to the figure fields
            for n = 1:length(plotfields)
                pl = addlistener(obj.State.Plot.Handle,plotfields{n},'PostGet',@(src,event,prop)updatePlot(obj,src,event,plotfields{n}));
                %notify the listener
                get(obj.State.Plot.Handle,plotfields{n});
                %delete the listener
                delete(pl);
            end
        end
        
        %----NOTIFY THE LEGEND PROPERTIES----%
        function obj = notifyNewLegend(obj,prop)
            %axis field names
            legfields = prop;
            %add listeners to the figure fields
            for n = 1:length(legfields)
                leglist = addlistener(obj.State.Legend.Handle,legfields{n},'PostGet',@(src,event,prop)updateLegend(obj,src,event,legfields{n}));
                %notify the listener
                get(obj.State.Legend.Handle,legfields{n});
                %delete the listener
                delete(leglist);
            end
        end
        
        %----NOTIFY THE TEXT PROPERTIES----%
        function obj = notifyNewText(obj,prop)
            %axis field names
            textfields = prop;
            %add listeners to the figure fields
            for n = 1:length(textfields)
                textlist = addlistener(obj.State.Text.Handle,textfields{n},'PostGet',@(src,event,prop)updateText(obj,src,event,textfields{n}));
                %notify the listener
                get(obj.State.Text.Handle,textfields{n});
                %delete the listener
                delete(textlist);
            end
        end
        
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
        end
        
        %----object deleted---%
        function delete(obj)
            delete(obj.State.Figure.Handle);
        end
        
        %----CALLBACK FUNCTIONS---%
        
        %----ADD AN AXIS TO THE FIGURE----%
        function obj = figureAddAxis(obj,~,event)
            % potential axis handle
            obj.State.Axis.Handle = event.Child;
            % check for type axes
            if strcmp(get(obj.State.Axis.Handle,'Type'),'axes')
                %check for legend tag
                if strcmp(get(obj.State.Axis.Handle,'Tag'),'legend')
                    %update the number of legends
                    obj.State.Figure.NumLegends = obj.State.Figure.NumLegends + 1;
                    if obj.State.Figure.NumLegends == 1
                        %store the first legend handle
                        obj.State.Legend.Handle = obj.State.Axis.Handle;
                        %add listeners to the legend
                        obj.addLegendListeners;
                        %notify the creation of the legend
                        obj.notifyNewLegend(fieldnames(get(obj.State.Axis.Handle)));
                    end
                else
                    % update the number of axes
                    obj.State.Figure.NumAxes = obj.State.Figure.NumAxes + 1;
                    % update the axis HandleIndexMap
                    obj.State.Axis.HandleIndexMap{obj.State.Figure.NumAxes} = obj.State.Axis.Handle;
                    % add listeners to the axis
                    obj.addAxisListeners;
                    % notify the creation of the axis
                    obj.notifyNewAxis(obj.State.Axis.ListenFields);
                end
            end
        end
        
        %----REMOVE AN AXIS FROM THE FIGURE----%
        function obj = figureRemoveAxis(obj,~,event)
            % potential axis handle
            obj.State.Axis.Handle = event.Child;
            % check for type axes
            if strcmp(get(obj.State.Axis.Handle,'Type'),'axes')
                % update the number of axes
                obj.State.Figure.NumAxes = obj.State.Figure.NumAxes - 1;
                % update the layout property
                eval(['obj.layout = rmfield(obj.layout,''xaxis' num2str(obj.getCurrentAxisIndex) ''');']);
                eval(['obj.layout = rmfield(obj.layout,''yaxis' num2str(obj.getCurrentAxisIndex) ''');']);
                % update the axis HandleIndexMap
                obj.State.Axis.HandleIndexMap(obj.getCurrentAxisIndex) = [];
            else
                %HANDLE ANNOTATIONS
            end
        end
        
        %----ADD A PLOT TO AN AXIS----%
        function obj = axisAddPlot(obj,~,event)
            % separate text from non-text
%            if ~strcmp(get(event.Child,'type'),'text')
                % plot handle
                obj.State.Plot.Handle = event.Child;
                % update the plot index
                obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                % update the HandleIndexMap
                obj.State.Plot.HandleIndexMap{obj.State.Figure.NumPlots} = obj.State.Plot.Handle;
                % add listeners to the plot
                obj.addPlotListeners;
                % notify the creation of the plot
                obj.notifyNewPlot(fieldnames(get(obj.State.Plot.Handle)));
%             else
%                 %text handle
%                 obj.State.Text.Handle = event.Child;
%                 % update the text index
%                 obj.State.Figure.NumTexts = obj.State.Figure.NumTexts + 1;
%                 % update the HandleIndexMap
%                 obj.State.Text.HandleIndexMap{obj.State.Figure.NumTexts} = obj.State.Text.Handle;
%                 % add listeners to the text annotations
%                 obj.addTextListeners;
%                 % notify the creation of the text
%                 obj.notifyNewText(fieldnames(get(obj.State.Text.Handle)));
%             end
        end
        
        %----REMOVE A PLOT FROM AN AXIS----%
        function obj = axisRemovePlot(obj,~,event)
            % separate text from non-text
           % if ~strcmp(get(event.Child,'type'),'text')
                % plot handle
                obj.State.Plot.Handle = event.Child;
                % update the plot index
                obj.State.Figure.NumPlots = obj.State.Figure.NumPlots - 1;
                % update the data property
                obj.data(obj.getCurrentDataIndex) = [];
                % update the HandleIndexMap
                obj.State.Plot.HandleIndexMap(obj.getCurrentDataIndex) = [];
%             else
%                 %if invisible it was already removed
%                 if strcmp(get(event.Child,'HandleVisibility'),'on')
%                     % text handle
%                     obj.State.Text.Handle = event.Child;
%                     % update the text index
%                     obj.State.Figure.NumTexts = obj.State.Figure.NumTexts - 1;
%                     % update the annotations layout field
%                     obj.layout.annotations(obj.getCurrentAnnotationIndex) = [];
%                     % update the HandleIndexMap
%                     obj.State.Text.HandleIndexMap(obj.getCurrentAnnotationIndex) = [];
%                 end
%             end
        end
        
%         function obj = removeHiddenAnnotation(obj, ~, ~)
%             % update the text index
%             obj.State.Figure.NumTexts = obj.State.Figure.NumTexts - 1;
%             % update the annotations layout field
%             obj.layout.annotations(obj.getCurrentAnnotationIndex) = [];
%             if obj.getCurrentAnnotationIndex == 1;
%                 obj.layout = rmfield(obj.layout,'annotations');
%             end
%             % update the HandleIndexMap
%             obj.State.Text.HandleIndexMap(obj.getCurrentAnnotationIndex) = [];
%         end
    end
end


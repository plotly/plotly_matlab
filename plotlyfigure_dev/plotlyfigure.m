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
        State; % state of plot (current axis)
        list;
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
            
            % plot options
            obj.PlotOptions.Filename = 'untitled';
            obj.PlotOptions.Fileopt = 'new';
            obj.PlotOptions.World_readable = true;
            obj.PlotOptions.Open_URL = false;
            obj.PlotOptions.Strip = true;
            obj.PlotOptions.Visible = 'on';
            
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
                obj.UserData.Credentials = loadplotlycredentials;
            catch exception
                fprintf(['\n\n' exception.identifier exception.message '\n\n']);
            end
            try
                obj.UserData.Configuration = loadplotlyconfig;
            catch exception
                fprintf(['\n\n' exception.identifier exception.message '\n\n']);
            end
            
            % default Plotly figure
            fig = figure('Name','PLOTLY FIGURE','color',[1 1 1],'NumberTitle','off','Visible',obj.PlotOptions.Visible);
            
            % figure state
            obj.State.Verbose = false;
            obj.State.Figure.Handle = fig;
            obj.State.Figure.NumAxis = 0; 
            obj.State.Figure.NextPlot = 'add';
            set(obj.State.Figure.Handle,'NextPlot','new');
            obj.State.Figure.Locked = false;
            
            % add figure listeners
            addlistener(obj.State.Figure.Handle,'NextPlot','PostSet',@obj.figureNextPlotModified);
            addlistener(obj.State.Figure.Handle,'ObjectChildAdded',@obj.figureAddAxis);
            
            % default Plotly axes
            ax = gca;
            
            % axis state
            obj.State.CurrentAxisIndex = 1;
            obj.State.CurrentDataIndex = 0;
            obj.State.Axis(obj.State.CurrentAxisIndex).Handle = ax;
            obj.State.Axis(obj.State.CurrentAxisIndex).NextPlot = 'replace';
            set(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot','replace');
            obj.State.Axis(obj.State.CurrentAxisIndex).Locked = false;
            
            % add axis listener
            addlistener(obj.State.Figure.Handle,'NextPlot','PostSet',@obj.axisNextPlotModified);
            
            % lock the figure and axis
            obj.State.Figure.Locked = true;
            obj.State.Axis(obj.State.CurrentAxisIndex).Locked = true;
            
            % plot response
            obj.Response = {};
            
        end
        
        %----PLOT----%
        function obj = plot(obj,varargin)
            
            % allow the plot to be drawn on obj.State.FigureHandle
            set(obj.State.Figure.Handle,'NextPlot',obj.State.Figure.NextPlot);
            
            % allow the plot to be drawn on obj.State.AxesHandle(obj.State.CurrentAxisHandleIndex)
            set(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot',obj.State.Axis(obj.getCurrentAxisIndex).NextPlot);
            
            try
                %it is possible that this is an axis handle that does not exist on obj.FigureHandle
                if ishandle(varargin{1})
                    if strcmp(get(varargin{1},'type'),'axes')
                        if ~ismember(varargin{1},[obj.State.Axis(:).Handle])
                            if(obj.State.Verbose)
                                fprintf(['\nOops! The axis handle specified does not match one recognized',...
                                    '\nwithin the current Plotly figure. The plot will be drawn on the current',...
                                    '\axis, whose handle is: ' num2str(obj.State.AxisHandle(obj.State.CurrentAxisIndex))]);
                            end
                            varargin{1} = obj.State.Axis(obj.getCurrentAxisIndex).Handle;
                        else
                            obj.State.CurrentAxisIndex = find(varargin{1} == [obj.State.Axis(:).Handle]);
                        end
                    else
                        varargin = {obj.State.Axis(obj.getCurrentAxisIndex).Handle,varargin{:}};
                    end
                else
                    varargin = {obj.State.Axis(obj.getCurrentAxisIndex).Handle,varargin{:}};
                end
            catch
                error(['Oops! An error occured while looking for the axis handle',...
                    'associated with this plot. Please make sure the axis handle specified',...
                    'is a child of the Plotly figure, whose handle is: ' num2str(obj.State.Figure.Handle)]);
            end
            
            % update the current data handle index
            obj.State.CurrentDataIndex = obj.State.CurrentDataIndex + 1;
            
            % make the plot and grab the data handle
            obj.State.Data(obj.State.CurrentDataIndex).Handle = plot(varargin{:});
            
            % map Data(obj.State.CurrentDataIndex).Handle to Axis(obj.State.CurrentAxisIndex).Handle.
            obj.State.Data(obj.State.CurrentDataIndex).AxisHandle = obj.State.Axis(obj.getCurrentAxisIndex).Handle;
            
            % update data
            obj = extractPlotData(obj);
            
            % update layout
            obj = extractPlotLayout(obj);
            
            % store the actual NextPlot setting of the Figure
            obj.State.Figure.NextPlot = get(obj.State.Figure.Handle,'NextPlot');
            
            % store the actual NextPlot setting of the Axis
            obj.State.Axis(obj.getCurrentAxisIndex).NextPlot = get(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot');
            
            % prevent generic plots being drawn on obj.State.Figure.Handle
            obj.LockFigure; 
            
            % prevent generic plots being drawn on obj.State.Axis(:).Handle
            obj.LockAxis; 
           
        end

        %----SET THE HOLD OF THE FIGURE----%
        function obj = hold(obj,varargin)
        end
        
        %----SEND PLOT REQUEST----%
        function obj = plotly(obj)
            response = plotly(obj.Data);
            obj.Response = response;
        end
        
        %----GET CURRENT AXIS----%
        function currentAxisIndex = getCurrentAxisIndex(obj)
             currentAxisIndex = find(obj.State.Axis(:).Handle == get(obj.State.Figure.Handle,'CurrentAxes'));
        end
        
        %----LOCK FIGURE----%
        set(obj.State.Figure.Handle,'NextPlot','new');
        
        %----CALLBACK FUNCTIONS---%
        function figureNextPlotModified(obj,~,~)
            if obj.State.Figure.Locked
                fprintf('\n[PLOTLY MESSAGE]: Sorry! You may not modify the NextPlot property of the plotlyfigure objects root figure\n\n');
            end
        end
        function axisNextPlotModified(obj,~,~)
            if obj.State.Figure.Locked
                fprintf('\n[PLOTLY MESSAGE]: Sorry! You may not modify the NextPlot property of the plotlyfigure objects current axis\n\n');
            end
        end
        function figureAddAxis(obj,~,~) 
           obj.State.Figure.NumAxis = obj.State.Figure.NumAxis + 1; 
           obj.State.Axis(obj.State.Figure.NumAxis).Handle = get(obj.State.Figure.Handle,'CurrentAxes'); 
           obj.State.Axis(obj.State.Figure.NumAxis).ID = obj.State.Figure.NumAxis; 
           % extract the layout of the current axis
           extractAxisLayout(obj); 
        end
    end
end


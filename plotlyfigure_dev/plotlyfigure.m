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
        %Stream; %stream {'key','handle','maxpoint'}
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
%                 if(strcmpi(varargin{a},'stream'))
%                     obj.Stream = varargin{a+1};
%                 end
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
            
            % default Plotly axes
            ax = gca;
            
            % plot state
            obj.State.Verbose = false;
            obj.State.Figure.Handle = fig;
            obj.State.Figure.NextPlot = 'new';
            set(obj.State.Figure.Handle,'NextPlot','new'); 
            obj.State.CurrentAxisIndex = 1;
            obj.State.CurrentDataIndex = 0; 
            obj.State.Axis(obj.State.CurrentAxisIndex).Handle = ax;
            obj.State.Axis(obj.State.CurrentAxisIndex).NextPlot = 'new';
            set(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot','new');
            
            % plot response
            obj.Response = {};
            
        end
        
        %----PLOT----%
        function obj = plot(obj,varargin)
            
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
                            varargin{1} = obj.State.Axis(obj.State.CurrentAxisIndex).Handle;
                        else
                            obj.State.CurrentAxisIndex = find(varargin{1} == [obj.State.Axis(:).Handle]);
                        end
                    else
                        varargin = {obj.State.Axis(obj.State.CurrentAxisIndex).Handle,varargin{:}};
                    end
                else
                  varargin = {obj.State.Axis(obj.State.CurrentAxisIndex).Handle,varargin{:}};  
                end
            catch
                error(['Oops! An error occured while looking for the axis handle',...
                    'associated with this plot. Please make sure the axis handle specified',...
                    'is a child of the Plotly figure, whose handle is: ' num2str(obj.State.Figure.Handle)]);
            end
 
            % allow the plot to be drawn on obj.State.FigureHandle
            set(obj.State.Figure.Handle,'NextPlot',obj.State.Figure.NextPlot); 
            
            % allow the plot to be drawn on obj.State.AxesHandle(obj.State.CurrentAxisHandleIndex)
            set(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot',obj.State.Axis(obj.State.CurrentAxisIndex).NextPlot); 
            
            % update the current data handle index
            obj.State.CurrentDataIndex = obj.State.CurrentDataIndex + 1;
            
            % make the plot and grab the data handle
            obj.State.Data(obj.State.CurrentDataIndex).Handle = plot(varargin{:});
            
            % map Data(obj.State.CurrentDataIndex).Handle to Axis(obj.State.CurrentAxisIndex).Handle.
            obj.State.Data(obj.State.CurrentDataIndex).AxisHandle = obj.State.Axis(obj.State.CurrentAxisIndex).Handle; 
            
            % update data
            obj = extractPlotData(obj);
            
            % update layout
            obj = extractPlotLayout(obj);
            
            % prevent generic plots being drawn on obj.State.FigureHandle
            set(obj.State.Figure.Handle,'NextPlot','new'); 
            
            % prevent generic plots being drawn on obj.State.AxesHandle
            for d = 1:length(obj.State.Axis(obj.State.CurrentAxisIndex).Handle)
            set(obj.State.Axis(obj.State.CurrentAxisIndex).Handle,'NextPlot','new'); 
            end
        end
        
        %----SET THE HOLD OF THE FIGURE----%
        function obj = hold(obj,varargin) 
        end
        
        %----SEND PLOT REQUEST----%
        function obj = plotly(obj)
            response = plotly(obj.Data);
            obj.Response = response;
        end
    end
end


%------TODO------%

% title
% xlabel
% ylabel
% set/get
% subplot
% plot
% scatter
% bar
% contour
% hist
% imagesc
% polar
% global plot command
% ...

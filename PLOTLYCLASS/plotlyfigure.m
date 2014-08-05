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
        Stream; %stream {'key','handle','maxpoint'} 
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
                if(strcmpi(varargin{a},'stream'))
                    obj.Stream = varargin{a+1};
                end
            end
            
            % user data
            obj.UserData.Credentials = loadplotlycredentials;
            obj.UserData.Configuration = loadplotlyconfig;
            
            % default Plotly figure
            fig = figure('Name','PLOTLY FIGURE','color',[1 1 1],'NumberTitle','off','Visible',obj.PlotOptions.Visible);
            
            % default Plotly axes
            ax = gca;
            
            % plot state
            obj.State.Verbose = false;
            obj.State.FigureHandle = fig;
            obj.State.AxisHandle(1) = ax;
            obj.State.CurrentAxisHandleIndex = 1;
            obj.State.DataHandle(1) = NaN;
            obj.State.CurrentDataHandleIndex = 1;
            obj.State.Data2AxisMap = [];
            
            % plot response
            obj.Response = {};
              
        end
        
        %----PLOT----%
        function obj = plot(obj,varargin)
            
            try
                if ishandle(varargin{1})
                    if strcmp(get(varargin{1},'type'),'axes')
                        if ~ismember(varargin{1},obj.State.AxisHandle)
                            if(obj.State.Verbose)
                                fprintf(['\nOops! The axis handle specified does not match one recognized',...
                                    '\nwithin the current Plotly figure. The plot will be drawn on the current',...
                                    '\axis, whose handle is: ' num2str(obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex))]);
                            end
                            varargin{1} = obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex);
                        else
                            obj.State.CurrentAxisHandleIndex = find(varargin{1} == obj.State.AxisHandle);
                        end
                    end
                else
                    varargin = {obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex),varargin{:}};
                end
            catch
                error(['Oops! An error occured while looking for the axis handle',...
                    'associated with this plot. Please make sure the axis handle specified',...
                    'is a child of the Plotly figure, whose handle is: ' num2str(obj.State.FigureHandle)]);
            end
            
            %check for hold to either erase or update
            switch get(obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex),'NextPlot')
                case 'add'
                    % Use the existing axes to draw graphics object
                    obj.State.CurrentDataHandleIndex = obj.State.CurrentDataHandleIndex + 1;
                case 'replace'
                    % Reset all axes properties except Position to their defaults and delete all axes children before displaying graphics (equivalent to cla reset)
                case 'replacechildren'
                    % Remove all child objects, but do not reset axes properties (equivalent to cla).
            end
            
            % map DataHandle to AxisHandle
            obj.State.Data2AxisMap(obj.State.CurrentDataHandleIndex) = obj.State.CurrentAxisHandleIndex;
            % make the plot and grab the data handle
            obj.State.DataHandle(obj.State.CurrentDataHandleIndex) = plot(varargin{:});
            % update data
            obj = extractPlotData(obj);
            % update layout
            obj = extractPlotLayout(obj);
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

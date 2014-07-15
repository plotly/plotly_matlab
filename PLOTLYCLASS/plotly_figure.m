classdef plotly_figure
    %plotlyfigure defines an online plotly plot
    %the main difference between this approach
    %and fig2plotly is that using fig2plotly is blind
    %to whatever functions were called.
    %TODO: [ADDING PLOT FUNCTION PARSING]
    %TODO: [ADD FIG INPUT];
    
    properties
        Layout; %layout of the plot
        Data; %data of the plot
        PlotOptions; %filename,fileopt,world_readable
        UserData; %credentials/configuration
        State; %state of plot (current axis)
    end
    
    methods
        %constructor
        function obj = plotly_figure(varargin)
            if mod(nargin,2) ~= 0
                fprintf(['\nSorry! You did not enter the right number of inputs \nto initialize ',...
                    'the plotly_figure object. Please try again \nor contact chuck@plot.ly',...
                    ' for more information! \n\n']);
                return
            end
            
            %create a plotly figure
            fig = figure('Name','PLOTLY FIGURE','color',[1 1 1],'NumberTitle','off');
            ax = gca;
            
            obj.Layout = {};
            obj.Data = cell(1,1);
            obj.PlotOptions.Filename = 'untitled';
            obj.PlotOptions.Fileopt = 'new';
            obj.PlotOptions.World_Readable = true;
            obj.PlotOptions.Open_URL = false;
            obj.UserData.Credentials = loadplotlycredentials;
            obj.UserData.Configuration = loadplotlyconfig;
            obj.State.Verbose = false;
            obj.State.FigureHandle = fig;
            obj.State.AxisHandle(1) = ax;
            obj.State.CurrentAxisHandleIndex = 1;
            obj.State.DataHandle(1) = NaN;
            obj.State.CurrentDataHandleIndex = 1;
            obj.State.Data2AxisMap = [];
            
            for a = 1:2:nargin
                if(strcmpi(varargin{a},'filename'))
                    obj.PlotOptions.Filename = varargin{a+1};
                end
                if(strcmpi(varargin{a},'fileopt'))
                    obj.PlotOptions.Fileopt= varargin{a+1};
                end
                if(strcmpi(varargin{a},'world_readable'))
                    obj.PlotOptions.World_Readable = varargin{a+1};
                end
                if(strcmpi(varargin{a},'open'))
                    obj.PlotOptions.Open_URL = varargin{a+1};
                end
                if(strcmpi(varargin{a},'layout'))
                    obj.Layout= varargin{a+1};
                end
                if(strcmpi(varargin{a},'data'))
                    obj.Data = varargin{a+1};
                end
            end
        end
        
        %all plotting functions
        function obj = plot(obj,varargin)
            
            try
                if ishandle(varargin{1})
                    if strcmp(get(varargin{1},'type'),'axes')
                        if ~ismember(varargin{1},obj.State.AxisHandle)
                            if(obj.State.Verbose)
                                fprintf(['\nOops! The axis handle specified does not match one recognized',...
                                    '\nwithin the current Plotly figure. The plot will be drawn on the current',...
                                    '\axis, whose handle is: ' num2str(obj.State.AxisHandle(end)) '\n\n']);
                            end
                            varargin{1} = obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex);
                        else
                            obj.State.CurrentAxisHandleIndex = find(varargin{1} == obj.State.AxisHandle);
                        end
                    end
                else
                    varargin{2:end+1} = varargin{:};
                    varargin{1} = obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex);
                end
            catch
                fprintf(['Oops! Something went wrong while looking for the axis handle',...
                    'associated with this plot. Please make sure the axis handle specified',...
                    'is a child of the Plotly figure, whose handle is: ' num2str(obj.State.FigureHandle)]);
            end
            
            %check for hold to either erase or update
            switch get(obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex),'NextPlot')
                case 'add'
                    obj.State.CurrentDataHandleIndex = obj.State.CurrentDataHandleIndex + 1;
                case 'replace'
                    % Reset all axes properties except Position to their defaults and delete all axes children before displaying graphics (equivalent to cla reset)
                case 'replacechildren'
                    %Remove all child objects, but do not reset axes properties (equivalent to cla).
                otherwise
            end
            
            %map DataHandle to AxisHandle
            obj.State.Data2AxisMap(obj.State.CurrentDataHandleIndex) = obj.State.CurrentAxisHandleIndex;
            %make the plot and grab the data handle
            obj.State.DataHandle(obj.State.CurrentDataHandleIndex) = plot(varargin{:});
            %update data
            obj.Data = extractPlotData(obj);
            %update layout
            obj.Layout = extractPlotLayout(obj);
        end
    end
end


%------TODO------%

%title
%xlabel
%ylabel
%set/get
%subplot
%plot
%scatter
%bar
%contour
%hist
%imagesc
%polar
%global plot command

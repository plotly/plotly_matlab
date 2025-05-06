classdef plotlyfig < handle
    properties
        data; % data of the plot
        layout; % layout of the plot
        frames; % for animations
        url; % url response of making post request
        error; % error response of making post request
        warning; % warning response of making post request
        message; % message response of making post request
    end

    properties (SetObservable)
        UserData; % credentials/configuration/verbose
        PlotOptions; % filename,fileopt,world_readable
    end

    properties (Hidden = true)
        PlotlyDefaults; % plotly specific conversion defaults
        State; % state of plot (FIGURE/AXIS/PLOTS)
    end

    properties (Access = private)
        PlotlyReference; % load the plotly reference
        InitialState; % initial userdata
    end

    methods
        function obj = plotlyfig(varargin)
            %-Core-%
            obj.data = {};
            obj.layout = struct();
            obj.frames = {};
            obj.url = '';

            obj.UserData.Verbose = true;

            obj.PlotOptions = struct( ...
                "CleanFeedTitle", true, ...
                "FileName", '', ...
                "FileOpt", 'new', ...
                "WorldReadable", true, ...
                "ShowURL", true, ...
                "OpenURL", true, ...
                "Strip", false, ...
                "WriteFile", true, ...
                "Visible", 'on', ...
                "TriangulatePatch", false, ...
                "StripMargins", false, ...
                "TreatAs", {{'_'}}, ...
                "Image3D", false, ...
                "ContourProjection", false, ...
                "AxisEqual", false, ...
                "AspectRatio", [], ...
                "CameraEye", [], ...
                "is_headmap_axis", false, ...
                "FrameDuration", 1, ... % in ms.
                "FrameTransitionDuration", 0, ... % in ms.
                "geoRenderType", 'geo', ...
                "DomainFactor", [1 1 1 1] ...
            );

            % offline options
            obj.PlotOptions.Offline = true;
            obj.PlotOptions.ShowLinkText = true;
            obj.PlotOptions.LinkText = obj.get_link_text;
            obj.PlotOptions.IncludePlotlyjs = true;
            obj.PlotOptions.SaveFolder = pwd;

            try
                [obj.UserData.Username,...
                    obj.UserData.ApiKey,...
                    obj.UserData.PlotlyDomain] = signin;
            catch
                idx=find(cellfun(@(x) strcmpi(x,'offline'), varargin))+1;
                if (nargin>1 && ~isempty(idx) && varargin{idx}) || (obj.PlotOptions.Offline)
                    obj.UserData.Username = 'offlineUser';
                    obj.UserData.ApiKey = '';
                    obj.UserData.PlotlyDomain = 'https://plot.ly';
                else
                    errkey = 'plotlyfigConstructor:notSignedIn';
                    error(errkey, plotlymsg(errkey));
                end
            end

            obj.PlotlyDefaults = struct( ...
                "MinTitleMargin", 10, ...
                "TitleHeight", 0.01, ...
                "TitleFontSizeIncrease", 40, ...
                "FigureIncreaseFactor", 1.5, ...
                "AxisLineIncreaseFactor", 1.5, ...
                "MarginPad", 0, ...
                "MaxTickLength", 20, ...
                "ExponentFormat", 'none', ...
                "ErrorbarWidth", 6, ...
                "ShowBaselineLegend", false, ...
                "Bargap", 0, ...
                "CaptionMarginIncreaseFactor", 1.2, ...
                "MinCaptionMargin", 80, ...
                "IsLight", false, ...
                "isGeoaxis", false, ...
                "isTernary", false ...
            );

            obj.State = struct( ...
                "Axis", [], ...
                "Plot", [], ...
                "Text", [], ...
                "Legend", [], ...
                "Colorbar", [], ...
                ... % figure object management
                "Figure", struct( ...
                    "NumAxes", 0, ...
                    "NumPlots", 0, ...
                    "NumLegends", 0, ...
                    "NumColorbars", 0, ...
                    "NumTexts", 0 ...
                ) ...
            );

            obj.PlotlyReference = [];

            obj.InitialState = struct( ...
                "Username", obj.UserData.Username, ...
                "ApiKey", obj.UserData.ApiKey, ...
                "PlotlyDomain", obj.UserData.PlotlyDomain ...
            );

            [fig_han,updatekey,noFig] = obj.parseInputs(varargin);

            if ~noFig
                % create figure/axes if empty
                if isempty(fig_han)
                    fig_han = figure;
                    axes;
                end

                % plotly figure default style
                fig_han.Name = obj.PlotOptions.FileName;
                fig_han.Color = [1 1 1];
                fig_han.NumberTitle = 'off';
                fig_han.Visible = obj.PlotOptions.Visible;

                % figure state
                obj.State.Figure.Handle = fig_han;
            end

            if updatekey
                obj.update;
            end

            if ~noFig
                addlistener(obj.State.Figure.Handle,'Visible','PostSet',@(src,event)updateFigureVisible(obj,src,event));
                addlistener(obj.State.Figure.Handle,'Name','PostSet',@(src,event)updateFigureName(obj,src,event));
                addlistener(obj,'PlotOptions','PostSet',@(src,event)updatePlotOptions(obj,src,event));
                addlistener(obj,'UserData','PostSet',@(src,event)updateUserData(obj,src,event));
            end
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

        %----KEEP THE MATLAB STYLE DEFAULTS----%
        function obj = revert(obj)
            obj.PlotOptions.Strip = false;
            obj.update;
        end

        %----STRIP THE STYLE DEFAULTS----%
        function obj = strip(obj)
            obj.PlotOptions.Strip = true;
            obj.loadplotlyref;

            % strip the style keys from data
            for d = 1:length(obj.data)
                if contains(lower(obj.data{d}.type), ["scatter" "contour" "bar"])
                    return
                end
                obj.data{d} = obj.stripkeys(obj.data{d}, obj.data{d}.type, 'style');
            end

            % strip the style keys from layout
            obj.layout = obj.stripkeys(obj.layout, 'layout', 'style');
        end

        %----GET THE FIELDS OF TYPE DATA----%
        function data = getdata(obj)
            obj.loadplotlyref;

            % initialize output
            data = cell(1,length(obj.data));

            % remove style / plot_info types in data
            for d = 1:length(obj.data)
                data{d} = obj.stripkeys(obj.data{d}, obj.data{d}.type, {'style','plot_info'});
            end
        end

        %----VALIDATE THE DATA/LAYOUT KEYS----%
        function validate(obj)
            obj.loadplotlyref;

            % validate data fields
            for d = 1:length(obj.data)
                try
                    obj.stripkeys(obj.data{d}, obj.data{d}.type, {'style','plot_info'});
                catch
                    % TODO
                end
            end

            % validate layout fields
            obj.stripkeys(obj.layout, 'layout', 'style');
        end

        %----GET PLOTLY FIGURE-----%
        function obj = download(obj, file_owner, file_id)
            plotlyfig = plotlygetfile(file_owner, file_id);
            obj.data = plotlyfig.data;
            obj.layout = plotlyfig.layout;
        end

        %---------------------STATIC IMAGE METHODS------------------------%

        %----SAVE STATIC PLOTLY IMAGE-----%
        function obj = saveas(obj, filename, varargin)
            % strip keys
            if obj.PlotOptions.Strip
                obj.strip;
            end

            % handle title
            if isempty(filename)
                handleFileName(obj);
                filename = obj.PlotOptions.FileName;
            end

            % create image figure
            imgfig.data = obj.data;
            imgfig.layout = obj.layout;

            % save image
            plotlygenimage(imgfig, filename, varargin{:});
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

        %----ADD A CUSTOM CAPTION-----%
        function obj = add_caption(obj, caption_string, varargin)
            caption = struct( ...
                "text", caption_string, ...
                "xref", "paper", ...
                "yref", "paper", ...
                "xanchor", "left", ...
                "yanchor", "top", ...
                "x", 0.1, ...
                "y", -0.05, ...
                "showarrow", false ...
            );

            % inject any custom annotation specs
            for n = 1:2:length(varargin)
                caption.(varargin{n}) = varargin{n+1};
            end

            % adjust the bottom margin
            obj.layout.margin.b = max(obj.layout.margin.b, ...
                    obj.PlotlyDefaults.MinCaptionMargin);

            % add the new caption to the figure
            obj.State.Figure.NumTexts = obj.State.Figure.NumTexts + 1;
            obj.layout.annotations{obj.State.Figure.NumTexts} = caption;

            % update the figure state
            obj.State.Text(obj.State.Figure.NumTexts).Handle = NaN;
            obj.State.Text(obj.State.Figure.NumTexts).AssociatedAxis = gca;
            obj.State.Text(obj.State.Figure.NumTexts).Title = false;
        end

        %------------------------REST API CALL----------------------------%

        %----SEND PLOT REQUEST (NO UPDATE)----%
        function obj = plotly(obj)
            % strip keys
            if obj.PlotOptions.Strip
                obj.strip;
            end

            % strip margins
            if obj.PlotOptions.StripMargins
                obj.layout.margin.l = 0;
                obj.layout.margin.r = 0;
                obj.layout.margin.b = 0;
                obj.layout.margin.t = 0;
            end

            % validate keys
            validate(obj);

            handleFileName(obj);

            % handle title (for feed)
            if obj.PlotOptions.CleanFeedTitle
                try
                    cleanFeedTitle(obj);
                catch
                    % TODO to the future
                end
            end

            args.filename = obj.PlotOptions.FileName;
            args.fileopt = obj.PlotOptions.FileOpt;
            args.world_readable = obj.PlotOptions.WorldReadable;
            args.offline = obj.PlotOptions.Offline;

            args.layout = obj.layout;

            if obj.PlotOptions.WriteFile
                % send to plotly
                if ~obj.PlotOptions.Offline
                    response = plotly(obj.data, args);

                    % update response
                    obj.url = response.url;
                    obj.error = response.error;
                    obj.warning = response.warning;
                    obj.message = response.message;

                    % open url in browser
                    if obj.PlotOptions.OpenURL
                        web(response.url, '-browser');
                    end
                else
                    obj.url = plotlyoffline(obj);
                    if obj.PlotOptions.OpenURL
                        web(obj.url, '-browser');
                    end
                end
            end
        end

        %-----------------------FIGURE CONVERSION-------------------------%

        % automatic figure conversion
        function obj = update(obj)
            % reset figure object count
            obj.State.Figure.NumAxes = 0;
            obj.State.Figure.NumPlots = 0;
            obj.State.Figure.NumLegends = 0;
            obj.State.Figure.NumColorbars = 0;
            obj.State.Figure.NumTexts = 0;

            % check if there is tiledlayout
            try
                tiledLayoutStruct = obj.State.Figure.Handle.Children;
                isTiledLayout = strcmp(tiledLayoutStruct.Type, 'tiledlayout');
            catch
                isTiledLayout = false;
            end

            % find axes of figure
            ax = findobj(obj.State.Figure.Handle, ...
                {'Type','axes','-or','Type','PolarAxes'}, ...
                '-and',{'Tag','','-or','Tag','PlotMatrixBigAx', ...
                        '-or','Tag','PlotMatrixScatterAx', ...
                        '-or','Tag','PlotMatrixHistAx'});

            if isempty(ax)
                try
                    ax = obj.State.Figure.Handle.Children;
                catch
                    error("No axes found"); %#ok<CPROP>
                end
            end

            %---------- checking the overlapping of the graphs -----------%
            temp_ax = ax;
            deleted_idx = 0;
            for i = 1:length(ax)
                for j = i:length(ax)
                    try
                        if ((mean(eq(ax(i).Position, ax(j).Position)) == 1) && (i~=j) && strcmp(ax(i).Children.Type, 'histogram'))
                            temp_plots = findobj(temp_ax(i),'-not','Type','Text','-not','Type','axes','-depth',1);
                            if isprop(temp_plots, 'FaceAlpha')
                                update_opac(i) = true;
                            else
                                update_opac(i) = false;
                            end
                            temp_ax(i).YTick = temp_ax(j- deleted_idx).YTick;
                            temp_ax(i).XTick = temp_ax(j- deleted_idx).XTick;
                            temp_ax(j - deleted_idx) = [];
                            deleted_idx = deleted_idx + 1;
                        end
                    catch
                        % TODO: error with ax(i).Children.Type. isfield is no enough
                    end
                end
            end
            ax = temp_ax;
            %---------- checking the overlapping of the graphs ------------%

            obj.State.Figure.NumAxes = length(ax);

            % update number of annotations (one title per axis)
            obj.State.Figure.NumTexts = length(ax);

            % find children of figure axes
            for a = 1:length(ax)
                % reverse axes
                axrev = length(ax) - a + 1;

                obj.State.Axis(a).Handle = ax(axrev);

                % add title
                try
                    obj.State.Text(a).Handle = ax(axrev).Title;
                    obj.State.Text(a).AssociatedAxis = handle(ax(axrev));
                    obj.State.Text(a).Title = true;
                    % Recommended use for subtitles is to append to the
                    % title https://github.com/plotly/plotly.js/issues/233
                    if isprop(ax(axrev),"Subtitle")
                        sub_handle = ax(axrev).Subtitle;
                        if ~isempty(sub_handle.String)
                            titleObj = ax(axrev).Title;
                            origTitle = titleObj.String;
                            oncleanup = onCleanup( ...
                                    @() set(titleObj,'String',origTitle));
                            obj.State.Text(a).Handle.String = [string( ...
                                    obj.State.Text(a).Handle.String) ...
                                    "<sub>"+sub_handle.String+"</sub>"];
                        end
                    end
                catch
                    % TODO
                end

                % find plots of figure
                plots = findobj(ax(axrev),'-not','Type','Text','-not','Type','axes','-depth',1);

                % get number of nbars for pie3
                if lower(obj.PlotOptions.TreatAs) == "pie3"
                    obj.PlotOptions.nbars{a} = 0;
                    for i = 1:length(plots)
                        if lower(obj.PlotOptions.TreatAs) == "surface"
                            obj.PlotOptions.nbars{a} = obj.PlotOptions.nbars{a} + 1;
                        end
                    end
                end

                % check if current axes have multiple y-axes
                try
                    obj.PlotlyDefaults.isMultipleYAxes(axrev) = length(ax(axrev).YAxis) == 2;
                catch
                    obj.PlotlyDefaults.isMultipleYAxes(axrev) = false;
                end

                % update structures for each plot in current axes
                for np = 1:length(plots)
                    % reverse plots
                    nprev = length(plots) - np + 1;

                    % update the plot fields
                    plotClass = lower(getGraphClass(plots(nprev)));

                    if ~ismember(plotClass, {'light', 'polaraxes'})
                        obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                        obj.State.Plot(obj.State.Figure.NumPlots).Handle = handle(plots(nprev));
                        obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = handle(ax(axrev));
                        obj.State.Plot(obj.State.Figure.NumPlots).Class = getGraphClass(plots(nprev));
                    else
                        obj.PlotlyDefaults.IsLight = true;
                    end
                end

                % this works for pareto
                if isempty(plots)
                    try
                        isPareto = length(ax) >= 2 & obj.State.Figure.NumPlots >= 2;
                        isBar = strcmpi(obj.State.Plot(obj.State.Figure.NumPlots).Class, 'line');
                        isLine = strcmpi(obj.State.Plot(obj.State.Figure.NumPlots-1).Class, 'bar');
                        isPareto = isPareto & isBar & isLine;
                    catch
                        isPareto = false;
                    end

                    if isPareto
                        obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = handle(ax(axrev));
                    else
                        obj.State.Figure.NumPlots = obj.State.Figure.NumPlots + 1;
                        obj.State.Plot(obj.State.Figure.NumPlots).Handle = {};
                        obj.State.Plot(obj.State.Figure.NumPlots).AssociatedAxis = handle(ax(axrev));
                        obj.State.Plot(obj.State.Figure.NumPlots).Class = 'nothing';
                    end
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
            if isHG2
                legs = findobj(obj.State.Figure.Handle,'Type','Legend');
            else
                legs = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','legend');
            end

            obj.State.Figure.NumLegends = length(legs);

            for g = 1:length(legs)
                obj.State.Legend(g).Handle = handle(legs(g));

                % find associated axis
                legendAxis = findLegendAxis(obj, handle(legs(g)));

                % update colorbar associated axis
                obj.State.Legend(g).AssociatedAxis = legendAxis;
            end

            % find colorbar of figure
            if isHG2
                cols = findobj(obj.State.Figure.Handle,'Type','Colorbar');
            else
                cols = findobj(obj.State.Figure.Handle,'Type','axes','-and','Tag','Colorbar');
            end

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

            obj.data = {};
            obj.PlotOptions.nPlots = obj.State.Figure.NumPlots;
            obj.PlotlyDefaults.anIndex = obj.State.Figure.NumTexts;

            obj.layout = struct();
            obj.layout.annotations = {};

            updateFigure(obj);

            % update axes
            for n = 1:obj.State.Figure.NumAxes
                nrev = length(ax) - n + 1;
                if ismember(ax(nrev).Type,specialAxisPlots())
                    continue
                end
                if ~obj.PlotlyDefaults.isMultipleYAxes(n)
                    updateAxis(obj,n);
                else
                    for yax = 1:2
                        updateAxisMultipleYAxes(obj,n,yax);
                    end
                end
            end

            % update plots
            for n = 1:obj.State.Figure.NumPlots
                updateData(obj,n);
            end

            % update annotations
            for n = 1:obj.State.Figure.NumTexts
                try
                    if obj.PlotOptions.is_headmap_axis
                        updateHeatmapAnnotation(obj,n);
                        obj.PlotOptions.CleanFeedTitle = false;
                    elseif obj.PlotlyDefaults.isGeoaxis
                        % TODO
                    else
                        if ~obj.PlotlyDefaults.isTernary
                            obj.layout.annotations{end+1} = updateAnnotation(obj,n);

                            if obj.State.Figure.NumAxes == 1
                                obj.PlotOptions.CleanFeedTitle = false;
                            end
                        end
                    end
                catch
                    % TODO
                end
            end

            if isTiledLayout
                updateTiledLayoutAnnotation(obj, tiledLayoutStruct);
            end

            if obj.State.Figure.NumLegends < 2
                for n = 1:obj.State.Figure.NumLegends
                    if lower(obj.PlotOptions.TreatAs) ~= "pie3"
                        updateLegend(obj,n);
                    end
                end
            else
                updateLegendMultipleAxes(obj,1);
            end

            for n = 1:obj.State.Figure.NumColorbars
                if ~obj.PlotlyDefaults.isTernary
                    updateColorbar(obj,n);
                else
                    updateTernaryColorbar(obj,n);
                end
            end
        end

        %----------------------EXTRACT PLOTLY INDICES---------------------%

        function currentAxisIndex = getAxisIndex(obj,axishan)
            currentAxisIndex = find(arrayfun(@(x)(eq(x.Handle,axishan)),obj.State.Axis));
        end

        function currentDataIndex = getDataIndex(obj,plothan)
            currentDataIndex = find(arrayfun(@(x)(eq(x.Handle,plothan)),obj.State.Plot));
        end

        function currentAnnotationIndex = getAnnotationIndex(obj,annothan)
            currentAnnotationIndex = find(arrayfun(@(x)(eq(x.Handle,annothan)),obj.State.Text));
        end

        %---------------------CALLBACK FUNCTIONS--------------------------%

        %----UPDATE FIGURE OPTIONS----%
        function obj = updateFigureVisible(obj,src,event)
            obj.PlotOptions.Visible = obj.State.Figure.Handle.Visible;
        end

        function obj = updateFigureName(obj,src,event)
            obj.PlotOptions.FileName = obj.State.Figure.Handle.Name;
        end

        %----UPDATE PLOT OPTIONS----%
        function obj = updatePlotOptions(obj,src,event)
            set(obj.State.Figure.Handle, 'Name', obj.PlotOptions.FileName, 'Visible', obj.PlotOptions.Visible);
        end

        %----UPDATE USER DATA----%
        function obj = updateUserData(obj,src,event)
            signin(obj.UserData.Username,...
                obj.UserData.ApiKey,...
                obj.UserData.PlotlyDomain);
        end

        %-------------------OVERLOADED FUNCTIONS--------------------------%

        %----PLOT FUNCTIONS----%
        function han = image(obj, varargin)
            han = image(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = imagesc(obj, varargin)
            han = imagesc(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = line(obj, varargin)
            han = line(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = patch(obj, varargin)
            han = patch(varargin{:});
            obj.update;
        end

        function han = rectangle(obj, varargin)
            han = rectangle(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = area(obj,varargin)
            han = area(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = bar(obj,varargin)
            han = bar(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = contour(obj,varargin)
            han = contour(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = plot(obj,varargin)
            han = plot(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = errorbar(obj,varargin)
            han = errorbar(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = quiver(obj,varargin)
            han = quiver(varargin{:});
            obj.update;
        end

        function han = scatter(obj, varargin)
            han = scatter(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = stairs(obj,varargin)
            han = stairs(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = stem(obj,varargin)
            han = stem(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = boxplot(obj,varargin)
            han = boxplot(varargin{:});
            obj.update;
            obj.plotly;
        end

        function han = mesh(obj,varargin)
            han = mesh(varargin{:});
            obj.update;
            obj.plotly;
        end

        function [y,t,x] = initial(obj,varargin)
            % plot initial
            initial(varargin{:});
            % call initial
            [y,t,x] = initial(varargin{:});
            % fake output by calling plot
            plot(t,y);
            % update object
            obj.update;
            % send to plotly
            obj.plotly;
        end

        %----OTHER----%
        function delete(obj)
            % reset persistent USERNAME, KEY, and DOMAIN
            % of signin to original state
            if isfield(obj.InitialState,'Username')
                signin(obj.InitialState.Username, ...
                    obj.InitialState.ApiKey,...
                    obj.InitialState.PlotlyDomain);
            end
        end
    end

    methods (Access=private)
        %----STRIP THE FIELDS OF A SPECIFIED KEY-----%
        function stripped = stripkeys(obj, fields, fieldname, key)
            % plorlt reference
            pr = obj.PlotlyReference;

            stripped = fields;

            fn = fieldnames(stripped);
            fnmod = fn;

            try
                for d = 1:length(fn)
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
                            annot = stripped.(fn{d});
                            fnmod{d} = 'annotation';
                            for a = 1:length(annot)
                                % recursive call to stripkeys
                                stripped.annotations{a} = obj.stripkeys(annot{a}, fnmod{d}, key);
                            end
                        else
                            % recursive call to stripkeys
                            stripped.(fn{d}) = obj.stripkeys(stripped.(fn{d}), fnmod{d}, key);
                        end

                        % look for desired key and strip if not an exception
                    elseif any(strcmp(keytype, key))
                        if ~isExceptionStrip(stripped,fn{d})
                            stripped = rmfield(stripped, fn{d});
                        end
                    end
                end

                %----CLEAN UP----%
                remfn = fieldnames(stripped);

                for n = 1:length(remfn)
                    if isstruct(stripped.(remfn{n}))
                        if isempty(fieldnames(stripped.(remfn{n})))
                            stripped = rmfield(stripped,remfn{n});
                        end
                    elseif isempty(stripped.(remfn{n}))
                        stripped = rmfield(stripped,remfn{n});
                    end
                end

                %---HANDLE ERRORS---%
            catch exception
                if obj.UserData.Verbose
                    % catch 3D output until integrated into graphref
                    validFields = {'surface', 'scatter3d', 'mesh3d', ...
                            'bar', 'scatterpolar', 'barpolar', 'scene', ...
                            'layout', 'heatmap', 'xaxis', 'yaxis', ...
                            'cone', 'legend', 'histogram', 'scatter', ...
                            'line', 'scattergeo', 'scattermapbox', ...
                            'scatterternary', 'colorbar', 'contours'};
                    if ~ismember(fieldname, validFields)
                        fprintf(['\nWhoops! ' ...
                                exception.message(1:end-1) ' in ' ...
                                fieldname '\n\n']);
                    end
                end
            end
        end

        function link_text = get_link_text(obj)
            if obj.PlotOptions.Offline
                plotly_domain = 'https://plot.ly';
            else
                plotly_domain = obj.UserData.PlotlyDomain;
            end
            link_domain = strrep(plotly_domain, 'https://', '');
            link_domain = strrep(link_domain, 'http://', '');
            link_text = ['Export to ' link_domain];
        end

        function [fig_han,updatekey,noFig] = parseInputs(obj,varargs)
            % initialize figure handle
            fig_han = [];

            % initialize autoupdate key
            updatekey = false;

            noFig = false;
            nargs = numel(varargs);

            switch nargs
                case 0
                case 1
                    % check for figure handle
                    if ishandle(varargs{1})
                        if strcmp(get(varargs{1},'type'),'figure')
                            fig_han = varargs{1};
                            updatekey = true;
                        end
                    else
                        errkey = 'plotlyfigConstructor:invalidInputs';
                        error(errkey , plotlymsg(errkey));
                    end
                otherwise
                    % check for figure handle
                    if ishandle(varargs{1})
                        if strcmp(get(varargs{1},'type'),'figure')
                            fig_han = varargs{1};
                            updatekey = true;
                            parseinit = 2;
                        end
                    elseif iscell(varargs{1}) && isstruct(varargs{2})
                        obj.data = varargs{1}{:};
                        structargs = varargs{2};
                        ff=fieldnames(structargs);
                        for i=1:length(ff)
                            varargs{2*i-1}=ff{i};
                            varargs{2*i}=structargs.(ff{i});
                        end
                        noFig=true;
                        parseinit = 1;
                    else
                        parseinit = 1;
                    end

                    % check for proper property/value structure
                    if mod(length(parseinit:nargs),2) ~= 0
                        errkey = 'plotlyfigConstructor:invalidInputs';
                        error(errkey , plotlymsg(errkey));
                    end

                    % parse property/values
                    for a = parseinit:2:length(varargs)
                        property = lower(varargs{a});
                        value = varargs{a+1};
                        switch property
                            case "filename"
                                obj.PlotOptions.FileName = value;
                                % overwrite if filename provided
                                obj.PlotOptions.FileOpt = 'overwrite';
                            case "savefolder"
                                obj.PlotOptions.SaveFolder = value;
                            case "fileopt"
                                obj.PlotOptions.FileOpt = value;
                            case "world_readable"
                                obj.PlotOptions.WorldReadable = value;
                            case "link"
                                obj.PlotOptions.ShowURL = value;
                            case "open"
                                obj.PlotOptions.OpenURL = value;
                            case "strip"
                                obj.PlotOptions.Strip = value;
                            case "writefile"
                                obj.PlotOptions.WriteFile = value;
                            case "visible"
                                obj.PlotOptions.Visible = value;
                            case "offline"
                                obj.PlotOptions.Offline = value;
                            case "showlink"
                                obj.PlotOptions.ShowLinkText = value;
                            case "linktext"
                                obj.PlotOptions.LinkText = value;
                            case "include_plotlyjs"
                                obj.PlotOptions.IncludePlotlyjs = value;
                            case "layout"
                                obj.layout= value;
                            case "data"
                                obj.data = value;
                            case "stripmargins"
                                obj.PlotOptions.StripMargins = value;
                            case "triangulatepatch"
                                obj.PlotOptions.TriangulatePatch = value;
                            case "treatas"
                                if ~iscell(value)
                                    obj.PlotOptions.TreatAs = {value};
                                else
                                    obj.PlotOptions.TreatAs = value;
                                end
                            case "axisequal"
                                obj.PlotOptions.AxisEqual = value;
                            case "aspectratio"
                                obj.PlotOptions.AspectRatio = value;
                            case "cameraeye"
                                obj.PlotOptions.CameraEye = value;
                            case "quality"
                                obj.PlotOptions.Quality = value;
                            case "zmin"
                                obj.PlotOptions.Zmin = value;
                            case "frameduration"
                                if value > 0
                                    obj.PlotOptions.FrameDuration = value;
                                end
                            case "frametransitionduration"
                                if value >= 0
                                    obj.PlotOptions.FrameTransitionDuration = value;
                                end
                            case "georendertype"
                                obj.PlotOptions.geoRenderType = value;
                            case "domainfactor"
                                len = length(value);
                                obj.PlotOptions.DomainFactor(1:len) = value;
                            otherwise
                                warning("Unrecognized property name ""%s""", property);
                        end
                    end
            end
        end
    end
end

function response = plotlyoffline(plotlyfig)
    % Generate offline Plotly figure saved as an html file within
    % the current working directory. The file will be saved as:
    % 'plotlyfig.PlotOptions.FileName'.html.

    % create dependency string unless not required
    if plotlyfig.PlotOptions.IncludePlotlyjs
        % grab the bundled dependencies
        userHome = getuserdir();
        plotlyConfigFolder = fullfile(userHome,'.plotly');
        plotlyJSFolder = fullfile(plotlyConfigFolder, 'plotlyjs');
        bundleName = 'plotly-matlab-offline-bundle.js';
        bundleFile = fullfile(plotlyJSFolder, bundleName);

        % check that the bundle exists
        try
            bundle = fileread(bundleFile);
            % template dependencies
            depScript = sprintf(['<script type="text/javascript">' ...
                '%s</script>\n'], bundle);
        catch
            error(['Error reading: %s.\nPlease download the required ', ...
                   'dependencies using: >>getplotlyoffline \n', ...
                   'or contact support@plot.ly for assistance.'], ...
                   bundleFile);
        end
    else
        depScript = '';
    end

    % handle plot div specs
    if is_octave()
        id = sprintf('plotly-%d', floor(rand*1e15));
    else
        id = char(java.util.UUID.randomUUID);
    end
    width = sprintf('%gpx', plotlyfig.layout.width);
    height = sprintf('%gpx', plotlyfig.layout.height);

    if plotlyfig.PlotOptions.ShowLinkText
        linkText = plotlyfig.PlotOptions.LinkText;
    else
        linkText = '';
    end

    % format the data and layout
    jData = m2json(plotlyfig.data);
    jLayout = m2json(plotlyfig.layout);
    jFrames = m2json(plotlyfig.frames);

    % template environment vars
    plotlyDomain = plotlyfig.UserData.PlotlyDomain;
    envScript = sprintf(['<script type="text/javascript">', ...
            'window.PLOTLYENV=window.PLOTLYENV || {};', ...
            'window.PLOTLYENV.BASE_URL="%s";Plotly.LINKTEXT="%s";', ...
            '</script>'], plotlyDomain, linkText);

    % template Plotly.plot
    script = sprintf(['\n Plotly.newPlot("%s", {\n"data": %s,' ...
            '\n"layout": %s,\n"frames": %s\n}).then(function(){'...
            '\n    if (typeof $ !== "undefined") {' ...
            '\n    $(".%s.loading").remove();' ...
            '\n    $(".link--embedview").text("%s");'...
            '\n    }' ...
            '\n    });'], id, jData, jLayout, ...
            jFrames, id, linkText);

    plotlyScript = sprintf(['\n<div id="%s" style="height: %s;', ...
            'width: %s;" class="plotly-graph-div"></div> \n', ...
            '<script type="text/javascript">%s \n</script>'], ...
            id, height, width, script);

    % template entire script
    offlineScript = [depScript envScript plotlyScript];
    filename = plotlyfig.PlotOptions.FileName;
    if iscellstr(filename)
        filename = sprintf('%s ', filename{:});
    end

    % remove the whitespace from the filename
    cleanFilename = filename(filename~=' ');
    htmlFilename = [cleanFilename '.html'];

    % save the html file in the working directory
    plotlyOfflineFile = fullfile(plotlyfig.PlotOptions.SaveFolder, ...
            htmlFilename);
    fileID = fopen(plotlyOfflineFile, 'w');
    fprintf(fileID, '%s', offlineScript);
    fclose(fileID);

    % remove any whitespace from the plotlyOfflineFile path
    plotlyOfflineFile = strrep(plotlyOfflineFile, ' ', '%20');

    % return the local file url to be rendered in the browser
    response = ['file:///' plotlyOfflineFile];
end

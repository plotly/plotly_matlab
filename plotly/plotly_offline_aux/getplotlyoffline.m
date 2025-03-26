function getplotlyoffline(plotly_bundle_url)
    try
        % download bundle
        plotly_bundle = webread(plotly_bundle_url);
    catch exception
        disp("Whoops! There was an error attempting to download the " ...
                + "MATLAB offline Plotly bundle");
        rethrow(exception);
    end

    % create Plotly config folder
    userhome = getuserdir();
    plotly_config_folder = fullfile(userhome, '.plotly');
    [status, mess, messid] = mkdir(plotly_config_folder);
    validatedir(status, mess, messid, 'plotly');

    % create plotlyjs folder
    plotly_js_folder = fullfile(plotly_config_folder, 'plotlyjs');
    [status, mess, messid] = mkdir(plotly_js_folder);
    validatedir(status, mess, messid, 'plotlyjs');

    % save bundle
    bundle = escapechars(plotly_bundle);
    bundle_name = 'plotly-matlab-offline-bundle.js';
    bundle_file = fullfile(plotly_js_folder, bundle_name);
    file_id = fopen(bundle_file, 'w');
    fprintf(file_id, '%s', bundle);
    fclose(file_id);

    % success!
    fprintf(['\nSuccess! You can now generate offline ', ...
             'graphs.\nTo generate online graphs, run ', ...
             'plotlysetup_online(username, api_key) ', ...
             '\nand use the ''offline'' flag of fig2plotly as ', ...
             'follows:\n\n>> plot(1:10); fig2plotly(gcf, ', ...
             '''offline'', false);\n\n'])
end

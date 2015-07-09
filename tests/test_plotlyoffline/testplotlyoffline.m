classdef testplotlyoffline < matlab.unittest.TestCase
    
    properties
        creds = loadplotlycredentials;
        config = loadplotlyconfig;
        username = 'test_user_name';
        api_key = 'test_api_keu';
        plotly_domain = 'test_plotly_domain';
    end
    
    methods(TestMethodTeardown)
        function setCredentials(testCase)
            saveplotlycredentials(testCase.creds.username, ...
                                  testCase.creds.api_key, ...
                                  testCase.creds.stream_ids);
        end
        function setConfig(testCase)
            saveplotlyconfig(testCase.config.plotly_domain, ...
                             testCase.config.plotly_streaming_domain);
        end
    end
    
    methods (Test)
       
        function testGetPlotlyOfflineInvalidLink(testCase)
            
            invalid_link = 'http://purchasing.plot.ly/invalid';       
            actual = 'this should get modified'; 
            
            try
                getplotlyoffline(invalid_link);
            catch exception
                actual = exception.message;
            end
            
            expected = ['Whoops! There was an error attempting to ', ...
                        'download the MATLAB offline Plotly bundle. ', ...
                        'Status: 404 NOT FOUND.'];
            
           testCase.verifyEqual(actual,expected); 
        end
        
        function testGetPlotlyOfflineCreateDir(testCase)
            
            % get plotlyjs dir
            userhome = getuserdir();
            plotly_config_folder = fullfile(userhome, '.plotly');
            plotly_js_folder = fullfile(plotly_config_folder, 'plotlyjs');
            
            test_link = ['https://gist.githubusercontent.com/chriddyp', ...
            '/f40bd33d1eab6f0715dc/raw/24cd2e4e62ceea79e6', ...
            'e790b3a2c94cda63510ede/test.js']; 
        
            getplotlyoffline(test_link);
            js_folder_exists = (exist(plotly_js_folder, 'dir') == 7); 
            testCase.verifyTrue(js_folder_exists); 
        end 
        
        function testPlotlyOffline(testCase)
            test_filename = 'test_offline';
            p = plotlyfig('visible', 'off', 'filename', test_filename); 
            p.layout.width = 0; 
            p.layout.height = 0; 
            plotlyoffline(p); 
            test_file = fullfile(pwd, strcat(test_filename, '.html')); 
            html_file_exists = (exist(test_file, 'file') == 2); 
            testCase.verifyTrue(html_file_exists);
            delete(test_file); 
        end    
        
        function testPlotlyOfflineNoBundle(testCase)
            
            actual = 'this should get modified'; 
            
            % get plotlyjs dir
            userhome = getuserdir();
            plotly_config_folder = fullfile(userhome, '.plotly');
            plotly_js_folder = fullfile(plotly_config_folder, 'plotlyjs');
            bundle_name = 'plotly-matlab-offline-bundle.js'; 
            delete(fullfile(plotly_js_folder, bundle_name))
            
            p = plotlyfig('visible', 'off'); 
            
            try
                plotlyoffline(p);
            catch exception
                actual = exception.message; 
            end
            
            expected = sprintf(['Error reading: /Users/bronsolo/', ...
                                '.plotly/plotlyjs/plotly-matlab-', ...
                                'offline-bundle.js.\nPlease download ', ...
                                'the required dependencies using: ', ...
                                '>>getplotloffline \nor contact ', ...
                                'support@plot.ly for assistance.']);
                    
            testCase.verifyEqual(actual,expected); 
        end    
    end
end



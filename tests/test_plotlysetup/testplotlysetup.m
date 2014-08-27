classdef testplotlysetup < matlab.unittest.TestCase
    
    %NOTE: read and write permission on all plotly/matlab toolbox paths
    %required to run testplotlysetup.m
    
    properties
        creds = loadplotlycredentials;
        config = loadplotlyconfig;
        username = 'test_user_name';
        api_key = 'test_api_keu';
        stream_ids = {'test_stream_key1','test_stream_key2'};
        plotly_domain = 'test_plotly_domain';
        plotly_streaming_domain = 'test_plotly_streaming_domain';
    end
    
    methods(TestMethodTeardown)
        function setCredentials(testCase)
            saveplotlycredentials(testCase.creds.username,testCase.creds.api_key,testCase.creds.stream_ids);
        end
        function setConfig(testCase)
            saveplotlyconfig(testCase.config.plotly_domain,testCase.config.plotly_streaming_domain);
        end
    end
    
    methods (Test)
        
        %test wrong number of inputs 
        function testPlotlyWrongNumInputs(testCase)
            except = plotlysetup;
            actual = except.identifier;
            expected = 'plotly:wrongInput';
            testCase.verifyEqual(actual,expected);
        end
        
        %test plotly not found 
        function testPlotlyNotFound(testCase)
            plotlysetupPath = which('plotlysetup');
            plotlyDirOld = fullfile(fileparts(plotlysetupPath),'plotly');
            rmpath(genpath(plotlyDirOld));
            plotlyDirHide = fullfile(pwd,'hidden_plotly');
            mkdir(plotlyDirHide);
            movefile(plotlyDirOld,plotlyDirHide);
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:notFound';
            testCase.verifyEqual(actual,expected);
            plotlyDirNew = fullfile(plotlyDirHide,'plotly');
            movefile(plotlyDirNew,plotlyDirOld);
            rmdir(plotlyDirHide);
            addpath(genpath(plotlyDirOld));
        end
        
        %test clean write of Plotly to MATLAB toolbox
        function testCleanWrite(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            plotlysetup(testCase.username,testCase.api_key);
            actual = exist(fullfile(plotlyToolboxDir,'plotly.m'),'file');
            expected = 2;
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test overwrite files in Plotly of MATLAB toolbox 
        function testOverwrite(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if ~exist(plotlyToolboxDir,'dir')
                mkdir(plotlyToolboxDir)
                existed = false;
            else
                existed = true;
            end
            
            plotlyDir = fullfile(pwd,'plotly');
            testOverwriteDir = fullfile(plotlyDir,'testOverwrite');
            mkdir(testOverwriteDir);
            
            %REQUIRES USER INPUT:
            fprintf('\n\nTESTING OVERWRITE: HIT Y + ENTER\n\n');
            plotlysetup(testCase.username,testCase.api_key);
            testOverwriteToolboxDir = fullfile(plotlyToolboxDir,'testOverwrite');
            actual = exist(testOverwriteToolboxDir,'dir');
            expected = 7;
            testCase.verifyEqual(actual,expected);
            rmpath(testOverwriteDir);
            rmdir(testOverwriteDir);
            if (actual == expected)
                rmpath(testOverwriteToolboxDir);
                rmdir(testOverwriteToolboxDir);
            end
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test no overwrite in Plotly of MATLAB toolbox 
        function testNoOverwrite(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if ~exist(plotlyToolboxDir,'dir')
                mkdir(plotlyToolboxDir)
                existed = false;
            else
                existed = true;
            end
            
            plotlyDir = fullfile(pwd,'plotly');
            testOverwriteDir = fullfile(plotlyDir,'testOverwrite');
            mkdir(testOverwriteDir);
            
            %REQUIRES USER INPUT:
            fprintf('\n\nTESTING NO OVERWRITE: HIT N + ENTER\n\n');
            plotlysetup(testCase.username,testCase.api_key);
            testOverwriteToolboxDir = fullfile(plotlyToolboxDir,'testOverwrite');
            actual = exist(testOverwriteToolboxDir,'dir');
            expected = 0;
            testCase.verifyEqual(actual,expected);
            rmpath(testOverwriteDir);
            rmdir(testOverwriteDir);
            if (actual ~= expected)
                rmpath(testOverwriteToolboxDir);
                rmdir(testOverwriteToolboxDir);
            end
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test make Plotly Dir with no permission attempt
        function testNoPermissionMakePlotly(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            
            %REMOVE WRITE PERMISSION
            fileattrib(fullfile(matlabroot,'toolbox'),'-w');
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:savePlotly';
            testCase.verifyEqual(actual,expected);
            
            %RESET WRITE PERMISSION
            fileattrib(fullfile(matlabroot,'toolbox'),'+w');
            plotlysetupPath = which('plotlysetup');
            plotlyFolderPath = fullfile(fileparts(plotlysetupPath),'plotly');
            copyfile(plotlyFolderPath,plotlyToolboxDir, 'f');
            addpath(genpath(plotlyToolboxDir));
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test copy plotly dir with no permission attempt 
        function testNoPermissionCopyPlotly(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if ~exist(plotlyToolboxDir,'dir')
                mkdir(plotlyToolboxDir)
                existed = false;
            else
                existed = true;
            end
            plotlysetupPath = which('plotlysetup');
            plotlyFolderPath = fullfile(fileparts(plotlysetupPath),'plotly');
            
            %remove write permission 
            fileattrib(plotlyToolboxDir,'-w');
            
            %requires user input:
            fprintf('\n\nTESTING OVERWRITE: HIT Y + ENTER\n\n');
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:copyPlotly';
            testCase.verifyEqual(actual,expected);
            
            %reset write permission 
            fileattrib(plotlyToolboxDir,'+w');
            copyfile(plotlyFolderPath,plotlyToolboxDir, 'f');
            addpath(genpath(plotlyToolboxDir));
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test read root startup with no permission attempt 
        function testNoPermissionReadStartup(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            startupFileRootPath = fullfile(matlabroot,'toolbox','local');
            startupLoc = fullfile(startupFileRootPath,'startup.m');
            if(exist(startupLoc,'file'))
                startupExisted = true;
                startupLocTemp = fullfile(startupFileRootPath,'startup_temp.m');
                copyfile(startupLoc,startupLocTemp);
                delete(startupLoc);
            else
                startupExisted = false;
            end
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            
            %remove write permission 
            fileattrib(startupFileRootPath,'-w')
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:startupRead';
            testCase.verifyEqual(actual,expected);
            
            %reset write permission 
            fileattrib(startupFileRootPath,'+w')
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
            if startupExisted
                copyfile(startupLocTemp,startupLoc);
                delete(startupLocTemp);
                addpath(genpath(startupFileRootPath));
            end
        end
        
        %test make root startup with no permission attempt 
        function testNoPermissionMakeStartup(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            startupFileRootPath = fullfile(matlabroot,'toolbox','local');
            startupLoc = fullfile(startupFileRootPath,'startup.m');
            if(exist(startupLoc,'file'))
                startupExisted = true;
                startupLocTemp = fullfile(startupFileRootPath,'startup_temp.m');
                copyfile(startupLoc,startupLocTemp);
                rmpath(genpath(startupFileRootPath));
                delete(startupLoc);
                addpath(genpath(startupFileRootPath));
            else
                startupExisted = false;
            end
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            
            %remove write permission 
            fileattrib(startupFileRootPath,'-w')
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:rootStartupCreation';
            testCase.verifyEqual(actual,expected);
            
            %reset write permission
            fileattrib(startupFileRootPath,'+w')
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
            if startupExisted
                copyfile(startupLocTemp,startupLoc);
                delete(startupLocTemp);
                addpath(genpath(startupFileRootPath));
            end
        end
        
        
        %test to write startup.m with no permission attempt
        function testNoPermissionWriteStartup(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            startupFileRootPath = fullfile(matlabroot,'toolbox','local');
            startupLoc = fullfile(startupFileRootPath,'startup.m');
            if(exist(startupLoc,'file'))
                startupExisted = true;
                startupLocTemp = fullfile(startupFileRootPath,'startup_temp.m');
                copyfile(startupLoc,startupLocTemp);
                rmpath(startupFileRootPath);
                delete(startupLoc);
                fopen(fullfile(startupFileRootPath,'startup.m'),'w');
                addpath(startupFileRootPath);
            else
                startupExisted = false;
            end
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            
            %remove write permission 
            fileattrib(startupLoc,'-w')
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = except.identifier;
            expected = 'plotly:startupWrite';
            testCase.verifyEqual(actual,expected);
            
            %reset write permission
            fileattrib(startupLoc,'+w')
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
            if startupExisted
                copyfile(startupLocTemp,startupLoc);
                delete(startupLocTemp);
                addpath(genpath(startupFileRootPath));
            end
        end
        
        %test Plotly already saved to startup warnings 
        function testStartupWarnings(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            startupFileRootPath = fullfile(matlabroot,'toolbox','local');
            startupLoc = fullfile(startupFileRootPath,'startup.m');
            startupLocTemp = fullfile(startupFileRootPath,'startup_temp.m');
            copyfile(startupLoc,startupLocTemp);
            
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            
            %write additional plotly line to startup.m 
            addString = 'plotly';
            fid = fopen(startupLoc,'a+');
            fprintf(fid,['\n' addString]);
            fclose(fid);
            except = plotlysetup(testCase.username,testCase.api_key);
            actual = isfield(except,'warnings');
            expected = true;
            testCase.verifyEqual(actual,expected);
            
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
            
            copyfile(startupLocTemp,startupLoc);
            delete(startupLocTemp);
            addpath(genpath(startupFileRootPath));
            
        end
        
        %test save username and api_key (required) 
        function testSaveUsernameAPIKey(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            plotlysetup(testCase.username,testCase.api_key);
            credentials = loadplotlycredentials;
            actual.username = credentials.username;
            actual.api_key = credentials.api_key;
            expected.username = testCase.username;
            expected.api_key = testCase.api_key;
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test save stream ids 
        function testSaveStreamIDS(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            plotlysetup(testCase.username,testCase.api_key,'stream_ids',testCase.stream_ids);
            credentials = loadplotlycredentials;
            actual.username = credentials.username;
            actual.api_key = credentials.api_key;
            actual.stream_ids = credentials.stream_ids;
            expected.username = testCase.username;
            expected.api_key = testCase.api_key;
            expected.stream_ids = testCase.stream_ids;
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test save plotly domain 
        function testSavePlotlyEndpointConfig(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            plotlysetup(testCase.username,testCase.api_key,'plotly_domain',testCase.plotly_domain);
            configuration = loadplotlyconfig;
            actual.plotly_domain = configuration.plotly_domain;
            expected.plotly_domain = testCase.plotly_domain;
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test save plotly stream endpoint 
        function testSavePlotlyStreamingEndpointConfig(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            plotlysetup(testCase.username,testCase.api_key,'plotly_streaming_domain',testCase.plotly_streaming_domain);
            configuration = loadplotlyconfig;
            actual.plotly_streaming_domain = configuration.plotly_streaming_domain;
            expected.plotly_streaming_domain = testCase.plotly_streaming_domain;
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test wrong varargin input
        function testWrongKW(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            except = plotlysetup(testCase.username,testCase.api_key,'plotly_streaming_domain',testCase.plotly_streaming_domain,'plotly_domain');
            actual = except.identifier;
            expected = 'plotly:wrongInputVarargin';
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
        
        %test unrecoginized property name
        function testWrongProperty(testCase)
            plotlyToolboxDir = fullfile(matlabroot,'toolbox','plotly');
            if exist(plotlyToolboxDir,'dir')
                existed = true;
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s')
            else
                existed = false;
            end
            except = plotlysetup(testCase.username,testCase.api_key,'plotly_stream_domain',testCase.plotly_streaming_domain);
            actual = except.identifier;
            expected = 'plotly:wrongInputPropertyName';
            testCase.verifyEqual(actual,expected);
            if ~existed
                rmpath(genpath(plotlyToolboxDir))
                rmdir(plotlyToolboxDir,'s');
            end
        end
    end
end



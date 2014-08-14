classdef testplotlyupdate < matlab.unittest.TestCase
    
    %NOTE: read and write permission on all plotly/matlab toolbox paths
    %required to run testplotlyupdate.m
    
    methods(TestMethodSetup)
        function setupPlotlyVersion(testCase)
            pv = which('plotly_version.m','-all');
            for d = 1:length(pv)
                copyfile(pv{d},fullfile(fileparts(pv{d}),'plotly_version_temp.m'));
            end
        end
    end
    
    methods(TestMethodTeardown)
        function tearDownPlotlyVersion(testCase)
            pvtemp = which('plotly_version_temp.m','-all');
            pv = which('plotly_version.m','-all');
            for d = 1:length(pv)
                copyfile(pvtemp{d},pv{d});
                delete(pvtemp{d});
            end
        end
    end
    
    methods (Test)
        
        %test no version found
        function testNoVersion(testCase)
            pv = which('plotly_version.m','-all');
            for d = 1:length(pv);
                rmpath(genpath(fileparts(pv{d})))
            end
            except = plotlyupdate;
            actual = except.identifier;
            expected = 'plotly:noVersion';
            testCase.verifyEqual(actual,expected);
            for d = 1:length(pv);
                addpath(genpath(fileparts(pv{d})))
            end
        end
        
        %test Plotly not found 
        function testPlotlyNotFound(testCase)
            ply = which('plotly.m','-all');
            pv = which('plotly_version.m');
            pu = which('plotlyupdate.m');
            for d = 1:length(ply);
                rmpath(genpath(fileparts(ply{d})))
            end
            addpath(genpath(fileparts(pv)));
            addpath(genpath(fileparts(pu)));
            except = plotlyupdate;
            actual = except.identifier;
            expected = 'plotly:missingScript';
            testCase.verifyEqual(actual,expected);
            for d = 1:length(ply);
                addpath(genpath(fileparts(ply{d})))
            end
        end
        
        %test Plotly already up to date 
        function testAlreadyUp2Date(testCase)
            % remote Plotly API MATLAB Library url
            remote = ['https://raw.githubusercontent.com/plotly/MATLAB-api/',...
                'master/plotly/plotly_aux/plotly_version.m'];
            pvContent = urlread(remote);
            pvBounds = strfind(pvContent,'''');
            pvRemote = pvContent(pvBounds(1)+1:pvBounds(2)-1);
            clear plotly_version.m
            testCase.setversion(pvRemote);
            except = plotlyupdate;
            actual = except.identifier;
            expected = 'plotly:alreadyUpdated';
            testCase.verifyEqual(actual,expected);
        end
        
        %test create temp update dir. no permission attempt 
        function testTempUpdateWriteNoPermission(testCase)
            %change plotly_version
            clear plotly_version.m;
            testCase.setversion('1.3.1');
            fileattrib(pwd,'-w');
            pu = which('plotlyupdate.m');
            addpath(genpath(fileparts(pu)));
            fprintf('\nTESTING UPDATE: HIT Y + ENTER\n\n');
            except = plotlyupdate;
            actual = except.identifier;
            expected = 'plotlyupdate:makeUpdateDir';
            testCase.verifyEqual(actual,expected);
            fileattrib(pwd,'+w');
        end
        
        %test proper update 
        function testProperUpdate(testCase)
            pvOld = '1.3.1';
            clear plotly_version.m;
            testCase.setversion(pvOld);
            remote = ['https://raw.githubusercontent.com/plotly/MATLAB-api/',...
                'master/plotly/plotly_aux/plotly_version.m'];
            pvContent = urlread(remote);
            pvBounds = strfind(pvContent,'''');
            pvRemote = pvContent(pvBounds(1)+1:pvBounds(2)-1);
            fprintf('\nTESTING UPDATE: HIT Y + ENTER\n\n');
            plotlyupdate;
            pv = which('plotly_version.m','-all');
            actual = cell(1,length(pv));
            expected = cell(1,length(pv));
            for d = 1:length(pv)
                clear plotly_version.m;
                actual{d} = plotly_version;
                expected{d} = pvRemote;
            end
            testCase.verifyEqual(actual,expected);
        end
        
        %test no overwrite of Plotly dir files 
        function testNoOverwritePlotly(testCase)
            pvOld = '1.3.1';
            clear plotly_version.m;
            testCase.setversion(pvOld);
            ply = which('plotly','-all');
            for d = 1:length(ply)
                mkdir(fullfile(fileparts(ply{d}),'testOverwrite'));
            end
            actual = cell(1,length(ply));
            expected = cell(1,length(ply));
            fprintf('\nTESTING UPDATE: HIT Y + ENTER\n\n');
            plotlyupdate;
            for d = 1:length(ply);
                actual{d} = exist(fullfile(fileparts(ply{d}),'testOverwrite'),'dir');
                expected{d} = 7;%name is a folder id
            end
            testCase.verifyEqual(actual,expected);
            for d = 1:length(ply);
                rmdir(fullfile(fileparts(ply{d}),'testOverwrite'));
            end
        end
        
        %test no overwrite of root rep files 
        function testNoOverwriteRepoRoot(testCase)
            pvOld = '1.3.1';
            clear plotly_version.m;
            testCase.setversion(pvOld);
            plyset = which('plotlysetup','-all');
            for d = 1:length(plyset)
                mkdir(fullfile(fileparts(plyset{d}),'testOverwrite'));
            end
            actual = cell(1,length(plyset));
            expected = cell(1,length(plyset));
            fprintf('\nTESTING UPDATE: HIT Y + ENTER\n\n');
            plotlyupdate;
            for d = 1:length(plyset);
                actual{d} = exist(fullfile(fileparts(plyset{d}),'testOverwrite'),'dir');
                expected{d} = 7;%name is a folder id
            end
            testCase.verifyEqual(actual,expected);
            for d = 1:length(plyset);
                rmdir(fullfile(fileparts(plyset{d}),'testOverwrite'));
            end
        end
        
        %test file cleanup 
        function testCleanUpFiles(testCase)
            pvOld = '1.3.1';
            clear plotly_version.m;
            testCase.setversion(pvOld);
            plyset = which('plotlysetup','-all');
            for d = 1:length(plyset)
                %NEED TO ADD testclean.m TO CLEANUP REMOVEFILES!! 
                testplyclean{d} = fullfile(fileparts(plyset{d}),'testclean.m');
                copyfile(plyset{d},testplyclean{d});
            end
            actual = cell(1,length(plyset));
            expected = cell(1,length(plyset));
            fprintf('\nTESTING UPDATE: HIT Y + ENTER\n\n');
            plotlyupdate;
            for d = 1:length(plyset);
                actual{d} = exist(testplyclean{d},'file');
                expected{d} = 0;
            end
            testCase.verifyEqual(actual,expected);
            if(~isequal(actual,expected))
                for d = 1:length(plyset)
                    delete(testplyclean{d});
                end
            end
        end
    end
    
    methods (Static)
        function setversion(ver)
            pv = which('plotly_version.m','-all');
            for d = 1:length(pv)
                fid = fopen(pv{d},'w');
                fprintf(fid,'%s',['function version=plotly_version();version = ''' ver ''';end']);
                fclose(fid);
            end
        end
    end
end


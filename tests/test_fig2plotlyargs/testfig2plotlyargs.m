classdef testfig2plotlyargs < matlab.unittest.TestCase
    %test fig2plotly args 
    
    methods (Test)
        
        %test changing name using 'name' property 
        function testNamePlot(testCase)
            close all
            f = figure;
            plot(1:10);
            name = 'test_name';
            resp = fig2plotly(f,'name',name);
            actual= resp.filename;
            expected = name;
            testCase.verifyEqual(actual,expected);
        end
        
        %test changing name using 'filename' property
        function testFileNamePlot(testCase)
            close all
            f = figure;
            plot(1:10);
            filename = 'test_name';
            resp = fig2plotly(f,'filename',filename);
            actual= resp.filename;
            expected = filename;
            testCase.verifyEqual(actual,expected);
        end
        
        %test no change to name
        function testNoNamePlot(testCase)
            close all
            f = figure;
            plot(1:10);
            resp = fig2plotly(f);
            actual= resp.filename(1:length('untitled'));
            expected = 'untitled';
            testCase.verifyEqual(actual,expected);
        end
    end
end


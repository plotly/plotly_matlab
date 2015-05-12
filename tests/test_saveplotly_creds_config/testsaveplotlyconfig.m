classdef testsaveplotlyconfig < matlab.unittest.TestCase
    
    properties
        creds = loadplotlycredentials;
        config = loadplotlyconfig;
        username = 'test_user_name';
        api_key = 'test_api_key';
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
        
        function testWrongNumberOfInputs(testCase)
            
            % the basedomain must be specified.
            message = ''; 
            
            try
               saveplotlyconfig; 
            catch exception
                message = exception.message; 
            end
            
            expected_message = ...
            ['Incorrect number of inputs. Please save your configuration ', ...
            'as follows: >> saveplotlyconfig(plotly_domain,', ...
            '[optional]plotly_streaming_domain)']; 
    
            testCase.verifyEqual(expected_message, message);           
        end     
        
        function testSigninDomain(testCase)
            
            % the user is signed in using the specified base domain.
            
            % signin as test user
            signin(testCase.username,testCase.api_key, testCase.plotly_domain)      
             
            saveplotlyconfig('new_domain'); 
            [~, ~, expected_domain] = signin; 
            
            testCase.verifyEqual(expected_domain, 'new_domain');
        end
        
        function testSigninDomainwithStream(testCase)
            
            % the user is signed in using the specified base domain even 
            % when both base and streaming domains are provided.
            
            % signin as test user
            signin(testCase.username,testCase.api_key, testCase.plotly_domain)      
             
            saveplotlyconfig('new_domain', 'stream_domain'); 
            [~, ~, expected_domain] = signin; 
            
            testCase.verifyEqual(expected_domain, 'new_domain');
        end
    end
end



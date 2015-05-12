classdef testsaveplotlycredentials < matlab.unittest.TestCase
    
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
            
            % both username and api_key must be specified.
            message = ''; 
            
            try
               saveplotlycredentials('test'); 
            catch exception
                message = exception.message; 
            end
            
            expected_message = ...
            ['Incorrect number of inputs. Please save your credentials ', ...
            'as follows: >> saveplotlycredentials(username, api_key,', ...
            '[optional]stream_ids)']; 
    
            testCase.verifyEqual(expected_message, message);           
        end     
        
        function testSigninUsernameAPIKey(testCase)
            
            % the user is signed in using the specified username and api_key.
            
            % signin as test user
            signin(testCase.username, testCase.api_key)      
             
            saveplotlycredentials('new_username', 'new_api_key'); 
            [expected_username, expected_api_key] = signin; 
            
            testCase.verifyEqual(expected_username, 'new_username');
            testCase.verifyEqual(expected_api_key, 'new_api_key');
        end
        
        function testSigninUsernameAPIKeyandStream(testCase)
            
            % the user is signed in using the specified username and api_key
            % even when the streaming tokens are provided.
            
            % signin as test user
            signin(testCase.username, testCase.api_key)      
             
            saveplotlycredentials('new_username', 'new_api_key', {'new_stream_token'}); 
            [expected_username, expected_api_key] = signin; 
            
            testCase.verifyEqual(expected_username, 'new_username');
            testCase.verifyEqual(expected_api_key, 'new_api_key');
        end
    end
end

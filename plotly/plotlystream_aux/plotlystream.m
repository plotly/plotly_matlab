classdef plotlystream < handle
    % Interface to Plotly's real-time graphing API.
    % Initialize a Stream object with a stream_id found in
    % {plotly_domain}/settings. Real-time graphs are
    % initialized with a call to `plot` that embeds your unique
    % `stream_id`s in each of the graph's traces. The `Stream`
    % interface plots data to these traces, as identified with the unique
    % stream_id, in real-time. Every viewer of the graph sees
    % the same data at the same time.
    
    %----CLASS PROPERTIES----%
    properties
        Response
        Specs
    end
    
    properties (Access=private)
        URL
        Connection
        Stream
    end
    
    %----CLASS METHODS----%
    methods
        
        %----CONSTRUCTOR---%
        function obj = plotlystream(request)
            
            %default stream settings
            obj.Specs.Token = '';
            
            %initialize connection settings
            obj.Specs.Port = 80;
            obj.Specs.Host = 'http://stream.plot.ly';
            obj.Specs.ReconnectOn = {'','200','408'};
            obj.Specs.Timeout = 5000;
            obj.Specs.Handler = sun.net.www.protocol.http.Handler;
            obj.Specs.Chunklen = 14;
            obj.Specs.Closed = true;
            obj.Specs.ConnectAttempts = 0;
            obj.Specs.ConnectDelay = 1;
            obj.Specs.MaxConnectAttempts = 5;
            
            %initialize output response
            obj.Response = '';
            
            %check for correct input structure
            if nargin > 0
                
                if ischar(request)
                    
                    obj.Specs.Token = request;
                    
                elseif isstruct(request)
                    
                    %check for tokens (required)
                    if (isfield(request,'token'))
                        obj.Specs.Token = request.token;
                    else
                        error(['Oops! You did not properly specify a stream token! Please check out the ', ....
                            'online documentation found @ plot.ly/matlab for more information or contact ',...
                            'chuck@plot.ly']);
                    end
                    
                    if (isfield(request,'port'))
                        obj.Specs.Port = request.port;
                    end
                    
                    if isfield(request,'host')
                        obj.Specs.Host = request.host;
                    else
                        try
                            config = loadplotlyconfig;
                            obj.Specs.Host  = config.plotly_streaming_domain;
                        end
                    end
                    
                    if obj.Specs.Port ~=80
                        obj.Specs.Host = [obj.Specs.Host ':' num2str(obj.Specs.Port)];
                    end
                    
                    if isfield(request,'timeout')
                        obj.Specs.Timeout = request.timeout;
                    end
                    
                    if isfield(request,'handler')
                        obj.Specs.Handler= request.handler;
                    end
                    
                    if isfield(request,'chunklen')
                        obj.Specs.Chunklen= request.chunklen;
                    end
                else
                    error(['Oops! It appears that the specified input argument used to ',...
                        'initialize the plotlystream object was not of type char or struct. ',...
                        'Please check out the online documentation found @ plot.ly/matlab ',...
                        'for more information or contact chuck@plot.ly']);
                end
                
            else
                error(['Oops! You did not properly specify a stream token! Please check out the ', ....
                    'online documentation found @ plot.ly/matlab for more information or contact ',...
                    'chuck@plot.ly']);
            end
        end
        
        
        %-----------OPEN STREAM-----------%
        function obj = open(obj)
            try
                try
                    obj.URL = java.net.URL([],obj.Specs.Host,obj.Specs.Handler);
                    obj.Connection = obj.URL.openConnection; %throws an I/O exception
                catch ME
                    obj.reconnect(ME);
                end
                obj.Connection.setChunkedStreamingMode(obj.Specs.Chunklen)
                obj.Connection.setRequestMethod('POST');
                obj.Connection.setReadTimeout(obj.Specs.Timeout);
                obj.Connection.setRequestProperty('plotly-streamtoken', obj.Specs.Token);
                obj.Connection.setDoOutput(true);
                try
                    obj.Stream = obj.Connection.getOutputStream; %throws an I/O exception
                catch ME
                    display(ME.message)
                end

                %successful connection  - reset the delay/retries
                obj.resetretries;
            catch
                error(['Oops! An error occured when attempting to open the output stream ',...
                    'Please check out the online documentation found @ plot.ly/matlab ',...
                    'for more information or contact chuck@plot.ly']);
            end
        end
        
        %-----------WRITE STREAM-----------%
        function obj = write(obj,request)
            if nargin ~= 2
                error(['Oops! It appears that not enough input arguments were ',...
                    'specified to the write method of your plotlystream object. ',...
                    'Please check out the online documentation found @ plot.ly/matlab ',...
                    'for more information or contact chuck@plot.ly']);
            else
                if ~isstruct(request)
                    error(['Oops! It appears that the input argument to the write method ',...
                        'of your plotlystream object is not a structure array as required.  ',...
                        'Please check out the online documentation found @ plot.ly/matlab ',...
                        'for more information or contact chuck@plot.ly']);
                end
                try
                    body = request;
                    obj.Stream.write(unicode2native(sprintf([m2json(body) '\n']),''));
                catch
                    error(['Oops! An error occured when attempting to write the output stream ',...
                        'Please check out the online documentation found @ plot.ly/matlab ',...
                        'for more information or contact chuck@plot.ly']);
                end
            end
        end
        
        %-----------CLOSE STREAM-----------%
        function obj = close(obj)
            try
                obj.Stream.close;
                obj.Specs.ConnectAttempts = 0;
                obj.Specs.ConnectDelay = 1;
                obj.Specs.Closed = true;
            catch
                error(['Oops! An error occured when attempting to close the output stream ',...
                    'Please check out the online documentation found @ plot.ly/matlab ',...
                    'for more information or contact chuck@plot.ly']);
            end
        end
        
        %-----------RECONNECT-----------%
        function obj = reconnect(obj,ME)
            if (obj.Specs.ConnectAttempts == 1)
                display(ME.message);
                sprintf('\n')
            end
            obj.Specs.ConnectAttempts = obj.Specs.ConnectAttempts + 1;
            if(obj.Specs.ConnectAttempts <= obj.Specs.MaxConnectAttempts)
                sprintf(['[Connection failed] Attempt:' num2str(obj.Specs.ConnectAttempts) ' to reconnect...'])
                pause(obj.Specs.ConnectDelay);
                obj.Specs.ConnectDelay = obj.Specs.ConnectDelay + obj.Specs.ConnectDelay; 
                display(num2str(obj.Specs.ConnectDelay)) 
                obj.open;
            else
                error(['Oops! All attempts to reconnect were unsuccessful. ',...
                    'Please check out the online documentation found @ plot.ly/matlab ',...
                    'for more information or contact chuck@plot.ly']);
            end
        end
        
        %-----------IS CONNECTED-----------%
        function resp = isconnected(obj)
            
            if(obj.Specs.Closed)
                resp = false;
                return
            end
            
            if ~exist(object.Stream,'class')
                resp = false;
                return
            end
            
        end
        
        %-----------GET RESPONSE-----------%
        function obj = getresponse(obj)
            obj.Response = obj.Connection.getResponseCode;
        end
        
        %-----------RESET RETRIES-----------%
        function obj = resetretries(obj)
            %reset the connect counter and delay
            obj.Specs.ConnectAttempts = 0;
            obj.Specs.ConnectDelay = 1;
        end
        
    end
end



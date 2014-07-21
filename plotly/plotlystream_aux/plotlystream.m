classdef plotlystream< handle
    
    %----CLASS PROPERTIES----%
    properties
        Response
        Specs
        Core
    end
    
    properties (Access=private)
        URL
        Connection
        Stream
    end
    
    %----CLASS METHODS----%
    methods
        
        %----CONSTRUCTOR---%
        function obj = plotlystream(reqStruct)
            
            %default stream settings
            obj.Specs.Token = '';
            obj.Core.Data = {};
            obj.Core.Layout = struct();
            
            %initialize connection settings
            obj.Specs.Port = 80;
            obj.Specs.Host = 'http://stream.plot.ly';
            obj.Specs.ReconnectOn = {'','200','408'};
            obj.Specs.Timeout = 5000;
            obj.Specs.Handler = sun.net.www.protocol.http.Handler;
            obj.Specs.Chunklen = 14;
            obj.Specs.Connected = false;
            
            %initialize output response
            obj.Response = '';
            
            %check for correct input structure
            if nargin > 0
                
                if (~isStruct(reqStruct))
                    error(['Oops! It appears that the specified input arguments used to ',...
                        'initialize the plotlystream object were not placed in a structure array. ',...
                        'Please check out the online documentation foud @ plot.ly/matlab ',...
                        'for more information or contact chuck@plot.ly']);
                end
                
                %check for tokens (required)
                if (isfield(reqStruct,'token'))
                    obj.Specs.Token = reqStruct.token;
                else
                    error(['Oops! You did not properly specify a stream token! Please check out the ', ....
                        'online documentation foud @ plot.ly/matlab for more information or contact ',...
                        'chuck@plot.ly']);
                end
                
                if (isfield(reqStruct,'port'))
                    obj.Specs.Port = reqStruct.port;
                end
                
                if isfield(reqStruct,'host')
                    obj.Specs.Host = reqStruct.host;
                else
                    try
                        config = loadplotlyconfig;
                        obj.Specs.Host  = config.plotly_streaming_domain;
                    end
                end
                
                if obj.Specs.Por ~=80
                    obj.Specs.Host = [obj.Specs.Host ':' obj.Conn.Port];
                end
                
                if isfield(reqStruct,'timeout')
                    obj.Specs.Timeout = reqStruct.timeout;
                end
                
                if isfield(reqStruct,'handler')
                    obj.Specs.Handler= reqStruct.handler;
                end
                
                if isfield(reqStruct,'chunklen')
                    obj.Specs.Chunklen= reqStruct.chunklen;
                end
            end
        end
        
        %-----------OPEN STREAM-----------%
        function obj = open(obj)
            try
                obj.URL = java.net.URL([],obj.Specs.Host,handler);
                obj.Connection = obj.URL.openConnection;
                obj.Connection.setChunkedStreamingMode(obj.Specs.Chunklen)
                obj.Connection.setRequestMethod('POST');
                obj.Connection.setReadTimeout(obj.Specs.Timeout);
                obj.Connection.setRequestProperty('plotly-streamtoken', obj.Specs.Token);
                obj.Connection.setDoOutput(true);
                obj.Stream = obj.Connection.getOutputStream;
            catch ME
                display(ME.message);
            end
        end
        
        %-----------WRITE STREAM-----------%
        function obj = write(obj,reqStruct)
            if nargin ~= 2
                error(['Oops! It appears that the input arguments required ',...
                         'to write using your plotlystream object were not specified. ',...
                         'Please check out the online documentation foud @ plot.ly/matlab ',...
                         'for more information or contact chuck@plot.ly']);
            end
            if isfield(reqStruct,'data')
                obj.Core.Data = reqStruct.data;
                body.data = obj.Core.Data;
            end
            if isfield(reqStruct,'layout')
                obj.Core.Layout = reqStruct.layout;
                body.args.layout = reqStruct.layout;
            end
            obj.Stream.write(unicode2native(sprintf([m2json(body) '\n']),''));
        end
        
        %-----------CLOSE STREAM-----------%
        
 
        %         %-----------WRITE STREAM-----------%
        %         function respStruct = write(reqStruct)
        %
        %             %input
        %             data = reqStruct.data;
        %             if (~iscell(data))
        %                 data = {data};
        %             end
        %
        %             stream = reqStruct.stream;
        %             body = cell(1,length(data));
        %
        %             for s = 1:length(stream)
        %                 body{s} = unicode2native(sprintf([m2json(data{s}) '\n']),'');
        %                 %write the outputstream to plotly
        %                 stream{s}.write(body{s});
        %             end
        %             respStruct = reqStruct;
        %             respStruct.msg = '';
        %         end
        %
        %
        %         %-----------CLOSE STREAM-----------%
        %         function respStruct = close(reqStruct)
        %             stream = reqStruct.stream;
        %             for s = 1:length(stream)
        %                 stream{s}.close;
        %             end
        %             respStruct = reqStruct;
        %             respStruct.msg = '';
        %         end
        %
        %         %-----------VALIDATE REQUEST-----------%
        %         function isvalid =validRequest(request)
        %             isvalid = (strcmpi(request,'open') || strcmpi(request,'write') || strcmpi(request,'close'));
        %         end
        %
        %         %-----------VALIDATE REQSTRUCT-----------%
        %         function isvalid = validReqStruct(request,reqStruct)
        %             if ~isstruct(reqStruct)
        %                 isvalid = false;
        %                 return
        %             else
        %                 switch request
        %                     case 'open'
        %                         isvalid = isfield(reqStruct,'tokens');
        %                     case 'write'
        %                         isvalid = (isfield(reqStruct,'stream')&&isfield(reqStruct,'data'));
        %                     case 'close'
        %                         isvalid = isfield(reqStruct,'stream');
        %                 end
        %             end
        %         end
        %     end
    end
end



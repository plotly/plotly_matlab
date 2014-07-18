function respStruct = plotlystream(request,reqStruct)
% plotlystream(request,reqStruct)
%----------------[INPUT]--------------------%
% request: ['open','write','close']
% open:
% reqStruct.tokens = cell('strmtkn1','strmtkn2',...) ;
% reqStruct.host = 'host url' (opt.) {config.plotly_stream_domain}
% reqStruct.port = 'output port' {80} [int] (opt.)
% reqStruct.timeout = 'connection timeout' {5s.} [int] (optional)
% write:
% reqStruct.stream = cell(java.net.URL object1,java.net.URL object2,...)
% reqStruct.data = struct('x',xdata,'y',ydata,'marker',struct('color','red',...))
% close:
% reqStruct.stream = cell(java.net.URL object1,java.net.URL object2,...)
%----------------[OUTPUT]------------------%
% open:
% respStruct.stream = cell(java.net.URL obj1,java.net.URL obj2,...)
% respStruct.message = 'associated msgs' [string]
% write:
% respStruct.message = 'associated msgs' [string]
% close:
% respStruct.message = 'associated msgs' [string]
%--------------[INFORMATION]---------------%
% For more information please visit:
% https://plot.ly/streaming/
% or contatct chuck@plot.ly
%----------------[EXAMPLE]-----------------%
% data{1}.x = [];
% data{1}.y = [];
% data{1}.stream.token = 'xxxyyyxxxi';
% data{1}.stream.maxpoints = 50;
% data{1}.type = 'scatter';
% data{1}.mode = 'lines+markers';
% data{2}.x = [];
% data{2}.y = [];
% data{2}.stream.token = 'yyyxxxyyyi';
% data{2}.stream.maxpoints = 50;
% data{2}.type = 'scatter';
% data{2}.mode = 'markers';
% %open:
% reqStruct.tokens = {'xxxyyyxxxi','yyyxxxyyyi'}
% respStruct = plotlystream('open', reqStruct);
% reqStruct = respStruct; 
% %write:
% for i = 1:10
% data{1}.x = i;
% data{1}.y = i^2;
% data{2}.x = i;
% data{2}.y = i^3;
% reqStruct.data = data;
% plotlystream('write',reqStruct);
% end
% %close:
% plotlystream('close',reqStruct);
% %close:
% plotlystream('close',{'stream',stream});
%------------------------------------------%
%[TODO]: allow for variable endpoint streaming domains
% to be written to simultaneously. (cell array host/port)

% check for correct number of inputs
if nargin ~= 2
    error(['Oops! Wrong number of inputs! ',...
        'Run >>help plotlystream for more information.']);
end
if validRequest(request)
    if validReqStruct(request,reqStruct)
        % parse the request
        switch request
            case 'open'
                respStruct = openplotlystream(reqStruct);
            case 'write'
                respStruct = writeplotlystream(reqStruct);
            case 'close'
                respStruct = closeplotlystream(reqStruct);
        end
    else
        error(['Oops! Bad stream request structure: missing required fields. ', ...
            'Run >>help plotlystream for more information.'])
    end
else
    error(['Oops! Bad stream request: please specify ',...
        'one of ''open'', ''write'', or ''close''.'])
end
end

%-----------OPEN STREAM-----------%
function respStruct = openplotlystream(reqStruct)

%input
tokens = reqStruct.tokens;

if (~iscell(tokens))
    tokens = {tokens};
end

handler = sun.net.www.protocol.http.Handler;
numStreams = length(tokens);
url= cell(1,numStreams);
conn = cell(1,numStreams); 
stream = cell(1,numStreams);
chunklen = 20;

if isfield(reqStruct,'host')
    host = reqStruct.host;
else
    try
        config = loadplotlyconfig;
        host = config.plotly_streaming_domain;
    catch
        host = 'http://stream.plot.ly';
    end
end

if (isfield(reqStruct,'port'))
    port = reqStruct.port;
else
    port = 80;
end

if (isfield(reqStruct,'timeout'))
    timeout = reqStruct.timeout;
else
    timeout = 5000;
end

%open the connection
for s = 1:numStreams;
    url{s} = java.net.URL([],[host ':' num2str(port)],handler);
    conn{s} = url{s}.openConnection;
    %[TODO]: handle connection errors
    conn{s}.setChunkedStreamingMode(chunklen)
    conn{s}.setRequestMethod('POST');
    conn{s}.setReadTimeout(timeout);
    conn{s}.setRequestProperty('plotly-streamtoken', tokens{s});
    conn{s}.setDoOutput(true);
    stream{s} = conn{s}.getOutputStream;
end

%ouput
respStruct = reqStruct; 
respStruct.stream = stream;
respStruct.msg = '';
end

%-----------WRITE STREAM-----------%
function respStruct = writeplotlystream(reqStruct)

%input
data = reqStruct.data; 
if (~iscell(data))
    data = {data};
end

stream = reqStruct.stream; 
body = cell(1,length(data)); 

for s = 1:length(stream)
body{s} = unicode2native(sprintf([m2json(data{s}) '\n']),''); 
%write the outputstream to plotly 
stream{s}.write(body{s});
end
respStruct = reqStruct; 
respStruct.msg = '';
end


%-----------CLOSE STREAM-----------%
function respStruct = closeplotlystream(reqStruct)
stream = reqStruct.stream;
for s = 1:length(stream)
    stream{s}.close;
end
respStruct = reqStruct; 
respStruct.msg = '';
end

%-----------VALIDATE REQUEST-----------%
function isvalid =validRequest(request)
isvalid = (strcmpi(request,'open') || strcmpi(request,'write') || strcmpi(request,'close'));
end

%-----------VALIDATE REQSTRUCT-----------%
function isvalid = validReqStruct(request,reqStruct)
if ~isstruct(reqStruct)
    isvalid = false;
    return
else
    switch request
        case 'open'
            isvalid = isfield(reqStruct,'tokens');
        case 'write'
            isvalid = (isfield(reqStruct,'stream')&&isfield(reqStruct,'data'));
        case 'close'
            isvalid = isfield(reqStruct,'stream');
    end
end
end


function resp = plotlystream(request,reqStruct)
% plotlystream(request,reqStruct)
% [INPUT]
% request: ['open','write','close']
% open:
% reqStruct.tokens = cell('streamtoken1','streamtoken2',...) ;
% reqStruct.host = 'stream host url' (optional) {default: creds.plotly_stream_domain}
% reqStruct.port = 'output port' {80} [int] (optional)
% reqStruct.timeout = 'connection timeout' {5s.} [int] (optional)
% write:
% reqStruct.stream = cell(java.net.URL object1,java.net.URL object2,...)
% reqStruct.data = struct('x',xdata,'y',ydata,'marker',struct('color','red',...))
% close:
% reqStruct.stream = cell(java.net.URL object1,java.net.URL object2,...)
% [OUPUT]
% open:
% resp.stream = cell(java.net.URL object1,java.net.URL object2,...)
% resp.error = 'any associated errors' [string]
% resp.message = 'any associated messages' [string]
% write:
% resp.errors= 'any associated errors' [string]
% resp.message = 'any associated messages' [string]
% close:
% resp.error = 'any associated errors' [string]
% resp.message = 'any associated messages' [string]
% [INFORMATION]
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
% reqStruct.stream = plotlystream('open', reqStruct);
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
                resp = openplotlystream(reqStruct);
            case 'write'
                resp = writeplotlystream(reqStruct);
            case 'close'
                resp = closeplotlystream(reqStruct);
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

function resp = openplotlystream(reqStruct)

%input
handler = sun.net.www.protocol.http.Handler;
tokens = reqStruct.tokens;
numStreams = length(tokens); 
stream = cell(1,numStreams); 

if isfield(reqStruct,'host')
    host = reqStruct.host;
else
    try
        creds = loadplotlycredentials;
        host = creds.plotly_streaming_domain;
    catch
        host = 'http://stream.plot.ly';
    end
end
if (isfield(reqStruct,'port'))
    port = reqStruct.port;
else
    port = 80;
end

%open the connection 
for s = 1:numStreams; 
stream{s} = java.net.URL([],host,handler);

end

%ouput 
resp.stream = stream;
resp.msg = '';
resp.error = '';
end

function resp = writeplotlystream(reqStruct)
resp.msg = '';
resp.error = '';
end

function resp = closeplotlystream(reqStruct)
stream = reqStruct.stream;
for s = 1:length(stream)
    stream{s}.close;
end
resp.msg = '';
resp.error = '';
end

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

function isvalid =validRequest(request)
isvalid = (strcmpi(request,'open') || strcmpi(request,'write') || strcmpi(request,'close'));
end


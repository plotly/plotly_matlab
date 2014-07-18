%-----plotly setup-----%

%trace1
data{1}.x = [];
data{1}.y = [];
data{1}.name = 'signal1';
data{1}.stream.token = 'YOUR STREAM TOKEN'; 
data{1}.stream.maxpoints = 50;
data{1}.type = 'scatter';
data{1}.mode = 'lines+markers';
data{1}.marker.symbol = 'x';
data{1}.marker.size = 10;
data{1}.marker.color = 'rgba(250,100,50,0.8)';
data{1}.line.color = 'rgba(250,100,50,0.5)';
data{1}.line.width = 5;

%trace2
data{2}.x = [];
data{2}.y = [];
data{2}.name = 'signal2';
data{2}.stream.token = 'ANOTHER STREAM TOKEN'; 
data{2}.stream.maxpoints = 50;
data{2}.type = 'scatter';
data{2}.mode = 'markers';
data{2}.marker.symbol = 'dot';
data{2}.marker.size = 10;
data{2}.marker.color = 'rgba(20,100,250,0.9)';

%layout
layout.xaxis.title = 'SAMPLE';
layout.yaxis.title = 'AMPLITUDE';
layout.title = 'MATLAB STREAMING';

%args
args.layout = layout;
args.filename = 'MATLAB_STREAM';
args.fileopt = 'overwrite';
resp = plotly(data,args);
resp.url

tokens{1} = data{1}.stream.token;
tokens{2} = data{2}.stream.token;
%reqStruct.host = 'http://localhost'; 
%reqStruct.port = 8080; 
reqStruct.tokens = tokens; 
reqStruct = plotlystream('open',reqStruct);

%-----signal generation-----%
n = 1;
cycles = 1000;
t = zeros(1,cycles);
g = zeros(1,cycles);

for n = 1:cycles;
    t(n) = sin(2*pi*40*n/1000);
    g(n) = 2*cos(2*pi*40*n/1000);
    data{1}.x = n;
    data{1}.y = t(n); 
    data{2}.x = n;
    data{2}.y = g(n); 
    reqStruct.data = data; 
    reqStruct = plotlystream('write',reqStruct); 
    pause(0.05);
end

plotlystream('close',reqStruct); 

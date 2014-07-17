 %-----stream testing-----%

%-----plotly setup-----%

%trace1 
data{1}.x = [];
data{1}.y = [];
data{1}.name = 'signal1'; 
%first token for the stream troll
data{1}.stream.token = 'a9ujhngbea';
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
%second token for the stream troll
data{2}.stream.token = 'gcuvbzmvxz';
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

%-----java libraries----- %
import java.net.Socket
import java.io.*
import java.net.URL

%-----connection specs----- %
host_url= 'http://stream.plot.ly'; 
%port = 80; (default)
protocol = 'HTTP/1.1'; 
timeout = 5000;
handler = sun.net.www.protocol.http.Handler;

%-----first stream-----%
url1 = java.net.URL([],host_url,handler);
urlConnection1 = url1.openConnection;
urlConnection1.setChunkedStreamingMode(14)
urlConnection1.setRequestMethod('POST');
urlConnection1.setReadTimeout(timeout);
%urlConnection1.setRequestProperty('Transfer-Encoding', 'chunked');
urlConnection1.setRequestProperty('plotly-streamtoken', 'a9ujhngbea');
urlConnection1.setDoOutput(true);
outputStream1 = urlConnection1.getOutputStream;

%-----second stream-----%
url2 = java.net.URL([],host_url,handler);
urlConnection2 = url2.openConnection;
urlConnection2.setChunkedStreamingMode(14)
urlConnection2.setRequestMethod('POST');
urlConnection2.setReadTimeout(timeout);
%urlConnection2.setRequestProperty('Transfer-Encoding', 'chunked');
urlConnection2.setRequestProperty('plotly-streamtoken', 'gcuvbzmvxz');
urlConnection2.setDoOutput(true);
outputStream2 = urlConnection2.getOutputStream; 

%time to switch tabs
pause(3); 

%-----signal generation-----%
n = 1;
cycles = 1000; 
t = zeros(1,cycles); 
g = zeros(1,cycles); 

for n = 1:cycles; 
    t(n) = sin(2*pi*40*n/1000);
    g(n) = 2*cos(2*pi*40*n/1000);
    body1 = sprintf('{"x":%s,"y":%s}\n',num2str(n),num2str(t(n)));
    body1 = unicode2native(body1,'');
    body2 = sprintf('{"x":%s,"y":%s}\n',num2str(n),num2str(g(n)));
    body2 = unicode2native(body2,'');
    %write to stream.plot.ly
    outputStream1.write(body1);
    outputStream2.write(body2); 
    %take a breath 
    pause(0.05);
end

%-----close it up-----%
outputStream.close;


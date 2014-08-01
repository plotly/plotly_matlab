% %-----stream testing-----%
% 
% %-----plotly setup-----%
% 
% %trace1
% data{1}.x = [];
% data{1}.y = [];
% data{1}.name = 'signal1';
% data{1}.stream.token = 'a9ujhngbea';
% data{1}.stream.maxpoints = 50;
% data{1}.type = 'scatter';
% data{1}.mode = 'lines+markers';
% data{1}.marker.symbol = 'x';
% data{1}.marker.size = 10;
% data{1}.marker.color = 'rgba(250,100,50,0.8)';
% data{1}.line.color = 'rgba(250,100,50,0.5)';
% data{1}.line.width = 5;
% 
% %trace2
% data{2}.x = [];
% data{2}.y = [];
% data{2}.name = 'signal2';
% data{2}.stream.token = 'gcuvbzmvxz';
% data{2}.stream.maxpoints = 50;
% data{2}.type = 'scatter';
% data{2}.mode = 'markers';
% data{2}.marker.symbol = 'dot';
% data{2}.marker.size = 10;
% data{2}.marker.color = 'rgba(20,100,250,0.9)';
% 
% %layout
% layout.xaxis.title = 'SAMPLE';
% layout.yaxis.title = 'AMPLITUDE';
% layout.title = 'MATLAB STREAMING';
% 
% %args
% args.layout = layout;
% args.filename = 'MATLAB_STREAM_TEST_3';
% args.fileopt = 'overwrite';
% resp = plotly(data,args);
% resp.url
% 
% %-----connection specs----- %
 host_url= 'http://stream.plot.ly';
% %host_url = 'http://localhost:8080';
 timeout = 5000;
 handler = sun.net.www.protocol.http.Handler;
 chunklen = 40; %this defaults to 4096 if not specified or chucklen < headerlen
% 
% %-----first stream-----%
% url1 = java.net.URL([],host_url,handler);
% urlConnection1 = url1.openConnection;
% urlConnection1.setChunkedStreamingMode(chunklen)
% urlConnection1.setRequestMethod('POST');
% urlConnection1.setConnectTimeout(timeout);
% urlConnection1.setRequestProperty('plotly-streamtoken',data{1}.stream.token);
% urlConnection1.setDoOutput(true);
% %urlConnection1.setDoInput(true);
% outputStream1 = urlConnection1.getOutputStream;
% %inputStream1 = urlConnection1.getInputStream;
% 
% %-----second stream-----%
% url2 = java.net.URL([],host_url,handler);
% urlConnection2 = url2.openConnection;
% urlConnection2.setChunkedStreamingMode(chunklen)
% urlConnection2.setRequestMethod('POST');
% urlConnection2.setConnectTimeout(timeout);
% urlConnection2.setRequestProperty('plotly-streamtoken',data{2}.stream.token);
% urlConnection2.setDoOutput(true);
% outputStream2 = urlConnection2.getOutputStream;
% 
% %time to switch tabs
% pause(3);
% 
% %-----signal generation-----%
% n = 1;
% cycles = 300;
% t = zeros(1,cycles);
% g = zeros(1,cycles);
% 
% for n = 1:cycles;
%     t(n) = sin(2*pi*40*n/1000);
%     g(n) = 2*cos(2*pi*40*n/1000);
%     
%     body1 = sprintf('{"x":%s,"y":%s}\n',num2str(n),num2str(t(n)));
%     body2 = sprintf('{"x":%s,"y":%s}\n',num2str(n),num2str(g(n)));
%     
%     body1 = unicode2native(body1,'');
%     body2 = unicode2native(body2,'');
%     %write to stream.plot.ly
%     
%     outputStream1.write(body1);   
%     outputStream2.write(body2);
%     
%     %take a breath
%     pause(0.05);
%     %if(~isConnected('outputStream'))
%     %getResponse(ouptutStream)); 
% %     inputStream = urlConnection1.getInputStream;
% %     %end
% %     display('here'); 
%    % inputStream = urlConnection1.getErrorStream;
% end
% 
% 
% %-----close it up-----%
% outputStream1.close;
% outputStream2.close;
% 




% %----heatmap stream----_%

%trace1
dim1 = 256; 
dim2 = 50; 
data{1}.x = 1:dim2;
data{1}.y = 1:dim1;
data{1}.z = rand(dim1,dim2);
data{1}.type = 'heatmap';
data{1}.stream.token = 'fedrtv8qow';
data{1}.stream.maxpoints = 50;
data{1}.zauto = false;
data{1}.zmin = 0;
data{1}.zmax = 20;

%layout
layout.xaxis.title = 'TIME FRAME';
layout.yaxis.title = 'FREQUENCY BIN';
layout.title = 'MATLAB SPEC STREAMING';

%args
args.layout = layout;
args.filename = 'MATLAB_SPEC_STREAM_TEST';
args.fileopt = 'overwrite';

%plotly response
resp = plotly(data,args);
resp.url

% %construct the stram object
% % reqStruct.host = 'http://localhost';
% % reqStruct.port = 8080;
% reqStruct.token = 'fedrtv8qow' ;
% ps = plotlystream(reqStruct);
% 
% %open the stream objects
% ps.open;

%-----first stream-----%
url1 = java.net.URL([],host_url,handler);
urlConnection1 = url1.openConnection;
urlConnection1.setChunkedStreamingMode(chunklen)
urlConnection1.setRequestMethod('POST');
urlConnection1.setConnectTimeout(timeout);
urlConnection1.setRequestProperty('plotly-streamtoken',data{1}.stream.token);
urlConnection1.setDoOutput(true);
%urlConnection1.setDoInput(true);
outputStream1 = urlConnection1.getOutputStream;
%inputStream1 = urlConnection1.getInputStream;
%number of signal divs
updates = 1000;

for i = 1:updates
    streamdata.x = i:i+10;
    streamdata.y = 1:dim1;
    streamdata.type = 'heatmap'; 
    streamdata.z = 10*rand(dim1,dim2);
     body1 = sprintf([m2json(streamdata) '\n']);
    %streamdata.type = 'heatmap';
    reqStruct.data = streamdata;
    tic
    outputStream1.write(unicode2native(body1,''));
    pause(0.05) 
    toc
end

%close the stream
outputStream1.close;



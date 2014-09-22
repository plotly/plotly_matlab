%%capture 
%%matlab 

%----plotly setup----%

%max streaming points
maxpoints = 32;

%credientials 
my_credentials = loadplotlycredentials; 

%signal1 (time domain)
data{1}.type = 'scatter';
data{1}.mode = 'lines+markers';
data{1}.x = [];
data{1}.y = [];
data{1}.line.width = 5;
data{1}.line.shape = 'spline';
data{1}.line.color = 'rgba(100,20,250,0.5)';
data{1}.marker.symbol = 'circle';
data{1}.marker.size = 10;
data{1}.marker.line.width = 2;
data{1}.stream.token = my_credentials.stream_ids{end-4};
data{1}.stream.maxpoints = maxpoints;
data{1}.autorange = true;
data{1}.name = '$s_1$';
data{1}.xaxis = 'x1';
data{1}.yaxis = 'y1';

%signal2 (time domain)
data{2}.type = 'scatter';
data{2}.mode = 'lines+markers';
data{2}.autorange = true;
data{2}.line.width = 5;
data{2}.line.color = 'rgba(0,200,200,0.5)';
data{2}.line.shape = 'spline';
data{2}.marker.symbol = 'circle';
data{2}.marker.size = 10;
data{2}.marker.line.width = 2;
data{2}.x = [];
data{2}.y = [];
data{2}.stream.token = my_credentials.stream_ids{end-3};
data{2}.stream.maxpoints = maxpoints;
data{2}.name = '$s_2$';
data{2}.xaxis = 'x1';
data{2}.yaxis = 'y1';

%signal1 (frequency domain)
data{3}.type = 'scatter';
data{3}.mode = 'lines';
data{3}.x = [];
data{3}.y = [];
data{3}.stream.token = my_credentials.stream_ids{end-2};
data{3}.line.color = 'rgba(0,0,0,1)';
data{3}.line.width = 3;
data{3}.name = '$|FFT(s_1)|$';
data{3}.fill = 'tozeroy';
data{3}.fillcolor =  'rgba(100,20,250,0.5)';
data{3}.xaxis = 'x2';
data{3}.yaxis = 'y2';

%signal2 (frequency domain)
data{4}.type = 'scatter';
data{4}.mode = 'lines';
data{4}.x = [];
data{4}.y = [];
data{4}.stream.token = my_credentials.stream_ids{end-1};
data{4}.line.color = 'rgba(0,0,0,1)';
data{4}.line.width = 3;
data{4}.fillcolor = 'rgba(0,200,200,0.5)';
data{4}.fill = 'tozeroy';
data{4}.name = '$|FFT(s_2)|$';
data{4}.xaxis = 'x2';
data{4}.yaxis = 'y2';

%---layout and plot options---%
args.layout.title = 'REAL TIME SIGNAL ANALYSIS';
args.layout.xaxis1.title = 'Time [s.]';
args.layout.xaxis1.showgrid = true;
args.layout.xaxis1.zeroline = false;
args.layout.xaxis1.showline = false;
args.layout.xaxis1.nticks = 20;
args.layout.xaxis1.mirror = false;
args.layout.yaxis1.title = 'Amplitude';
args.layout.xaxis1.anchor = 'y1';
args.layout.yaxis1.anchor = 'x1';
args.layout.yaxis1.range = [-7 7];
args.layout.yaxis1.nticks = 10;
args.layout.yaxis1.showline = true;
args.layout.yaxis1.mirror = false;
args.layout.yaxis1.linewidth = 2;
args.layout.yaxis1.zeroline = true;
args.layout.yaxis1.zerolinewidth = 2;
args.layout.yaxis1.showgrid = true;
args.layout.yaxis1.domain = [0.6 1];


args.layout.yaxis2.title = 'Magnitude';
args.layout.xaxis2.title = 'Frequency [Hz.]';
args.layout.xaxis2.showline = true;
args.layout.xaxis2.zeroline = false;
args.layout.xaxis2.mirror = false;
args.layout.yaxis2.showline = true;
args.layout.yaxis2.linewidth = 2;
args.layout.yaxis2.mirror = false;
args.layout.yaxis2.nticks = 10;
args.layout.xaxis2.nticks = 20;
args.layout.yaxis2.zeroline = false;
args.layout.yaxis2.domain = [0 0.4];
args.layout.xaxis2.anchor = 'y2';
args.layout.yaxis2.anchor = 'x2';
args.layout.yaxis2.range = [0 100];
args.layout.xaxis2.linewidth = 2;

args.filename = 'stream_example_fourier2';
args.fileopt = 'new';
resp = plotly(data,args);
resp.url 


%----SIGNAL GENERATION---%

%Sampling frequency
SR = 20;

%N (length of fft)
N = 256;

%Duration
dur = 50*SR;

%Time vector
time = linspace(1,50,dur);

%Amplitude vector
A = [1 2 3 4 5];

src1 = [ A(1)*sin(2*pi*1*(0*dur/5 + 1:1*dur/5)/SR)' ,...
           ; A(2)*sin(2*pi*2*(1*dur/5 + 1:2*dur/5)/SR)',...
           ; A(3)*sin(2*pi*3*(2*dur/5 + 1:3*dur/5)/SR)',...
           ; A(4)*sin(2*pi*4*(3*dur/5 + 1:4*dur/5)/SR)',....
           ; A(5)*sin(2*pi*5*(4*dur/5 + 1:5*dur/5)/SR)'];
       
src2 = [ A(5)*sin(2*pi*5*(0*dur/5 + 1:1*dur/5)/SR)',...
           ; A(4)*sin(2*pi*4*(1*dur/5 + 1:2*dur/5)/SR)',...
           ; A(3)*sin(2*pi*3*(2*dur/5 + 1:3*dur/5)/SR)',....
           ; A(2)*sin(2*pi*2*(3*dur/5 + 1:4*dur/5)/SR)',....
           ; A(1)*sin(2*pi*1*(4*dur/5 + 1:5*dur/5)/SR)'];

%frequency vector
freq = (1:N/2)*SR/(N);

%length of stream
los = length(src1);

%create plotlystream objects
sigstream_time1 = plotlystream(data{1}.stream.token);
sigstream_time2 = plotlystream(data{2}.stream.token);
sigstream_freq1 = plotlystream(data{3}.stream.token);
sigstream_freq2 = plotlystream(data{4}.stream.token);

%open the streams
sigstream_time1.open;
sigstream_time2.open;
sigstream_freq1.open;
sigstream_freq2.open;

s = maxpoints;

for i = maxpoints:2*los+maxpoints+1;
    
    s = mod(i,los)+1; 
    
    %stream data of signal 1 (time)
    datast1t.x = i/SR;
    datast1t.y = src1(s);
    
    %stream data of signal 2 (time)
    datast2t.x = i/SR;
    datast2t.y = src2(s);
    
    %stream data of signal 1 (freq)
    datast1f.x = freq;
    F = abs(fft(src1(mod(i-data{1}.stream.maxpoints:(i-1),los)+1),N));
    datast1f.y = F(1:length(freq));
    
    %stream data of signal 2 (freq)
    datast2f.x = freq;
    F = abs(fft(src2(mod(i-data{1}.stream.maxpoints:(i-1),los)+1),N));
    datast2f.y = F(1:length(freq));
    
    %write stream data
    sigstream_time1.write(datast1t);
    sigstream_time2.write(datast2t);
    sigstream_freq1.write(datast1f);
    sigstream_freq2.write(datast2f);
    
    %take a breath
       pause(0.03);
   
end

%close the streams before they cross! (a la Ghostbusters)

sigstream_time1.close;
sigstream_time2.close;
sigstream_freq1.close;
sigstream_freq2.close;
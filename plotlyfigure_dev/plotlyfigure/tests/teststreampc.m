%%matlab

%----STORED STREAMING CREDENTIALS----%
my_credentials = loadplotlycredentials; 
my_stream_token = 'dc0d4sxhe2';

%----SETUP-----%
p = plotlyfigure; 
p.data{1}.x = []; 
p.data{1}.y = [];
p.data{1}.type = 'scatter';
p.data{1}.stream.token = my_stream_token; 
p.data{1}.stream.maxpoints = 100;  
p.PlotOptions.FileName = 'random_stream'; 
p.PlotOptions.FileOpt = 'overwrite'; 

%----PLOTLY-----%
plotly(p); 

%%matlab 

ps = plotlystream(my_stream_token);

%%matlab 

%----open the stream----%

ps.open(); 

%----write to the stream----%

for i = 1:1000
    mydata.x = i; 
    mydata.y = rand; 
    ps.write(mydata);
    %take a breath 
    pause(0.05); 
end

%----close the stream----% 
ps.close(); 


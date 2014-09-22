%%matlab

%----STORED STREAMING CREDENTIALS----%
my_credentials = loadplotlycredentials; 
my_stream_token = 'dc0d4sxhe2';

%----SETUP-----%

data{1}.x = []; 
data{1}.y = [];
data{1}.type = 'scatter';
data{1}.stream.token = my_stream_token; 
data{1}.stream.maxpoints = 100;  
args.filename = 'MY_FIRST_STREAM'; 
args.fileopt = 'overwrite'; 

%----PLOTLY-----%

resp = plotly(data,args); 
URL_OF_PLOT = resp.url

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


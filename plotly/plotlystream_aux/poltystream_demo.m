%----STORED STREAMING CREDENTIALS----%
my_credentials = loadplotlycredentials; 
my_stream_token = my_credentials.stream_key{4};

%----SETUP-----%

data{1}.x = []; 
data{1}.y = [];
data{1}.type = 'scatter';
data{1}.stream.token = my_stream_token; 
data{1}.stream.maxpoints = 30;  
args.filename = 'stream_test'; 
args.fileopt = 'overwrite'; 

%----PLOTLY-----%

resp = plotly(data,args); 
URL_OF_PLOT = resp.url

%----CREATE A PLOTLY STREAM OBJECT----%

ps = plotlystream(my_stream_token);

%----OPEN THE STREAM----%

ps.open(); 

%----WRITE TO THE STREAM----%

i = 0; 

while true
    mydata.x = i; 
    mydata.y = rand; 
    ps.write(mydata);
    %take a breath 
    pause(0.05); 
    i = i + 1; 
end

%----CLOSE THE STREAM----% 
ps.close; 


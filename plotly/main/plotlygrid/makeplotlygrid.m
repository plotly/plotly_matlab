classdef makeplotlygrid < dynamicprops & handle
    
    
    %----CLASS PROPERTIES----%
    
    properties
        UserData;
        PlotOptions;
        Response;
        Raw; 
        Plot; 
    end
    
    %----CLASS METHODS----%
    methods
        
        function obj = makeplotlygrid(data,varargin)
            
            % check if signed in and grab username, key, domain
            [un, key, domain] = signin;
            
            if isempty(un) || isempty(key)
                error('Plotly:CredentialsNotFound',...
                    ['It looks like you haven''t set up your plotly '...
                    'account credentials yet.\nTo get started, save your '...
                    'plotly username and API key by calling:\n'...
                    '>>> saveplotlycredentials(username, api_key)\n\n'...
                    'For more help, see https://plot.ly/MATLAB or contact '...
                    'chris@plot.ly.']);
            end
            
            % update UserData
            obj.UserData.Username = un;
            obj.UserData.Key = key;
            obj.UserData.Domain = domain;
            
            % check for key/value
            if mod(length(varargin),2)~=0
                error('must be key value');
            end
            
            % defaults
            obj.PlotOptions.Filename = 'untitled'; 
            obj.PlotOptions.WorldReadable = true; 
            
            %parse variable arguments
            for n = 1:2:length(varargin)
                switch varargin{n}
                    case 'filename'
                        obj.PlotOptions.Filename = varargin{n+1};
                end
            end
            
            % post grid to plotly
            resp = obj.makecall(data);
             
            % data fields
            datafields = fieldnames(data);
            
            % add dynamic properties
            for n = 1:length(datafields)
                % add property field
                addprop(obj,datafields{n});
                % create column object
                plotlycol = plotlycolumn(getfield(data,datafields{n}),'id', getfield(resp,datafields{n}));
                % initialize property field
                setfield(obj, datafields{n}, plotlycol);
            end
            
        end
        
        function obj = makecall(obj, data)
            
            querystring = ['?fn=' obj.PlotOptions.Filename '&ftreq=grid' '&world_readable=true']; 
            url = [obj.UserData.Domain '/v0.1/grids/' querystring];
            body.data = data;
            payload = m2json(body); 
            headers(1).name = 'x-plotly-username'; 
            headers(1).value = obj.UserData.Username; 
            headers(2).name = 'x-plotly-apikey'; 
            headers(2).value = obj.UserData.Key; 
            
            %make post request
            resp = urlread2(url, 'Post', payload , headers);
            
            % check response
            response_handler(resp);
            
            % add to PlotOption
            obj.Response = resp;   
        end
        
        %---overload plot command---%
        function obj = plot(obj,varargin)
            obj.Plot = plotlyfigure; 
            plot(varargin{:}); 
            col1 = varargin{1};
            col2 = varargin{2}; 
            obj.Plot.data{1}.x = col1.ID; 
            obj.Plot.data{1}.y = col2.ID; 
            %fig2plotly(p); 
        end 
    end
end


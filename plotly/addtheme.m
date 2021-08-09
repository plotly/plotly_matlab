function figure = addtheme(f, theme)
    
    % validate theme name
    
    S = dir('plotly/themes');
    N = {S.name};
        
    if ~any(strcmp(N,strcat(theme, '.json'))) == 1
        ME = MException('MyComponent:noSuchVariable',...
            [strcat('\n<strong>', theme, '</strong> is not a supported themes.'),...
            ' Please choose one of these theme names:\n\n',...
            strrep(strrep([S.name], '...', ''), '.json', ' | ')]);
        throw(ME)
    end
        
    % add theme to figure
    
    fname = strcat('plotly/themes/', theme, '.json');
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    theme_template = jsondecode(str);

    f.layout.template = theme_template;

    if isfield(f.layout.template.layout, 'paper_bgcolor')
        disp([strcat('layout.bg_paper:::',...
            f.layout.template.layout.paper_bgcolor)])
    end
    
    if isfield(f.layout.template.layout, 'plot_bgcolor')
        disp([strcat('layout.plot_bgcolor:::',...
            f.layout.template.layout.plot_bgcolor)])
    end
    
end

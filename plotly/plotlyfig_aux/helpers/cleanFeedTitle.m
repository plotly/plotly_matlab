function cleanFeedTitle(obj)
% cleanFeedTitle checks all annotations for a title. The first title found 
% is used as the layout.title (Plotly title). This should correspond to the 
% title of the first plot added to the MATLAB figure. As a workaround, only 
% the text is used so that the title appears in the feed. The text color is
% set so that the Plotly title is hidden from the graph, favouring the 
% annotation title (with its flexibilty over positioning). 

    if ~isempty(obj.State.Figure.NumTexts)
        
        % grab the title of the first plot added to the figure. 
        first_title_index = find(arrayfun(@(x)(isequal(x.Title, 1)), ...
            obj.State.Text), 1, 'first');
        
        if ~isempty(first_title_index)
           
            first_title_handle = obj.State.Text(first_title_index).Handle; 
            
            % grab the string of the first title
            first_title = get(first_title_handle, 'String'); 
            interp = get(first_title_handle, 'Interpreter');
            first_title_parsed = parseString(first_title, interp);
            
            % use that as the filename
            obj.layout.title = first_title_parsed;

            % make the title invisible
            obj.layout.titlefont.color = 'rgba(0,0,0,0)'; 
        end
    end
end
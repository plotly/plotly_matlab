function handleFileName(obj)

%--IF EMPTY FILENAME, CHECK FOR PLOT TITLES--%
if isempty(obj.PlotOptions.FileName)
    for t = 1:obj.State.Figure.NumTexts
        if obj.State.Text(t).Title
            str = get(obj.State.Text(t).Handle,'String');
            interp = get(obj.State.Text(t).Handle,'Interpreter');
            obj.PlotOptions.FileName = parseString(str,interp);
            
            % untitle.html if \text exist (special chars)
            if ~isempty(strfind(obj.PlotOptions.FileName, '\text'))
                obj.PlotOptions.FileName = 'untitled';
            end
        end
    end
end

%--IF FILENAME IS STILL EMPTY SET TO UNTITLED--%
if isempty(obj.PlotOptions.FileName)
    obj.PlotOptions.FileName = 'untitled';
end

end
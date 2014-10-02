function handleFileNameOpt(obj)

%--IF EMPTY FILENAME, CHECK FOR PLOT TITLES--%
if isempty(obj.PlotOptions.FileName)
    for t = 1:obj.State.Figure.NumTexts
        if obj.State.Text(t).Title
            str = get(obj.State.Text(t).Handle,'String');
            interp = get(obj.State.Text(t).Handle,'Interpreter');
            obj.PlotOptions.FileName = parseString(str,interp);
        end
    end
end

%--IF FILENAME IS STILL EMPTY SET TO UNTITLED--%
if isempty(obj.PlotOptions.FileName)
    obj.PlotOptions.FileName = 'untitled';
    if isempty(obj.PlotOptions.FileOpt)
        obj.PlotOptions.FileOpt = 'new';
    end
else
    %--IF THERE IS A FILENAME--%
    if isempty(obj.PlotOptions.FileOpt)
        obj.PlotOptions.FileOpt = 'new';
    end
end

end
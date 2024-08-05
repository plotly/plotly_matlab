function handleFileName(obj)
    %--IF EMPTY FILENAME, CHECK FOR PLOT TITLES--%
    try
        if isempty(obj.PlotOptions.FileName)
            for t = 1:obj.State.Figure.NumTexts
                if obj.State.Text(t).Title
                    str = obj.State.Text(t).Handle.String;
                    interp = obj.State.Text(t).Handle.Interpreter;
                    obj.PlotOptions.FileName = parseString(str, interp);

                    % untitle.html if \text exist (special chars)
                    if ~isempty(strfind(obj.PlotOptions.FileName, '\text'))
                        obj.PlotOptions.FileName = 'untitled';
                    end
                end
            end
        end
    catch
        obj.PlotOptions.FileName = 'untitled';
    end

    %--IF FILENAME IS STILL EMPTY SET TO UNTITLED--%
    if isempty(obj.PlotOptions.FileName)
        obj.PlotOptions.FileName = 'untitled';
    end
end

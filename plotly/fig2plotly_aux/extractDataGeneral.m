function data = extractDataGeneral(d, data)
% extractDataGeneral - copy general data struct attributes
%   data = extractDataGeneral(d, data)
%       d - a data struct from matlab describing data
%       data - a plotly data struct
%
% For full documentation and examples, see https://plot.ly/api

if (strcmp(d.Type,'line')||strcmp(d.Type,'patch'));
    data.x = d.XData;
    data.y = d.YData;
else
    if(any(d.Children(1)))
        child_temp = get(d.Children(1));
        if(strcmp(child_temp.Type,'line'))
            data.x = child_temp.XData;
            data.y = child_temp.YData;
        else
            data.x = d.XData;
            data.y = d.YData;
        end
    else
        %no children and not a line nor a patch?
    end
end

try
    ah = ancestor(d.Parent,'axes');
    xtl = get(ah,'XTickLabel');
    if(strcmp(get(ah,'XTickLabelMode'),'manual'))
        if(iscell(xtl))
            data_tempx = data.x;
            for ind = 1:length(data.x)
                data_tempx(ind) = str2double(xtl{1+mod(ind-1,length(xtl))});
            end
        end
        if(ischar(xtl))
            data_tempx = data.x;
            for ind = 1:length(data.x)
                data_tempx(ind) = str2double(xtl(1+mod(ind-1,size(xtl,1)),:));
            end
        end
    end
    data.x = data_tempx; 
end

if strcmp('on', d.Visible)
    data.visible = true;
else
    data.visible = false;
end

if numel(d.DisplayName)>0
    %  data.name = parseText(d.DisplayName);
    try
        %look for interpreter for data name (tex/latex/none)
        tempm = findobj('-property','Interpreter');
        interp = get(tempm(1),'Interpreter');
        m.Interpreter = interp;
    catch
        m.Interpreter = 'tex';
    end
    data.name = (parseLatex(d.DisplayName,m));
else
    data.showlegend = false;
end


end
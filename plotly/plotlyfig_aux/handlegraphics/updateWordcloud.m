function updateWordcloud(obj,scatterIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(scatterIndex).AssociatedAxis);

    %-SCATTER DATA STRUCTURE- %
    scatter_data = obj.State.Plot(scatterIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-scatter type-%
    obj.data{scatterIndex}.type = 'scatter';

    %-format the mesh domain-%
    maxx = get(scatter_data, 'MaxDisplayWords');
    npoints = round(sqrt(maxx));

    if mod(npoints, 2) == 0
        npoints = npoints+1;
    end

    xdomain = linspace(1, maxx, npoints);
    ydomain = linspace(1, maxx*.7, npoints);

    [xdata, ydata] = meshgrid(xdomain, ydomain);
    xrand = diff(xdomain(1:2)) * (rand(size(xdata)) - 0.5);
    yrand = diff(ydomain(1:2)) * (rand(size(ydata)) - 0.5);
    xdata = xdata + xrand;
    ydata = ydata + yrand;

    %-make oval effect-%
    inds = (xdata-0.5*xdomain(end)).^2 + (ydata-0.5*ydomain(end)).^2 < (0.5*maxx)^2;
    xdata(~inds) = NaN;
    ydata(~inds) = NaN;

    %-get frequency-%
    [B, inds] = sort(get(scatter_data, 'SizeData'), 'descend');

    %-take more freq words-%
    nwords = numel(xdata);
    inds = inds(1:nwords);

    %-get indices for distribution-%
    middle = round(nwords*0.5);
    inds = inds(mod([1:nwords] + middle, nwords)+1);
    inds_aux = inds;
    inds1 = round(linspace(1,middle-1, round(middle/2)));
    inds2 = round(linspace(nwords,middle+1, round(middle/2)));
    inds(inds1) = inds_aux(inds2);
    inds(inds2) = inds_aux(inds1);

    %-exchange columns-%
    inds = reshape(inds, size(xdata));
    inds_aux = inds;
    mc = round(0.5*size(inds_aux, 2));

    inds(:,mc-2) = inds_aux(:,mc-1);
    inds(:,mc-1) = inds_aux(:,mc-2);
    inds(:,mc+1) = inds_aux(:,mc+2);
    inds(:,mc+2) = inds_aux(:,mc+1);
    inds = inds(:);

    %-get data to wordcloud-%
    tmpSizeData = get(scatter_data, 'SizeData');
    sizedata = tmpSizeData(inds);

    worddata = cell(nwords,1);
    for w = 1:nwords
        tmpWordData = get(scatter_data, 'WordData');
        worddata{w} = char(tmpWordData(inds(w)));
    end

    %-sent data to plotly-%
    obj.data{scatterIndex}.mode = 'text';
    obj.data{scatterIndex}.x = xdata(:);
    obj.data{scatterIndex}.y = ydata(:);
    obj.data{scatterIndex}.text = worddata;
    obj.data{scatterIndex}.textfont.size = sizedata;

    %-coloring-%
    is_colormap = size(get(scatter_data, 'Color'), 1) > 1;
    col = cell(nwords, 1);

    if ~is_colormap
        for w=1:nwords
            if B(4) > sizedata(w)
                col{w} = getStringColor(round(255*get(scatter_data, 'Color')));
            else
                col{w} = getStringColor(round(255*get(scatter_data, 'HighlightColor')));
            end
        end
    else
        for w=1:nwords
            tmpColor = get(scatter_data, 'Color');
            col{w} = getStringColor(round(255*tmpColor(inds(w), :)));
        end
    end

    obj.data{scatterIndex}.textfont.color = col;
    obj.data{scatterIndex}.textfont.family = matlab2plotlyfont(get(scatter_data, 'FontName'));
    obj.data{scatterIndex}.visible = strcmp(get(scatter_data, 'Visible'),'on');

    %-set layout-%
    xaxis.showgrid = false;
    xaxis.showticklabels = false;
    xaxis.zeroline = false;

    yaxis.showgrid = false;
    yaxis.showticklabels = false;
    yaxis.zeroline = false;

    wordcloudPosition = get(scatter_data, 'Position');
    xo = wordcloudPosition(1);
    yo = wordcloudPosition(2);
    w = wordcloudPosition(3);
    h = wordcloudPosition(4);

    xaxis.domain = min([xo xo + w],1);
    yaxis.domain = min([yo yo + h],1);

    obj.layout.(sprintf('xaxis%d',xsource)) = xaxis;
    obj.layout.(sprintf('yaxis%d',ysource)) = yaxis;

    obj.layout.annotations{1}.xref = 'paper';
    obj.layout.annotations{1}.yref = 'paper';
    obj.layout.annotations{1}.showarrow = false;
    obj.layout.annotations{1}.text = sprintf('<b>%s</b>', get(scatter_data, 'Title'));
    obj.layout.annotations{1}.x = mean(xaxis.domain);
    obj.layout.annotations{1}.y = (yaxis.domain(2) + obj.PlotlyDefaults.TitleHeight);
    obj.layout.annotations{1}.font.color = 'rgb(0,0,0)';
    obj.layout.annotations{1}.font.size = 15;
end

function colsrc = data2colsrc(coldata, plotlycolumns)

colsrc = 0;

if size(coldata,2) > 1
    coldata = coldata'; 
end

colindex = find(cellfun(@(x)(isequal(coldata,x.Data)),...
    plotlycolumns),1,'first');

if(colindex)
    colsrc = plotlycolumns{colindex}.ID;
end

end
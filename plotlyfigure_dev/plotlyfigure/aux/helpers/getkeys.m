function keys = getkeys(plotlyobj,type)

ph = plotlyhelp(plotlyobj); 
plotlyobjfields = fieldnames(ph); 
n = 1; 

for p = 1:length(plotlyobjfields)
    if strcmp(getfield(ph,plotlyobjfields{p},'type'),type)
        keys{n} = plotlyobjfields{p}; 
        n = n+1; 
    end
end

end
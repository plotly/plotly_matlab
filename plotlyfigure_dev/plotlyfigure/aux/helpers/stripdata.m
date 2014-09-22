function stripped = stripdata(data,pr)

stripped = data;

try
    for d = 1:length(data);
        fn = fieldnames(data{d});
        plottype = data{d}.type; 
        for n = 1:length(fn)
            field = getfield(pr, plottype, fn{n},'type');
            if ~strcmp(field,'data')
                stripped{d} = rmfield(stripped{d},fn{n});
            end
        end
    end
end
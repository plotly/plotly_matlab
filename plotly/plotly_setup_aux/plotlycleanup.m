function removed = plotlycleanup
%cleans up any old Plotly API MATLAB library files (v.1.0.0)

%files to be removed (hard coded)
REMOVEFILES = {''};

%initialize removed
removed = {}; 

for s = 1:length(REMOVEFILES)
    
    %look for old files
    oldScripts = which(REMOVEFILES{s},'-all');
    
    if ~isempty(oldScripts)
 
        %remove files
        if(~iscell(oldScripts))
            delete(oldScripts);
        else
            for d = 1:length(oldScripts)
                delete(oldScripts{d});
            end
        end

        %output which files have been removed
        removed{s} = REMOVEFILES{s};      
    end
end

display('done cleanup!'); 

end
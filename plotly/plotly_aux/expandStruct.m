function strP = expandStruct(S,strP)

if nargin < 2
    strP="pr(1)";
end

% fprintf('%s\n',strP(end));

strIn = strP(end);
if isstruct(S)
    for j=1:numel(S)     
        fn=fieldnames(S(j));
        for i = 1:numel(fn)
            strP = [strP; join([strIn,fn{i}],'.')];
            if isstruct(S(j).(fn{i}))
                strP = expandStruct(S(j).(fn{i}), strP);
            end
        end
    end
end

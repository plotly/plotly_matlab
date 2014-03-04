function text_str = parseText(input_text)

%check for '\' and double up

cases = [];

for i=1:numel(input_text)
    
    if strcmp('\', input_text(i))
        cases = [cases i];
    end
end

if numel(cases)==0
    text_str = input_text;
else   
    text_str=[];
    for i=1:numel(cases)-1
        text_str =  [text_str '\' input_text(cases(i):cases(i+1)-1)];
    end   
    text_str =  [text_str '\' input_text(cases(numel(cases)):end)];
end



end
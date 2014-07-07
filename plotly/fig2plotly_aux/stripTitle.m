function stripped = stripTitle(title)
stripped = title;
tloc = regexp(stripped,'\\text');
try
    for i = 1:length(tloc)
        stripped(tloc(i) - (i-1)*length('\text'):tloc(i)+length('\text')-1-(i-1)*length('\text') ) = '';
    end
end
stripped(regexp(stripped,'\$')) = '';
stripped(regexp(stripped,'{')) ='';
stripped(regexp(stripped,'}')) = '';
stripped(regexp(stripped,'\\')) = '';
stripped(regexp(stripped,'\^')) = '';
stripped(regexp(stripped,'_')) = '';
stripped(regexp(stripped,' ')) = '';
end

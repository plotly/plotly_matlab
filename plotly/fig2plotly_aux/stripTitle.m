function stripped = stripTitle(title)
stripped = title; 
stripped(regexp(stripped,'\$')) = '';
stripped(regexp(stripped,'\\text'):regexp(stripped,'\\text')+length('\text')) = ''; 
stripped(regexp(stripped,'{')) =''; 
stripped(regexp(stripped,'}')) = '';
stripped(regexp(stripped,'\\')) = ''; 
stripped(regexp(stripped,' ')) = ''; 
end

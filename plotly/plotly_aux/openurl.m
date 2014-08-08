function  openurl (url)
status = dos(['open ' url ' > nul 2> nul']);
if status==1
     dos(['start ' url ' > nul 2> nul']);
end
end


function check = isBoxplot(obj, boxIndex)
   check = ~isempty(findobj(obj.State.Plot(boxIndex).Handle,'Tag', 'Box')); 
end

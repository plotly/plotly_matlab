function check = isBoxplot(obj, boxIndex)
   check = any([findobj(obj.State.Plot(boxIndex).Handle,'Tag', 'Box')' findobj(obj.State.Plot(boxIndex).Handle,'Tag', 'Outliers')']); 
end

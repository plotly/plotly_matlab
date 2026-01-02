function colorbarDataIndex = findColorbarData(obj, colorbarIndex, colorbarData)
    if nargin == 2
        %locate index of data associated with colorbar
        colorbarDataIndex = find( ...
            arrayfun( @(x)eq(x.AssociatedAxis, ...
                            obj.State.Colorbar(colorbarIndex).AssociatedAxis), ...
                            obj.State.Plot ...
                    ), ...
            1);
        %if no matching data index found
        if isempty(colorbarDataIndex)
            colorbarDataIndex = max(min(colorbarIndex,obj.State.Figure.NumPlots),1);
        end
    elseif nargin == 3
        c = 1; a = 1;
        allAxesIndex = zeros(length(colorbarData.Parent.Children), 1);
        for n = 1:length(colorbarData.Parent.Children)
            if strcmp(colorbarData.Parent.Children(n).Type, 'colorbar')
                allColorbarIndex(c) = n;
                c = c + 1;
            elseif strcmp(colorbarData.Parent.Children(n).Type, 'axes')
                allAxesIndex(n) = a;
                a = a + 1;
            end
        end
        colorbarAxisIndex = allColorbarIndex(colorbarIndex) + 1;
        colorbarAxisIndex = allAxesIndex(colorbarAxisIndex);
        colorbarDataIndex = obj.State.Figure.NumAxes - colorbarAxisIndex + 1;
        colorbarDataIndex = colorbarDataIndex;
    end
end

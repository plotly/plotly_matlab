function resp = onePlot(fig)
%this helper function looks through the figure fig
%for the number of axes labelled with a "legend" tag
%returns resp = (numAxesLeg - numAxes == 1);

childHan = fig.Children;
numLeg = 0;
numAx = 0;

for i = 1:length(childHan)
    curChild = get(childHan(i));
    if strcmpi(curChild.Type,'axes')
        numAx = numAx + 1;
        if strcmpi(curChild.Tag,'legend')
            numLeg = numLeg + 1;
        end
    end
end

resp = (numAx - numLeg == 1);


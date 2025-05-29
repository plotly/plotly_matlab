function out = getMarkerSymbol(markerStyle)
    switch markerStyle
        case "."
            out = "circle";
        case "o"
            out = "circle";
        case "x"
            out = "x-thin-open";
        case "+"
            out = "cross-thin-open";
        case "*"
            out = "asterisk-open";
        case {"s","square"}
            out = "square";
        case {"d","diamond"}
            out = "diamond";
        case "v"
            out = "triangle-down";
        case "^"
            out = "triangle-up";
        case "<"
            out = "triangle-left";
        case ">"
            out = "triangle-right";
        case {"p","pentagram"}
            out = "star";
        case {"h","hexagram"}
            out = "hexagram";
    end
end

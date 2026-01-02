function lineDash = getLineDash(lineStyle)
    switch lineStyle
        case "-"
            lineDash = "solid";
        case "--"
            lineDash = "dash";
        case ":"
            lineDash = "dot";
        case "-."
            lineDash = "dashdot";
    end
end

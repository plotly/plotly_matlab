function layoutret = setGlobalTitle(text_prop,layout)

% helper function which sets the global plot
% titles in the case of plot with no subplots.
layoutret = layout; 

try
    layoutret.title = text_prop.text;
end

try
    layoutret.titlefont.family = text_prop.font.family;
end

try
    layoutret.titlefont.size = text_prop.font.size;
end

try
    layoutret.tiltefont.color = text_prop.font.color;
end

end


fig = figure;
plot([1,2,3], [10,20,30]);
txt = {'first line', 'second line'};
xlabel(txt);
ylabel(txt);
text(2, 20, txt);
title(txt);

% PLOTLY
response = fig2plotly(fig,'name','matlab_text_as_cell_array');
plotly_url = response.url;

%%
% This is an example of how to create subplots with multiple plot types in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/subplot.html |subplot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the data to be plotted
TBdata = [1990 4889 16.4; 1991 5273 17.4; 1992 5382 17.4; 1993 5173 16.5;
          1994 4860 15.4; 1995 4675 14.7; 1996 4313 13.5; 1997 4059 12.5;
          1998 3855 11.7; 1999 3608 10.8; 2000 3297  9.7; 2001 3332  9.6;
          2002 3169  9.0; 2003 3227  9.0; 2004 2989  8.2; 2005 2903  7.9;
          2006 2779  7.4; 2007 2725  7.2];
      
measles = [38556 24472 14556 18060 19549 8122 28541 7880 3283 4135 7953 1884]';
mumps = [20178 23536 34561 37395 36072 32237 18597 9408 6005 6268 8963 13882]';
chickenPox = [37140 32169 37533 39103 33244 23269 16737 5411 3435 6052 12825 23332]';
years = TBdata(:, 1);
cases = TBdata(:, 2);
rate  = TBdata(:, 3);

% Create the pie chart in position 1 of a 2x2 grid
fig = figure;
subplot(2, 2, 1);
pie([sum(measles) sum(mumps) sum(chickenPox)], {'Measles' 'Mumps' 'Chicken Pox'});
title('Childhood Diseases');

% Create the bar chart in position 2 of a 2x2 grid
subplot(2, 2, 2);
bar(1:12, [measles/1000 mumps/1000 chickenPox/1000], 0.5, 'stack');		
xlabel('Month');
ylabel('Cases (in thousands)');
title('Childhood Diseases');
axis([0 13 0 100]);

% Create the stem chart in position 3 of a 2x2 grid
subplot(2, 2, 3);
stem(years, cases);
xlabel('Years');
ylabel('Cases');
title('Tuberculosis Cases');
axis([1988 2009 0 6000]);

% Create the line plot in position 4 of a 2x2 grid
subplot(2, 2, 4);
plot(years, rate);
xlabel('Years');
ylabel('Infection Rate');
title('Tuberculosis Cases');
axis([1988 2009 5 20]);

response = fig2plotly(fig,'name','mpg_subplots_diff_plot_types');
plotly_url = response.url;


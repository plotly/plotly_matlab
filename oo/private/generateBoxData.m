function y = generateBoxData(outliers, pmin, p25, md, p75, pmax)

%set number of data points
N = numel(outliers)*5+20;


%find percentile numbers

%pn = 100*(1:N-1/2)/N;
pid_25 = floor(N*25/100 + 0.5);
pid_50 = floor(N*50/100 + 0.5);
pid_75 = floor(N*75/100 + 0.5);

% %find p25
% pidx = find(pn<=25);
% pid_25 = pidx(end);
% %find median
% pidx = find(pn<=50);
% pid_50 = pidx(end);
% %find p75
% pidx = find(pn<=75);
% pid_75 = pidx(end);

low_o = outliers(outliers<md);
high_o = outliers(outliers>md);

y=[low_o ...
    linspace(pmin, p25, pid_25-numel(low_o)) ...
    linspace(p25, md, pid_50-pid_25) ...
    linspace(md, p75, pid_75-pid_50) ...
    linspace(p75, pmax, N-pid_75-numel(high_o)) ...
    high_o];



% 
% if numel(low_o)>0
%     y(1:numel(low_o))=low_o;
% end
% if numel(high_o)>0
%     y(end-numel(high_o)+1:end)=high_o;
% end











end
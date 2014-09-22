for n = 1:10
    subplot(5,2,n)
    bar(rand(3,10))
    grid on
    colorbar
    title(['barplot' num2str(n)]);
end

p = plotlyfigure(gcf); 
%strip(p); 
%plotly(p); 

% %plotly low level edits
% for n = 1:length(p.data)
%     p.data{n}.opacity = n/length(p.data); 
% end

%vs.... 

open plotlyfigure
subplot(2,2,3);
imagesc(rand(5,5))
colorbar
subplot(2,2,1);
contour(rand(5,5));
subplot(1,2,2);
imagesc(rand(5,5))
colorbar

p = plotlyfigure(gcf); 
test_account = 'PlotlyImageTest';
test_account_key = '786r5mecv0';
images = [0, 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,...
          21, 22, 23, 24, 27, 28, 30, 31, 32, 34, 35, 37, 38, 41, 51, 52, 29,...
          33, 40, 42, 43, 44, 45, 50, 53, 56, 61, 62];
test_failures_json = [26, 36, 49];
test_failures_toolarge = [39];
signin(test_account, test_account_key);

formats = {'png', 'pdf', 'jpg', 'svg'};
for i=1:length(images)
    for j=1:length(formats)
        disp(['testing https://plot.ly/~PlotlyImageTest/' num2str(images(i)) '.' formats{j}])
        figure = getplotlyfig(test_account, images(i));
        saveplotlyfig(figure.data, figure.layout, ['test_saveplotlyfig_images/' 'PlotlyImageTest_' num2str(images(i))], formats{j});
    end
end
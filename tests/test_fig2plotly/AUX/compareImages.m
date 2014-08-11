%HANDLES IMAGE COMPARISON/LOG CREATION
function log = compareImages(baseDir,testDir,ext)

un = signin;
imagesBase = dir([baseDir '/*.' ext]);
imagesTest = dir([testDir '/*.' ext]);

if(length(imagesBase)~=length(imagesTest))
    fprintf(['\n\nWARNING: please make sure the same number ', ...
        'of images are in both directories and try again!\n\n']);
    return
end

%CREATE LOG CELL
log = cell(1,length(imagesBase));

for n = 1:length(imagesBase)
    if(~strcmp(imagesBase(n).name,imagesTest(n).name))
        log{n} = ['WARNING: ' imagesBase(n).name ' in [BASE] ',...
            'does not match the name of ' imagesTest(n).name ' in [TEST] \n'];
    else
        A = imread([baseDir '/' imagesBase(n).name]);
        B = imread([testDir '/' imagesTest(n).name]);
        if(~isequal(A,B))
            log{n} = ['TESTED: ' imagesBase(n).name ' RESULT: ---------->FAILED \n'];
            
            % take the difference of the two images
            diffMat = abs(A-B);
            % plot the second image compared
            hold on
            imagesc(B);
            %add color marker to indicate difference
            spy(mean(diffMat,3),'ro',10)
            hold off
            %save plotly image as fig
            fn = imagesTest(n).name; 
            fig = gcf; 
            %use "print" to avoid unwanted behaviour if fig2plotly is broken 
            print(fig,[testDir '/' fn(1:end-length(['.' ext])) '_DIFF.eps'],'-depsc');
            %close image
            close;
        else
            log{n} = ['TESTED: ' imagesBase(n).name ' RESULT: PASSED \n'];
        end
    end
end

%WRITE THE LOG TO testDIR
logID = fopen([testDir '/[LOG]'],'w');
fprintf(logID,[log{:}]);
fclose(logID);

end

%HANDLES IMAGE COMPARISON/LOG CREATION 
function log = compareImages(baseDir,testDir,ext)

imagesBase = dir([baseDir '/*.' ext]);
imagesTest = dir([testDir '/*.' ext]);
if(length(imagesBase)~=length(imagesTest))
    sprintf(['\n\nWARNING: please make suer the same number ', ...
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
        A = imread(imagesBase(n).name); 
        B = imread(imagesTest(n).name);
        if(A~=B)
            log{n} = ['TESTED: ' imagesBase(n).name ' RESULT: FAILED \n'];
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

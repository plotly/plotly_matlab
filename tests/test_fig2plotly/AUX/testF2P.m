function testF2P(varargin)

%----------------TESTS------------------- %
%- BED: MATLAB PLOT GALLERY + PLOTLY DOCS- %

% FOR REBASE:
% run scripts in ./TESTING/BANK/MPG(and/or)PD
% create images
% save images in ./TESTING/BASE
% visually inspect images for errors (better way ?)

% FOR TESTS (~REBASE):
% rerun scripts in ./TESTING/BANK/MPG(and/or)PD
% create images
% save images in ./TESTING/[TEST-day-month-year-hour-min-sec]
% compare image using hard pixel difference (pass - fail)
% write results to log

%[TODO]: MAKE WINDOWS COMPATIBLE


%-------TEST DEFAULTS/INITIALIZATION-------%
rebase = false;
usePD = ~logical(nargin);
useMPG = ~logical(nargin); %default to true if no arguments
ext = 'png';
strip = true; 

for i = 1:nargin
    
    %CHECK WHICH EXAMPLES TO INCLUDE
    if(strcmpi(varargin{i},'MPG'))
        useMPG = true;
    end
    
    if(strcmpi(varargin{i},'PD'))
        usePD = true;
    end
    
    %CHECK FOR REBASE OF TESTS
    if(strcmpi(varargin{i},'rebase'))
        rebase = true;
    end
    
    %CHECK FOR IMAGE EXTENSION
    if(strcmpi(varargin{i},'ext'))
        ext = varargin{i+1};
    end
    
    %CHECK FOR STRIP_STYLE
    if(strcmpi(varargin{i},'strip'))
        strip = varargin{i+1};
    end
    
    %TODO: HANDLE EXCLUSIVES/EXCEPTIONS
    %-------------------------------------->
    if(strcmpi(varargin{i},'MPGexcept'))
        MPGexcept = varargin{i+1};
    end
    if(strcmpi(varargin{i},'MPGexclusive'))
        MPGexclusive = varargin{i+1};
    end
    if(strcmpi(varargin{i},'PDexcept'))
        PDexcept = varargin{i+1};
    end
    if(strcmpi(varargin{i},'PDexclusive'))
        PDexclusive = varargin{i+1};
    end
    %-------------------------------------->
end


% ----------FOLDER STRUCTURE-------------%

%STRIP KEY
if(strip)
    STRIP_KEY = '[STRIP]'; 
else
    STRIP_KEY = '[NOSTRIP]'; 
end

%MAIN F2P TEST DIRECTORY
testF2PLocation = which('testF2P.m');
testF2PDir = testF2PLocation(1:strfind(testF2PLocation,'/AUX'));

%MATLAB PLOT GALLERY [TODO]
MPGDirName = fullfile(testF2PDir,'BANK','MPG');

%MATLAB PLOTLY DOCS
PDDirName = fullfile(testF2PDir,'BANK','PD');

%BASE FOLDER
imgBaseDir = fullfile(testF2PDir,['BASE' STRIP_KEY]);

%MAKE BASE FOLDER DIRECTORY IF REBASE
if(rebase)
    if(~exist(imgBaseDir,'dir'))
        mkdir(imgBaseDir);
    end
end

%RESULTS FOLDER
c = clock;
resultsDir = fullfile(testF2PDir,'RESULTS'); 
imgTestDir = fullfile(resultsDir, ['TEST' '[v.' plotly_version '-' date '-', ...
    num2str(c(4)) '-' num2str(c(5)) '-' num2str(floor(c(6))) ']' STRIP_KEY]);

%MAKE TEST FOLDER DIRECTORY IF ~REBASE
if(~rebase)
    try
        if ~exist(imgBaseDir,'dir')
            error('NOBASE - MUST REBASE');
        end
    catch
        fprintf('\nWe cannot locate the BASE directory! Please rebase before proceeding.\n\n');
        return
    end
    mkdir(imgTestDir);
end

% %TODO: USING THE MATLAB PLOT GALLERY SET
% if(useMPG)
%     %get all .m files from MPGDir
%     MPGDir = dir([MPGDirName '/*.m']);
%     %run all .m files from MPGDir not in MPGexcept (or just iin MPGexclusive)
%     runScripts(MPGDirName,MPGDir,rebase,imgBaseDir,imgTestDir,ext);
%     if(~rebase)
%         runScripts(PDDirName,PDDir,imgTestDir,ext);
%         compareImages(imgBaseDir,imgTestDir,ext);
%     else
%         runScripts(PDDirName,PDDir,imgBaseDir,ext);
%         %WRITE THE LOG TO imgBaseDir
%         logID = fopen([imgBaseDir '/[LOG]'],'w');
%         fprintf(logID,['LAST REBASE:' 'TEST' '[ v.' plotly_version '-' date '-', ...
%             num2str(c(4)) '-' num2str(c(5)) '-' num2str(floor(c(6))) ']']);
%         fclose(logID);
%     end
% end

%USING THE PLOTLY DOCS SET
if(usePD)
    %get all .m files from PDDir
    PDDir = dir([PDDirName '/*.m']);
    %run all .m files from PDDir not in PDexcept (or just in PDexclusive) [TODO]
    if(~rebase)
        runScripts(PDDirName,PDDir,imgTestDir,ext);
        compareImages(imgBaseDir,imgTestDir,ext);
    else
        runScripts(PDDirName,PDDir,imgBaseDir,ext);
        %WRITE THE LOG TO imgBaseDir
        logID = fopen([imgBaseDir '/[LOG]'],'w');
        fprintf(logID,['LAST REBASE:' '[v.' plotly_version '-' date '-', ...
            num2str(c(4)) '-' num2str(c(5)) '-' num2str(floor(c(6))) ']']);
        fclose(logID);
    end
end
end

%HANDLES RUNNING OF TESTBANK SCRIPTS
function runScripts(folderName,scriptInfo,imgDir,ext)

un = signin; 

for localInd = 1:length(scriptInfo);
    sc = scriptInfo(localInd).name;
    %seed rand.num. gen.
    s = RandStream('mcg16807','Seed',0);
    RandStream.setGlobalStream(s);
    %run the scripts 
    run(fullfile(folderName,sc));
    %getplotlyfig
    fsInd = findstr(plotly_url,'/');
    plotlyfig = getplotlyfig(un, plotly_url(fsInd(end)+1:end));
    %save iimage in imgDir
    saveplotlyfig(plotlyfig,[imgDir '/' sc(1:end-2)],ext);
    %close figures as they are generated
    close
    %display status
    fprintf(['image: ' sc ' saved as: ' ext ' \n'])
    %clear conflicting variables and preserve local variables
    clearvars -except localInd folderName scriptInfo imgDir ext un 
end
end


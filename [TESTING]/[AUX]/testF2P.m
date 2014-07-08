function testF2P(varargin)

%----------------TESTS------------------- %
%- BED: MATLAB PLOT GALLERY + PLOTLY DOCS- %

% FOR REBASE:
% run scripts in ./[TESTING]/[BANK]/MPG(and/or)PD
% create images  
% save images in ./[TESTING]/[BASE]
% visually inspect images for errors (better way ?) 

% FOR TESTS (~REBASE):
% rerun scripts in ./[TESTING]/[BANK]/MPG(and/or)PD
% create images  
% save images in ./[TESTING]/[TEST-day-month-year-hour-min-sec]
% compare image using hard pixel difference (pass - fail) 
% write results to log 


%-------TEST DEFAULTS/INITIALIZATION-------%
rebase = false;
usePD = ~logical(nargin);
useMPG = ~logical(nargin); %default to true if no arguments
ext = 'svg';

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
    
    %TODO: THIS STUFF --------->
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
    %TODO: TO HERE ----------->
end

% ----------FOLDER STRUCTURE-------------%

%MATLAB PLOT GALLERY
MPGDirName = fullfile(pwd,'[TESTING]/[BANK]/MPG/');

%MATLAB PLOTLY DOCS
PDDirName = fullfile(pwd,'[TESTING]/[BANK]/PD/');

%BASE FOLDER
if(rebase)
    imgBase = mkdir(fullfile(pwd,'[TESTING]'),'[BASE]');
end

%TEST FOLDER

%date/time
c = clock;
d = date;
%test folder name
testName = ['[TEST]' '[' d '-' num2str(c(4)) '-' num2str(c(5)) '-' num2str(floor(c(6))) ']'];
%check for rebase + existence of base folder 
if(~rebase)
    imgTest = mkdir(fullfile(pwd,'[TESTING]'),testName);
    imgTestDir = fullfile(pwd,'[TESTING]',testName);
    try
        imgBaseDir = fullfile(pwd,'[TESTING]','[BASE]');
        if ~exist(imgBaseDir)
            error('NOBASE - MUST REBASE');
        end
    catch
        fprintf('\n\nWe cannot locate the [BASE] directory! Please rebase before proceeding\n\n');
        return
    end
end

%USING THE MATLAB PLOT GALLERY SET
if(useMPG)
    %get all .m files from MPGDir
    MPGDir = dir([MPGDirName '*.m']);
    %run all .m files from MPGDir not in MPGexcept (or just iin MPGexclusive)
    runScripts(MPGDirName,MPGDir,rebase,imgBaseDir,imgTestDir,ext);
    if(~rebase)
        compareImages(imgBaseDir,imgTestDir,ext);
    end
end

%USING THE PLOTLY DOCS SET
if(usePD)
    %get all .m files from PDDir
    PDDir = dir([PDDirName '*.m']);
    %run all .m files from PDDir not in PDexcept (or just in PDexclusive)
    runScripts(PDDirName,PDDir,rebase,imgBaseDir,imgTestDir,ext);
    if(~rebase)
        compareImages(imgBaseDir,imgTestDir,ext);
    end
end
end

%HANDLES RUNNING OF TESTBANK SCRIPTS
function runScripts(folderName,scriptInfo,rebase,imgBaseDir,imgTestDir, ext)
for localInd = 1:length(scriptInfo);
    sc = scriptInfo(localInd).name;
    run([folderName sc]);
    %getplotlyfig
    fsInd = findstr(plotly_url,'/');
    plotlyfig = getplotlyfig('matlab_user_guide',plotly_url(fsInd(end)+1:end));
    %save in base/test depenidng on rebase
    if (rebase)
        saveplotlyfig(plotlyfig,[imgBaseDir '/' sc(1:end-2)],ext);
    else
        saveplotlyfig(plotlyfig,[imgTestDir '/' sc(1:end-2)],ext);
    end
    %close figures as they are generated
    close all
    %clear conflicting variables
    clearvars -except localInd scriptInfo folderName rebase imgBaseDir imgTestDir ext
end
end


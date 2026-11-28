classdef Test_plotlysetup < PlotlyTestCase
    methods
        function testPlotlysetupOfflineFromAnyFolder(tc)
            % the URL cannot resolve, so the real bundle is never replaced
            sandbox = Test_plotlysetup.enterSetupSandbox(); %#ok<NASGU>

            output = evalc(['try, plotlysetup_offline(', ...
                '''https://plotly.invalid/plotly.min.js''); catch, end']);

            tc.verifyTrue(isempty(strfind(output, 'plotly:notFound')), output);
            tc.verifyTrue(~isempty(strfind(output, 'Now downloading')), output);
        end

        function testPlotlysetupOnlineFromAnyFolder(tc)
            if ~is_octave()
                return % MATLAB's getuserdir ignores HOME, so this would overwrite the real credentials.
            end
            sandbox = Test_plotlysetup.enterSetupSandbox(); %#ok<NASGU>

            output = evalc('plotlysetup_online(''setup_test_user'', ''setup_test_key'');');

            tc.verifyTrue(isempty(strfind(output, 'plotly:notFound')), output);
            credentials = loadplotlycredentials();
            tc.verifyEqual(credentials.username, 'setup_test_user');
        end

        function testPersistPlotlyPathPrintsStartupLine(tc)
            if is_octave()
                return % Octave's savepath writes the per-user ~/.octaverc instead.
            end
            pathdefs = which('pathdef.m', '-all');
            before = Test_plotlysetup.fileDatenums(pathdefs);

            output = evalc('persistplotlypath(''/opt/it''''s here/plotly'')');

            tc.verifyTrue(~isempty(strfind(output, 'startup.m')), output);
            tc.verifyTrue(~isempty(strfind(output, ...
                'addpath(genpath(''/opt/it''''s here/plotly''));')), output);
            tc.verifyEqual(Test_plotlysetup.fileDatenums(pathdefs), before);
        end

        function testPersistPlotlyPathSavesOctaverc(tc)
            if ~is_octave()
                return % MATLAB users get a startup.m line instead.
            end
            plotlyFolder = fileparts(which('fig2plotly'));
            sandbox = Test_plotlysetup.enterSetupSandbox(); %#ok<NASGU>

            output = evalc('persistplotlypath(plotlyFolder)');

            octaverc = fullfile(getenv('HOME'), '.octaverc');
            tc.verifyTrue(exist(octaverc, 'file') == 2, octaverc);
            tc.verifyTrue(~isempty(strfind(fileread(octaverc), plotlyFolder)));
            tc.verifyTrue(isempty(strfind(output, 'add this line')), output);
        end

        function testPersistPlotlyPathOctavercUnwritable(tc)
            if ~is_octave()
                return % MATLAB users get a startup.m line instead.
            end
            sandbox = Test_plotlysetup.enterSetupSandbox(); %#ok<NASGU>
            setenv('HOME', fullfile(getenv('HOME'), 'missing'));

            output = evalc('persistplotlypath(''/opt/plotly'')');

            tc.verifyTrue(~isempty(strfind(output, '~/.octaverc')), output);
            tc.verifyTrue(~isempty(strfind(output, ...
                'addpath(genpath(''/opt/plotly''));')), output);
        end
    end

    methods (Static)
        function sandbox = enterSetupSandbox()
            %-run the setup scripts, which live in the repository root,
            %-from an empty folder that is also HOME; the returned object
            %-restores folder, HOME and the repository root's absence from
            %-the path when it goes out of scope (restoring the whole path
            %-with path() breaks the running test object in Octave)-%
            oldFolder = pwd();
            oldHome = getenv('HOME');
            repoRoot = fileparts(fileparts(which('fig2plotly')));
            rootWasOnPath = ~isempty(strfind([pathsep path() pathsep], ...
                [pathsep repoRoot pathsep]));
            home = tempname();
            mkdir(home);
            cd(home);
            setenv('HOME', home);
            addpath(repoRoot);
            sandbox = onCleanup(@() Test_plotlysetup.leaveSetupSandbox( ...
                oldFolder, oldHome, home, repoRoot, rootWasOnPath));
        end

        function leaveSetupSandbox(oldFolder, oldHome, home, repoRoot, rootWasOnPath)
            if ~rootWasOnPath
                rmpath(repoRoot);
            end
            cd(oldFolder);
            setenv('HOME', oldHome);
            try rmdir(home, 's'); catch; end
        end

        function datenums = fileDatenums(files)
            datenums = zeros(size(files));
            for i = 1:numel(files)
                info = dir(files{i});
                datenums(i) = info.datenum;
            end
        end
    end
end

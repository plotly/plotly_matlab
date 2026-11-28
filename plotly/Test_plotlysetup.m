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

        function testPrintPlotlyPathHint(tc)
            sandbox = Test_plotlysetup.enterSetupSandbox(); %#ok<NASGU>
            if is_octave()
                startupFile = '~/.octaverc';
                pathdefs = {};
            else
                startupFile = 'startup.m (in the folder that userpath returns)';
                pathdefs = which('pathdef.m', '-all');
            end
            before = Test_plotlysetup.fileDatenums(pathdefs);

            output = evalc('printplotlypathhint(''/opt/it''''s here/plotly'')');

            tc.verifyTrue(~isempty(strfind(output, ...
                ['add this line to your ' startupFile])), output);
            tc.verifyTrue(~isempty(strfind(output, ...
                'addpath(genpath(''/opt/it''''s here/plotly''));')), output);
            tc.verifyEqual(Test_plotlysetup.fileDatenums(pathdefs), before);
            tc.verifyNumElements(dir(fullfile(getenv('HOME'), '.octaverc')), 0);
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
            if is_octave()
                confirm_recursive_rmdir(false, 'local');
            end
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

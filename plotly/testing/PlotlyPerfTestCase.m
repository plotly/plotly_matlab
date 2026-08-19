classdef PlotlyPerfTestCase < PlotlyTestCase
    % PlotlyPerfTestCase: performance tests measured with keepMeasuring.
    %
    % A performance test wraps the measured code in a while loop:
    %
    %   function testFoo(tc)
    %       while tc.keepMeasuring
    %           doWork();
    %       end
    %       tc.verifyTrue(doWorkCorrect());
    %   end
    %
    % Each loop iteration is one measurement: keepMeasuring returns the
    % wall time elapsed since the previous call, so one body execution
    % is timed per call.  The first NumWarmups measurements are
    % discarded, then samples are collected until their relative margin
    % of error (Student-t at ConfidenceLevel, n-1 degrees of freedom)
    % falls below RelativeMarginOfError, with MinSamples as the minimum
    % and MaxSamples as the cap.

    properties
        NumWarmups = 5
        MinSamples = 4
        MaxSamples = 256
        RelativeMarginOfError = 0.05
        ConfidenceLevel = 0.95
    end

    properties (Access = protected)
        p_timer = []
        p_times = []
        p_nSamples = 0
        p_warmupsDone = 0
        p_measuringTest = ''
    end

    methods
        function ok = keepMeasuring(tc)
            % true while more measurements are needed
            if ~strcmp(tc.p_measuringTest, tc.CurrentTest)
                % first call of this test case: reset the state and
                % start timing the first body execution
                tc.p_measuringTest = tc.CurrentTest;
                tc.p_times = zeros(1, tc.MaxSamples);
                tc.p_nSamples = 0;
                tc.p_warmupsDone = 0;
                tc.p_timer = tic;
                ok = true;
                return;
            end

            dt = toc(tc.p_timer);
            tc.p_timer = tic;

            if tc.p_warmupsDone < tc.NumWarmups
                tc.p_warmupsDone = tc.p_warmupsDone + 1;
                ok = true;
                return;
            end

            tc.p_nSamples = tc.p_nSamples + 1;
            tc.p_times(tc.p_nSamples) = dt;
            if tc.p_nSamples < tc.MinSamples || tc.p_nSamples >= tc.MaxSamples
                ok = tc.p_nSamples < tc.MaxSamples;
                return;
            end

            m = mean(tc.p_times(1:tc.p_nSamples));
            if m > 0
                s = std(tc.p_times(1:tc.p_nSamples));
                T = tc.tQuantile(tc.p_nSamples - 1);
                relMoE = T * s / (m * sqrt(tc.p_nSamples));
                if relMoE <= tc.RelativeMarginOfError
                    ok = false;
                    return;
                end
            end
            ok = true;
        end
        function s = sampleStats(tc)
            % statistics of the collected samples; NumSamples is 0 when
            % nothing was measured
            if tc.p_nSamples == 0
                s = struct('NumSamples', 0, 'Mean', [], 'Std', [], ...
                    'Min', [], 'Max', [], 'RelMoE', [], ...
                    'NumWarmups', tc.p_warmupsDone);
                return;
            end
            x = tc.p_times(1:tc.p_nSamples);
            m = mean(x);
            sd = std(x);
            if m > 0
                relMoE = tc.tQuantile(tc.p_nSamples - 1) * sd / (m * sqrt(tc.p_nSamples));
            else
                relMoE = [];
            end
            s = struct('NumSamples', tc.p_nSamples, ...
                'Mean', m, ...
                'Std', sd, ...
                'Min', min(x), ...
                'Max', max(x), ...
                'RelMoE', relMoE, ...
                'NumWarmups', tc.p_warmupsDone);
        end
    end

    methods (Access = private)
        function T = tQuantile(tc, dof)
            % two-tailed Student-t critical value at ConfidenceLevel;
            % the normal approximation avoids a Statistics dependency
            if exist('tinv')
                try
                    T = tinv(1 - (1 - tc.ConfidenceLevel) / 2, dof);
                    return;
                catch
                end
            end
            T = 1.96;
        end
    end
end

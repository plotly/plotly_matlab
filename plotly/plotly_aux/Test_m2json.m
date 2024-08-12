classdef Test_m2json < matlab.unittest.TestCase
    methods (Test)
        function testLowPrecisionInRange0to10(tc)
            values = 1 + (1:5) + 0.234;
            expected = "[2.234,3.234,4.234,5.234,6.234]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRange0to10(tc)
            values = 1 + (1:5) + 0.23456789;
            expected = "[2.23456789,3.23456789,4.23456789,5.23456789," ...
                    + "6.23456789]";
            tc.verifyEqual(m2json(values), expected);
        end

        function test2dArrayInRange0to10(tc)
            values = 1 + (1:5) + (0:1)' + 0.234;
            expected = "[[2.234,3.234,4.234,5.234,6.234]," ...
                    + "[3.234,4.234,5.234,6.234,7.234]]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testLowPrecisionInRange1e6to1e5(tc)
            values = 1e-6 * (1 + (1:5) + 0.234);
            expected = "[2.234e-06,3.234e-06,4.234e-06,5.234e-06," ...
                    + "6.234e-06]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRange1e6to1e5(tc)
            values = 1e-6 * (1 + (1:5) + 0.23456789);
            expected = "[2.23456789e-06,3.23456789e-06,4.23456789e-06," ...
                    + "5.23456789e-06,6.23456789e-06]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRange1e14Plus0to1(tc)
            values = 1e14 + (1:5) + 0.23456789;
            expected = "[100000000000001,100000000000002,"...
                    + "100000000000003,100000000000004,100000000000005]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRange1e14Plus1e7Plus0to1(tc)
            values = 1e14 + 1e7 + (1:5) + 0.23456789;
            expected = "[100000010000001,100000010000002," ...
                    + "100000010000003,100000010000004,100000010000005]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testLogScaledVariables(tc)
            values = 1e14 + 10.^(1:5) + 0.23456789;
            expected = "[100000000000010,100000000000100," ...
                    + "100000000001000,100000000010000,100000000100000]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testLowPrecisionInRangeMinus10to0(tc)
            values = -(1 + (1:5) + 0.234);
            expected = "[-2.234,-3.234,-4.234,-5.234,-6.234]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRangeMinus10to0(tc)
            values = -(1 + (1:5) + 0.23456789);
            expected = "[-2.23456789,-3.23456789,-4.23456789," ...
                    + "-5.23456789,-6.23456789]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRangeMinus1e5toMinus1e6(tc)
            values = -1e-6 * (1 + (1:5) + 0.23456789);
            expected = "[-2.23456789e-06,-3.23456789e-06," ...
                    + "-4.23456789e-06,-5.23456789e-06,-6.23456789e-06]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testInRangeMinus1e14Plus0to1(tc)
            values = -1e14 + (1:5) + 0.23456789;
            expected = "[-99999999999998.8,-99999999999997.8," ...
                    + "-99999999999996.8,-99999999999995.8," ...
                    + "-99999999999994.8]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testEmpty(tc)
            values = [];
            expected = "[]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testCell(tc)
            values = {1, "text", [1,2,3]};
            expected = "[1, ""text"", [1,2,3]]";
            tc.verifyEqual(m2json(values), expected);
        end

        function testStruct(tc)
            values = struct("a", 1, "b", "text");
            expected = "{""a"" : 1, ""b"" : ""text""}";
            tc.verifyEqual(m2json(values), expected);
        end

        function testDatetime(tc)
            value = datetime("2023-05-01 12:30:45");
            expected = """2023-05-01 12:30:45""";
            tc.verifyEqual(m2json(value), expected);
        end

        function testDate(tc)
            value = datetime("2023-05-01");
            expected = """2023-05-01""";
            tc.verifyEqual(m2json(value), expected);
        end

        function testLogicalTrue(tc)
            value = true;
            expected = "true";
            tc.verifyEqual(m2json(value), expected);
        end

        function testLogicalFalse(tc)
            value = false;
            expected = "false";
            tc.verifyEqual(m2json(value), expected);
        end

        function testCharArray(tc)
            value = 'Hello';
            expected = """Hello""";
            tc.verifyEqual(m2json(value), expected);
        end

        function testString(tc)
            value = "World";
            expected = """World""";
            tc.verifyEqual(m2json(value), expected);
        end
    end
end

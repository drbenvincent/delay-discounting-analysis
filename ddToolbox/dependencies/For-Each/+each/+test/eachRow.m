classdef eachRow < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.    
    methods (Test)
        
        function numberOfIterations(testcase)
        A = magic(6);
        loopCounter = 0;
        for elem = eachRow(A)
            loopCounter = loopCounter+1;
            testcase.verifyEqual(elem,A(loopCounter,:));
        end
        testcase.verifyEqual(loopCounter,6);
        end
    end
end
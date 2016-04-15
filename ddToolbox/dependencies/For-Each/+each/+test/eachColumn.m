classdef eachColumn < matlab.unittest.TestCase
    
    methods (Test)
        
        function numberOfIterations(testcase)
        A = magic(6);
        loopCounter = 0;
        for elem = eachColumn(A)
            loopCounter = loopCounter+1;
            testcase.verifyEqual(elem,A(:,loopCounter));
        end
        testcase.verifyEqual(loopCounter,6);
        end
    end
end
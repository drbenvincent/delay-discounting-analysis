classdef Iterable < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.    
    methods (Test)
        
        function negativeTest(testcase)
            import each.test.helpers.NumberOfIterationsHelper;
            
            testcase.verifyError(@() NumberOfIterationsHelper(magic(3)),...
                'Iterators:Iterable:NumberOfIterations')
            
            testcase.verifyError(@() NumberOfIterationsHelper('F'),...
                'Iterators:Iterable:NumberOfIterations')
            
        end
        
        function FloorNumberOfIterations(testcase)
            import each.test.helpers.NumberOfIterationsHelper;
            
            IO = NumberOfIterationsHelper(2.5);
            testcase.verifyEqual(IO.NumberOfIterations,2);
        end
    end
end
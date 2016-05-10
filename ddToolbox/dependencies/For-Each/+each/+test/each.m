classdef each < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.    
    methods (Test)
        
        function eachVector(testcase)
            A = rand(9,1);
            loopCounter = 0;
            for elem = each(A)
                loopCounter = loopCounter+1;
                testcase.verifyEqual(elem,A(loopCounter));
            end
            testcase.verifyEqual(loopCounter,numel(A));
        end
        
        function eachMatrix(testcase)
            A = magic(3);
            loopCounter = 0;
            for elem = each(A)
                loopCounter = loopCounter+1;
                testcase.verifyEqual(elem,A(loopCounter));
            end
            testcase.verifyEqual(loopCounter,numel(A));
        end
        
        function eachNDArray(testcase)
            A = randi(5,3,3,4);
            loopCounter = 0;
            for elem = each(A)
                loopCounter = loopCounter+1;
                testcase.verifyEqual(elem,A(loopCounter));
            end
            testcase.verifyEqual(loopCounter,numel(A));
        end
        
        function eachCell(testcase)
            A = randi(5,3,3,4);
            C = num2cell(A);
            loopCounter = 0;
            
            for elem = each(C)
                loopCounter = loopCounter+1;
                testcase.verifyEqual(elem,A(loopCounter));
            end
            testcase.verifyEqual(loopCounter,numel(C));
        end
        
        function eachEmpty(testcase)
            A = double.empty(0,0,0,1);
            loopCounter = 0;
            for elem = each(A)
                loopCounter = loopCounter+1;
            end
            testcase.verifyEqual(loopCounter,0);
            
            A = double.empty(0,1);
            loopCounter = 0;
            for elem = each(A)
                loopCounter = loopCounter+1;
            end
            testcase.verifyEqual(loopCounter,0);
        end
        
        function bad_indexing(testcase)
            
            try
                for elem = each(each.test.helpers.BadIndexing)
                    % Should never enter this loop.
                end
            catch ME
                testcase.verifyEqual(ME.identifier,'iterators:test:badindexing');
            end
        end
        
        function numberArguments(testcase)
            
            testcase.verifyError(@()each(),'MATLAB:minrhs');
            testcase.verifyError(@()each(1,2),'MATLAB:TooManyInputs');
            try
                [~,~] = each(1);
            catch ME
                testcase.verifyEqual(ME.identifier,'MATLAB:TooManyOutputs');
            end
        end
        
        function eachTupleWithIter(testcase)
            cells = {};
            for x = eachTuple([1, 2, 3], each([4, 5, 6]))
                cells(end+1, 1:2) = x; %#ok
            end
            testcase.verifyEqual(cells, ...
                {1, 4; 2, 5; 3, 6 });
        end
        
        function eachCombinationWithIter(testcase)
            cells = {};
            for x = eachCombination([1, 2, 3], each([4, 5, 6]))
                cells(end+1, 1:2) = x; %#ok
            end
            testcase.verifyEqual(cells, ...
                {1, 4; 1, 5; 1, 6; 2, 4; 2, 5; 2, 6; 3, 4; 3, 5; 3, 6});
        end
    end
end
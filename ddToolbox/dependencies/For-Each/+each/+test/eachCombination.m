classdef eachCombination < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.    
    methods (Test)

        function doubleIteration(testcase)
        % Basic functionality test. The number of loop iterations should be
        % the product of the two array sizes.
        iA = 1:5;
        iB = 1:3;
        % Loop counter shold be independent of the each iterator
        loopCounter = 0;
        for elem = eachCombination(iA,iB)
            [ia,ib] = elem{:};
            loopCounter = loopCounter+1;
            testcase.verifyEqual(ia,iA(ia));
            testcase.verifyEqual(ib,iB(ib));
        end
        
        testcase.verifyEqual(loopCounter,numel(iA)*numel(iB));
        
        end
        
        function multipleIteration(testcase)
        % Validate three arrays work as expected.
        iA = 1:5;
        iB = 1:3;
        iC = 'abcd';
        
        % use two loop counters, don't want to rely on the self-indexing 
        % for all the tests.
        loopCounter = 0;
        charLoopCounter = 0;
        for elem = eachCombination(iA,iB,iC)
            [ia,ib,ic] = elem{:};
            loopCounter = loopCounter+1;
            charLoopCounter = mod(charLoopCounter,numel(iC))+1;
            testcase.verifyEqual(ia,iA(ia));
            testcase.verifyEqual(ib,iB(ib));
            testcase.verifyEqual(ic,iC(charLoopCounter)); 
        end
        
        testcase.verifyEqual(loopCounter,numel(iA)*numel(iB)*numel(iC));
        
        end
        
        
        function emptyCombination(testcase)
        % An empty array in the combination should result in no Loops.
        iA = 1:10;
        iB = 1:0; % <--- is empty, so zero loops should occur.
        iC = 'abcdef';
        
        loopCounter = 0;
        for elem = eachCombination(iA,iB,iC)
            loopCounter = loopCounter+1;
            testcase.assertTrue(false,'This Code should not execute');
        end
        
        testcase.verifyEqual(loopCounter,0);
        
        end
        
        function eachCombinationWithIter(testcase)
        % If the input of eachCombination is an iterator, use that iterator
        % not an iterator over a scalar iterator.
        
            cells = {};
            for x = eachCombination([1, 2, 3], each([4, 5, 6]))
                cells(end+1, 1:2) = x; %#ok
            end
            testcase.verifyEqual(cells, ...
                {1, 4;
                 1, 5;
                 1, 6;
                 2, 4;
                 2, 5;
                 2, 6;
                 3, 4;
                 3, 5;
                 3, 6});
        end
        
    end
end
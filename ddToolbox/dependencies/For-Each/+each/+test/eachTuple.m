classdef eachTuple < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.
    methods (Test)
        
        function SameTypes(testcase)
        
        A = 1:10;
        B = -5:4;
        loopCounter = 0;
        for elem = eachTuple(A,B)
            testcase.verifySize(elem,[1,2]);
            [a,b] = elem{:};
            loopCounter = loopCounter + 1;
            % You don't want to include the index in the loop to
            % make sure the loop returns as expected. Must have a
            % decoupled test to verify the order is as expected.
            testcase.verifyEqual(a,A(loopCounter));
            testcase.verifyEqual(b,B(loopCounter));
        end
        testcase.verifyEqual(loopCounter,10,'Ten iterations are expected');
        end
        
        function  multipleTypes(testcase)
        
        letters = {'a','b','c','d','e'};
        % Note, using the second input of eachTuple to verify the loop count
        % SameTypes tests validates the loop counters will be correct.
        for elem = eachTuple(letters,1:5)
            [str,i] = elem{:};
            testcase.verifyEqual(str,letters{i});
        end
        
        end
        
        function multipleArrays(testcase)
        % Verify many arrays work as expected with a tuple.
        numberOfIterations = 5;
        A = randi(5,numberOfIterations,1);
        B = randi(5,numberOfIterations,1);

        D = num2cell(A);
        E = repmat(struct('x',0),numberOfIterations,1);
        for i = 1:numberOfIterations;E(i).x = B(i);end
        
        for elem = eachTuple(A,B,D,E,1:numberOfIterations)
            testcase.verifySize(elem,[1 5]);
            [a,b,d,e,i] = elem{:};
            
            testcase.verifyEqual(a,A(i));
            testcase.verifyEqual(b,B(i));

            testcase.verifyEqual(d,A(i));
            testcase.verifyEqual(e,struct('x',B(i)));
        end
        end
        
        function mismatchedLengths(testcase)
        % See subfunction - This is for an error.
        testcase.verifyError(@mismatcherr,'iterators:Tuple:MismatchSize');
        end
        
        function eachTupleWithIter(testcase)
        % eachTuple should use the iterator passed into it, and not try to 
        % loop over the scalar iterator being passed in
        cells = {};
        for x = eachTuple([1, 2, 3], each([4, 5, 6]))
            cells(end+1, 1:2) = x; %#ok
        end
        testcase.verifyEqual(cells, ...
            {1, 4;
            2, 5;
            3, 6 });
        end
        
    end
end

function mismatcherr()
% This will error, factored into subfunction for ease of reading.
for elem = eachTuple(1,1:2), end

end
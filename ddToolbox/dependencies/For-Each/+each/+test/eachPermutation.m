classdef eachPermutation < matlab.unittest.TestCase
    %   Copyright 2014 The MathWorks, Inc.    
    methods (Test)
        
        function inputArgs(testcase)
            
            io = eachPermutation([1 2 3],'unique');
            testcase.verifyClass(io,'each.iterators.UniquePermutationIterator');
            
            io = eachPermutation([1 2 3],'ALL');
            testcase.verifyClass(io,'each.iterators.AllPermutationIterator');
            
            testcase.verifyError(@() eachPermutation([1 2 3],'wat'),'MATLAB:unrecognizedStringChoice');
        end
        function smallIterations_Double(testcase)
        % Generally speaking, permutations take too long to run to make a 
        % suitable test. For the smallest vectors, we can do some useful 
        % things. 
        vect = [1 2 3 4 5];
        expPerms = sortrows(perms(vect));
        
        loopCounter = 0;
        actPerms1 = [];
        for perm = eachPermutation(vect)
            loopCounter = loopCounter +1;
            actPerms1 = [actPerms1; perm]; %#ok<AGROW>
        end
        testcase.verifyEqual(actPerms1,expPerms);
        testcase.verifyEqual(loopCounter,factorial(numel(vect)));
        end
        
        function smallIterations_Char(testcase)
        loopCounter = 0;
        actPerms2 = [];
        str = 'abcde';
        expPerms = sortrows(perms([1 2 3 4 5]));
        for perm = eachPermutation(str)
            loopCounter = loopCounter +1;
            actPerms2 = [actPerms2; perm]; %#ok<AGROW>
        end
        
        testcase.verifyEqual(actPerms2,str(expPerms));
        testcase.verifyEqual(loopCounter,factorial(numel(str)));
        end 
        
        function smallIterations_String(testcase)
        loopCounter = 0;
        actPerms3 = {};
        cellstrings = {'all','along','the','watch','tower'};
        for perm = eachPermutation(cellstrings)
            loopCounter = loopCounter +1;
            actPerms3 = [actPerms3; perm]; %#ok<AGROW>
        end
        
        perIds = unique(perms([1 2 3 4 5]),'rows');
        cellstrings = sort(cellstrings);
        testcase.verifyEqual(actPerms3,cellstrings(perIds));
        end
        
        function smallIterations_Duplicate(testcase)
        vect1 = [1 2 2 3 4 4];
        expPerms2 = unique(perms(vect1),'rows');

        loopCounter = 0;
        for perm = eachPermutation(vect1)
            loopCounter = loopCounter +1;
            testcase.verifyEqual(perm,expPerms2(loopCounter,:));
        end        
        testcase.verifyEqual(loopCounter,factorial(numel(vect1))/4);
        end
        
        function smallIterations_DuplicateAll(testcase)
        vect1 = [1 2 2 3 4 4];
        expPerms2 = sortrows(perms(vect1));

        loopCounter = 0;
        actPerms = [];
        for perm = eachPermutation(vect1,'all')
            loopCounter = loopCounter +1;
            actPerms = [actPerms;perm]; %#ok<AGROW>
        end 
        testcase.verifyEqual(actPerms,expPerms2);
        testcase.verifyEqual(loopCounter,factorial(numel(vect1)));
        end
        
        function numberOfPerms(testcase)
        % For these tests, it is more convienient to check the number of 
        % iterations promised by the iterator than to try to perform the 
        % number of iterations. These number of iterations can exceed 
        % the range which is accurate with floating point numbers, and have 
        % been calculated independently to ensure the function is correct.
        vect = [0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1];
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,48620);
        testcase.verifyEqual(permIter.FirstVector,sort(vect));
        
        vect = [zeros(1,10) ones(1,20)];
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,30045015); 
        testcase.verifyEqual(permIter.FirstVector,sort(vect));
        
        vect = repmat([1 2 3],1,10);
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,5550996791340); 
        testcase.verifyEqual(permIter.FirstVector,sort(vect));
        
        vect = 36:-2:1;
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,6402373705728000); 
        testcase.verifyEqual(permIter.FirstVector,sort(vect));
        
        vect = [zeros(1,48) ones(1,18)];
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,6848956078664700); 
        testcase.verifyEqual(permIter.FirstVector,sort(vect));

        % really close to 2/eps
        vect = [1 1 2 2 repmat(1:3,1,11)];
        permIter = eachPermutation(vect);
        testcase.verifyEqual(permIter.NumberOfIterations,8892431376091200); 
        testcase.verifyEqual(permIter.FirstVector,sort(vect));
        
        % This exceeds 2^52 and will not error if converted to use uint64
        % for number of perms. However, that is not supported for releases
        % prior to R2013a.
        vect = [zeros(1,32) ones(1,33)];
        testcase.verifyError(@()eachPermutation(vect),'each:iterators:TooManyIterations');

        % permIter = eachPermutation(vect);
        % testcase.verifyEqual(permIter.NumberOfIterations,uint64(3609714217008132870));
        % testcase.verifyEqual(permIter.FirstVector,sort(vect));

        vect = [zeros(1,49) ones(1,18)];
        testcase.verifyError(@()eachPermutation(vect),'each:iterators:TooManyIterations');
        
        vect = [zeros(1,48) ones(1,19)];
        testcase.verifyError(@()eachPermutation(vect),'each:iterators:TooManyIterations');

        
        end
                
        function tooManyIterations(testcase)
            testcase.verifyError(@()eachPermutation(1:1000),'each:iterators:TooManyIterations')
        end
        
        function smallIterationsNonUnique(testcase)
        % Generally speaking, permutations take too long to run to make a 
        % suitable test. For the smallest vectors, we can do some useful 
        % things. 
        vect = [1 2 3 4 5];
        expPerms = sortrows(perms(vect));
        
        loopCounter = 0;
        actPerms1 = [];
        for perm = eachPermutation(vect,'all') % No different with unique elements
            loopCounter = loopCounter +1;
            actPerms1 = [actPerms1; perm]; %#ok<AGROW>
        end
        testcase.verifyEqual(actPerms1,expPerms);
        testcase.verifyEqual(loopCounter,factorial(numel(vect)));
        
        
        loopCounter = 0;
        actPerms2 = [];
        str = 'abcde';
        for perm = eachPermutation(str)
            loopCounter = loopCounter +1;
            actPerms2 = [actPerms2; perm]; %#ok<AGROW>
        end
        
        testcase.verifyEqual(actPerms2,str(expPerms));
        testcase.verifyEqual(loopCounter,factorial(numel(str)));
        
        loopCounter = 0;
        actPerms3 = {};
        cellstrings = {'all','along','the','watch','tower'};
        for perm = eachPermutation(cellstrings)
            loopCounter = loopCounter +1;
            actPerms3 = [actPerms3; perm]; %#ok<AGROW>
        end
        
        % Strings aren't in sorted order, so we need to sort the input before indexing into it.
        cellstrings = sort(cellstrings); 
        testcase.verifyEqual(actPerms3, cellstrings(expPerms) );
        testcase.verifyEqual(loopCounter,factorial(numel(cellstrings)));
        
        end
        
        function allPermutationsCounts(testcase)
        vect = [0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1];
        permIter = eachPermutation(vect,'all');
        testcase.verifyEqual(permIter.NumberOfIterations,355687428096000);
        testcase.verifyEqual(permIter.FirstVector,sort(vect));

        end
        
        function emptyPermutations(testcase)
            permIter = eachPermutation([],'all');
            testcase.verifyEqual(permIter.NumberOfIterations,0);
            permIter = eachPermutation([],'unique');
            testcase.verifyEqual(permIter.NumberOfIterations,0);
        end
    end
end
function out = eachCombination(varargin)
% EACHCOMBINATION Loop over each combination of N elements in N arrays.
% Use EACHCOMBINATION to iterate over every combination of elements from 
% the arrays A1 through AN. 
% 
% The input arrays to EACHCOMBINATION (A1, A2, ..., AN) must all work with 
% the each function. They do not have to be the same data type, nor have 
% the same number of elements.
%
%     for elem = EACHCOMBINATION(A1,A2,...,AN)
%         % elem{1} is from A1
%         % elem{2} is from A2
%         ...
%         % elem{N} is from AN
%         ... % Loop Body
%     end
%
% In each loop iteration, elem is a cell array containing the next 
% combination of elements in the same order as the nested loop below.
%
%     for k1 = 1:numel(A1)
%         for k2 = 1:numel(A2)
%         ... % until we get to
%             for kN = 1:numel(AN)
%                 elem{1} = A1(k1);
%                 elem{2} = A2(k2);
%                 ... % for every input array
%                 elem{N} = An(kN);
%                 ... % Loop Body
%             end
%         ...
%         end
%     end
%
% The total number of iterations is the product of the number of elements 
% in each array.
%
% Example, use EACHCOMBINATION instead of a nested loop:
%
%     workdays = {'Monday','Tuesday','Wednesday'};
%     relations = {'at','before','after'};
%     timesOfDay = {'dawn','noon','midnight'};
%
%     for strings = eachCombination(workdays,relations,timesOfDay)
%         fprintf('Meet me %s.\n',strjoin(strings,' '))
%     end
%
% You can collapse a nested loop to build a 3D array.
%
%     sx = 4;    sy = 5;    sz = 3;
%     A = zeros(sx,sy,sz);
%     for idxs = eachCombination(1:sx,1:sy,1:sz)
%         [i,j,k] = idxs{:};
%         A(i,j,k) = sqrt(sum(randn(3,1).^2));
%     end
% 
% EACHCOMBINATION also accepts inputs which are the results of another 
% each* function. 
%
% Example, using the results of each* functions in EACHCOMBINATION.
%
%     A = magic(3); B = randn(3);
%     for elem = eachCombination(eachRow(A),eachColumn(B))
%         [a,b] = elem{:};
%         % dot product of each combination of each row and column.
%         C(end+1) = a*b; 
%     end
%
% See also each, eachSlice, cell/each, eachTuple, eachPermutation
% 

%   Copyright 2014 The MathWorks, Inc.

out = each.iterators.CombinationIterator(varargin{:});
end
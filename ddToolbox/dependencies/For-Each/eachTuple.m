function out = eachTuple(varargin)
%EACHTUPLE Loop over each tuple of N elements in N arrays
% Use EACHTUPLE(A1,A2,...,AN) to loop over all the elements of multiple 
% arrays which all have the same size.
%
% The input arrays to eachTuple (A1, A2, ..., AN) must work with the 
% function each. They do not have to be the same data type, but do need to 
% have the same number of elements
%
%    for elem = EACHPTUPLE(A1,A2,...,AN)
%        % elem{1} is from A1
%        % elem{2} is from A2
%        ...
%        % elem{N} is from AN
%        ... % Loop Body
%    end
%
% In each iteration, ELEM is a cell array containing the next set of 
% elements of each array Ai. The output of this loop is the same as:
%
%    for k = 1:numel(A1)
%        elem{1} = A1(k);
%        elem{2} = A2(k);
%        ...
%        elem{N} = AN(k);
%        ... % Loop Body
%    end
%
% If any of the input arrays are the return value of an each* function,   
% EACHTUPLE uses that function to perform the iterations for that element.
% When using another each* function in EACHTUPLE, the functions must all 
% produce the same number of iterations.
%
% Example, using EACHTUPLE with another each* function:
%
%     sx = 2; sy = 3; sz = 4;
%     A = rand(sx,sy,sz);
% 
%     for elem = eachTuple(A, eachCombination(1:sx,1:sy,1:sz) )
%         % Storing cell results in variables for easier reading.
%         [a,ids] = elem{:}; % elem will be a 2 element cell array
%
%         % Note: the second element is the kth result of using 
%         % eachCombination. 
%         [i,j,k] = ids{:};  % ids is a 3 element cell array.
% 
%         B(i,k,j) = a; % Note: the order of indices is different here.
%     end
%
% See also each, eachSlice, cell/each, eachCombination, eachPermutation
%

%   Copyright 2014 The MathWorks, Inc.

out = each.iterators.TupleIterator(varargin{:});
end
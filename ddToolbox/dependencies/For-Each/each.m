function out = each(A)
% EACH Step through each element in an array.
% The general form of a for-EACH statement:
% 
%   for variable = EACH(expr), statement, ..., statement, end
%         
% The individual elements of the expression are stored one at a time in the
% variable, and then the following statements are executed.
% The expression must result in an array which can be indexed using 
% MATLAB® linear indexing. i.e. A(k) does not error.
%
% Use a for-EACH loop to step through each element in A
% without specifying the number of elements or its size.
% 
%     for elem = EACH(A)
%         % Loop Body - Your Code
%     end
% 
% When EACH takes the next step, it sets elem to the next element in A.
% The output of the above loop is the same as:
% 
%     for k = 1:numel(A)
%         elem = A(k);
%         % Loop Body - Your Code
%     end
%
% Note: The data type of the element is the same as A for most MATLAB
% types. For cell arrays, see the help for cell/each.
%
% See also for, eachRow, eachColumn, eachSlice, cell/each, eachTuple,
%           eachCombination, eachPermutation

%   Copyright 2014 The MathWorks, Inc.

out = each.iterators.ArrayIterator(A);
end
function IO = eachRow(A)
% EACHROW Loop over each row in an array
% Use EACHROW(A) to iterate over each row in an array.
%    
%    for elem = EACHROW(A)
%        ...
%    end
%
% In each iteration, elem is the next row of the array A, a 1-by-N array, 
% where N = size(A,2). EACHROW performs numel(A)/size(A,2) iterations.
% 
%  See also each, cell/each, eachColumn, eachPage, eachSlice

%   Copyright 2014 The MathWorks, Inc.

IO = each.iterators.ArraySliceIterator(A,1);
end
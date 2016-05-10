function IO = eachColumn(A)
% EACHCOLUMN Loop over each column of an array
% Use EACHCOLUMN to iterate over each column in an array.
%    
%     for elem = EACHCOLUMN(A)
%         ...
%     end
%
% In each iteration, elem is the next column of the array A, an N-by-1 
% array, where N is size(A,2). EACHCOLUMN performs numel(A)/size(A,1) 
% iterations.
%  
% See also each, cell/each, eachRow, eachPage, eachSlice

%   Copyright 2014 The MathWorks, Inc.

IO = each.iterators.ArraySliceIterator(A,2);
end
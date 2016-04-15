function idx = getNextPerm(idx)
% GETNEXTPERM Find the next unique permutation of an index vector    
%
%   Copyright 2014 The MathWorks, Inc.

% Find the first element in the vector with a value less than the value to
% its right. Call that the pivot element
pivotID = find( idx(1:end-1) < idx(2:end), 1 ,'last');

% Construct the tail and replace any elements less than the pivot element
tail = idx(pivotID+1:end);
tail(tail <= idx(pivotID)) = Inf;

% finds the smallest element in the tail which is larger than the pivot
% element. Call that the ceil and store its offset.
[ceilElem, ceilID] = min(tail);

% swap the ceil, and the pivot
idx(ceilID+pivotID) = idx(pivotID);
idx(pivotID) = ceilElem;

% sort the remaining tail.
idx(pivotID+1:end) = sort(idx(pivotID+1:end));
    
end

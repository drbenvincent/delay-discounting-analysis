function out = eachPermutation(v,mode)
% EACHPERMUTATION Loop over all the permutations of a vector
% Use EACHPERMUTATION(V) to iterate over every unique permutation of the
% vector V.
%
%     for pV = eachPermutation(V)
%         % Loop Body
%     end
%
% In each iteration, pV is the next permutation of vector V in a
% lexicographic ordering of the vector, starting with the sorted vector.
% 
% Note: the total number of loop iterations grows rapidly with respect to
% the size of the input vector V (on the order of factorial(length(v)). 
% Execution of such loops might be possible, but could take an extremely long
% time to complete. Use ctrl-C to break out of a permutation loop which is 
% taking too long.
%
% Example:
% 
% for perm = eachPermutation([1 1 0 0])
%     disp(perm);
% end
%
% Use EACHPERMUTATION(V,'all') to iterate over every permutation of the
% vector V, including duplicate instances of permutations.
%
% Example:
%
% for perm = eachPermutation([1 1 0 0],'all')
%     disp(perm);
% end
% 
% See also eachRow, eachColumn, eachPage, eachSlice, cell/each, eachTuple, 
%   perms, factorial
% 

%   Copyright 2014 The MathWorks, Inc.

if nargin < 2
    mode = 'unique';
else
    mode = validatestring(mode,{'unique','all'});
end

try
    switch mode
        case 'unique'
            out = each.iterators.UniquePermutationIterator(v);
        otherwise
            out = each.iterators.AllPermutationIterator(v);
    end
catch ME
    throwAsCaller(ME)
end
end
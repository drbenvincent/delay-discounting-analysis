classdef PermutationIterator < each.iterators.Iterable
%PERMUTATIONITERATOR permutation iterator
% Iterator for looping over permutations of an array
%
% See Also: each, eachPermutation, each.iterators.Iterable
%

%   Copyright 2014-2015 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = protected)
        Ids  
        FirstVector
    end
    
    properties (Access = private)
        lastPerm
        lastK
    end
    
    methods (Access = protected)
        
        function perm = GetKthPerm(obj,k)
            if k > obj.NumberOfIterations
                perm = [];
                return
            end
            
            if isempty(obj.lastPerm) || k == 1
                obj.lastPerm = obj.Ids;
                obj.lastK = 1;
                perm = obj.Ids;
                return
            elseif k == obj.lastK
                perm = obj.lastPerm;
                return
            elseif k == (obj.lastK+1)
                obj.lastPerm = each.iterators.getNextPerm(obj.lastPerm);
                obj.lastK = obj.lastK+1;
            else
                % Only needed for out of order calculations.
                if obj.lastK < k;
                    start = obj.lastK+1;
                else
                    start = 2;
                    obj.lastPerm = obj.Ids;
                end
                for i = start:k
                    obj.lastPerm = each.iterators.getNextPerm(obj.lastPerm);
                end
                obj.lastK = k;
            end
            perm = obj.lastPerm;
        end
        
    end
    
end

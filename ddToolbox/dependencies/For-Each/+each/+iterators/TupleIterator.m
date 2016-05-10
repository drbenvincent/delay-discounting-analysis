classdef TupleIterator < each.iterators.Iterable
%TUPLEITERATOR tuple iterator
% Iterator for looping over sets of equal length arrays
%
% TupleIterator Methods:
%   each.iterators.TupleIterator/TupleIterator - Constructor for a tuple iterator
%   each.iterators.TupleIterator/getValue      - Get the Kth tuple of an iterator object.
%
% See Also: each, eachTuple, each.iterators.Iterable
%

%   Copyright 2014-2015 The MathWorks, Inc.
    properties (Access = private)
        Iters
    end
    
    properties (GetAccess = public, SetAccess = private)
        TupleSize;
    end
    
    methods
        
        function obj = TupleIterator(varargin)
            %TUPLEITERATIOR create a N-Tuple iterator from a set of arrays
            % TI = TUPLEITERATIOR(A1,...An) creates a tuple iterator which will iterate
            %                               over all the elements of several arrays.
            %                               All the inputs must be arrays with the same
            %                               number of elements, or whose iterators
            %                               produce the same number of iterations.
            %
            % Example, the following will iterate of each pair from arrays A and B:
            %
            %   A = 1:3;
            %   B = -1:1;
            %   TI = each.iterators.TupleIterator(A,B);
            %   n = TI.NumberOfIterations
            %
            % See Also: each, eachTuple, each.iterators.Iterable
            obj.TupleSize = nargin;
            obj.Iters = cellfun(@each.iterators.getIterator,varargin,'UniformOutput',false);
            siz = cellfun(@(c)c.NumberOfIterations,obj.Iters);
            
            if any(siz ~= siz(1))
               throwAsCaller(MException('iterators:Tuple:MismatchSize',...
                    'All arrays in the tuple must produce the same number of iterations.'));
            end
            obj.NumberOfIterations = siz(1);
        end
        
        function elem = getValue(obj,k)
            elem = cellfun(@(c)getValue(c,k),obj.Iters,'UniformOutput',false);
        end
        
    end
    
end

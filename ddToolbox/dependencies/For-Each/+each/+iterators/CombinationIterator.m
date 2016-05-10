classdef CombinationIterator < each.iterators.Iterable
%COMBINATIONITERATOR iterator for array combinations
% Iterator for looping over all the combinations of elements in a set of arrays
%
% CombinationIterator Methods:
%   each.iterators.CombinationIterator/CombinationIterator - Constructor for a combination iterator
%   each.iterators.CombinationIterator/getValue            - Get the Kth combination of an iterator object.
%
% See Also: each, eachCombination, each.iterators.Iterable
%

%   Copyright 2014-2015 The MathWorks, Inc.

    properties (GetAccess = public, SetAccess = private)
        NumberOfInputs;
    end
    
    properties (Access = private)
        Iters
        Dimensions
    end
    
    methods
        
        function obj = CombinationIterator(varargin)
            %COMBINATIONITERATOR create a N-Tuple iterator from a set of arrays
            % IO = COMBINATIONITERATOR(varargin) creates a combination iterator which
            %                                    will iterate over all pairwise
            %                                    elements of the arrays in varargin.
            %
            % Example, the following will iterate of each pair from arrays A and B:
            %
            %   A = 1:3;
            %   B = -1:1;
            %   IO = each.iterators.COMBINATIONITERATOR(A,B);
            %   n = IO.NumberOfIterations
            %
            % Note: If an element of any of the input arrays is empty, there will be 
            %       no iterations.
            %
            % See Also: each, eachTuple, each.iterators.Iterable
            
            obj.NumberOfInputs = nargin;
            
            % In order to iterate as a nested loop
            % reverse iteration on the input to loop "innermost" first
            obj.Iters = cellfun(@each.iterators.getIterator,varargin(end:-1:1),'UniformOutput',false);
            
            obj.Dimensions = cellfun(@(c)c.NumberOfIterations,obj.Iters);
            obj.NumberOfIterations = prod(obj.Dimensions);
            
            % uint64 support - works in 2013a and later
            % obj.Size = cellfun( @(c) uint64(c.NumberOfIterations),obj.Iters);
            % obj.NumberOfIterations = prod(obj.Size,'native');
        end
        
        function elem = getValue(obj,k)
            
            subs = {}; dim = obj.Dimensions;
            %Convert the kth linear index into multi-dimensional subscripts
            [subs{1:length(dim)}] = ind2sub(dim,k);
            
            %Get the elements for the subscripts
            elem = cellfun(@getValue,obj.Iters,subs,'UniformOutput',false);
            
            %Iterators are stored in the reverse order, reorder the outputs
            % to return the elements in the same order as the arguments.
            elem = elem(end:-1:1);
        end
        
    end
    
end

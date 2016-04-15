classdef ArrayIterator < each.iterators.Iterable
%ARRAYITERATOR Array Iterator
% Array Iterator for looping over each element of an array
%
% Example, a standard FOR loop:
%
%     for i = X
%         ...% Loop Body
%     end
%
% We can think of it as the equivalent loop:
%
%     sz = size(X);
%     numLoops = prod([sz(2:end)]);
%     for k = 1:numLoops
%         i = X(:,k);
%         ...% Loop Body
%     end
%
% This iterator is returned by a helper function, in this case EACH.
% This allows the following call:
%
%     for elem = each(A)
%         ...% Loop Body
%     end
%
% to behave like:
%
%     for k = 1:numel(A)
%         elem = A(k);
%         ...% Loop Body
%     end
%
% ArrayIterator Methods:
%   each.iterators.ArrayIterator/ArrayIterator - Constructor for an array 
%                                                iterator
%   each.iterators.ArrayIterator/GETVALUE      - Get the Kth value of an 
%                                                iterator object.
%
% ArrayIterator Properties:
%   each.iterators.ArrayIterator.NumberOfIterations - The number of 
%                                                     iterations.
%
% Note: This iterator only works with objects which can be indexed into
%       by linear indexing.
%
% See Also: each, eachTuple, each.iterators.Iterable, 
%   each.iterators.TupleIterator
%

%   Copyright 2014 The MathWorks, Inc.
    
    properties (Access = private)
        Array;
    end
    
    methods
        function obj = ArrayIterator(A)
            %ARRAYITERATOR Constructor for an array iterator
            % IO = ArrayIterator(A) returns an iterator object IO which can access
            %                       every element of the array A.
            %
            %
            % Note: The input A needs to support MATLAB® linear indexing. i.e. A(n) for
            % n > 0 and n <= NumberOfIterations should not error.
            %
            % See Also: each, each.iterators.Iterable
            obj.Array = A;
            obj.NumberOfIterations = numel(A);
        end
        
        function elem = getValue(obj,k)
            %GETVALUE  Get the Kth value of an iterator object.
            % ELEM = getValue(OBJ,K) returns the kth element of the array used to
            %                        create the instance of OBJ.
            %
            elem = obj.Array(k);
        end
        
    end
    
end
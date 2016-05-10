classdef ArraySliceIterator < each.iterators.Iterable
    %ARRAYSLICEITERATOR Array Slice Iterator Object
    % Iterator for looping over all the slices of an array
    %
    % ArraySliceIterator Methods:
    %   each.iterators.ArraySliceIterator/ArraySliceIterator - Constructor for an array slice iterator
    %   each.iterators.ArraySliceIterator/getValue           - Get the Kth slice of an iterator object.
    %
    % See Also: each, eachRow, eachColumn, eachSlice, each.iterators.Iterable
    %
    
    %   Copyright 2014 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = private)
        SliceDimensions
        ElementSize
    end
    
    properties (Access = private)
        dimsItr;
        Array;
    end
    
    methods
        function IO = ArraySliceIterator(A,workdim)
            %ARRAYSLICEITERATOR Constructor for an array iterator
            % IO = ArraySliceIterator(A,WORKDIM) returns an iterator object IO which can
            %                                  access every slice of the array A, as
            %                                  determined by the dimensions in WORKDIM.
            %                                  WORKDIM must be a vector containing the
            %                                  dimensions along which the array A will be
            %                                  divided.
            %
            % For Example, if A = rand(6,4,3), and WORKDIM = [2 3], then each iteration
            % would produce a double array with dimension 6x1x1, and the total number
            % of iterations would be 12.
            %
            % See Also: each, each.iterators.Iterable
            
            n = ndims(A);
            slice = setdiff(1:n,workdim);
            siz = size(A);
            
            % -----------
            % Calculate the element size
            elemSize = siz;
            elemSize(workdim < n) = 1;
            
            % -----------
            % Create indexing iterator
            % eachCombination avoids using num2cell for a memory win.
            dims = arrayfun(@(n){1:n},siz);
            dims(slice) = {':'};
            IO.dimsItr = eachCombination(dims{:});
            % -----------
            % get NumberOfIterations from index iterator.
            
            IO.ElementSize = elemSize;
            IO.Array = A;
            IO.NumberOfIterations = IO.dimsItr.NumberOfIterations;
            IO.SliceDimensions = slice;
        end
        
        function elem = getValue(obj,k)
            %GETVALUE  Get the Kth value of an iterator object.
            % ELEM = getValue(OBJ,K) returns the kth slice of the array used to create
            %                        the instance of OBJ.
            %
            idx = getValue(obj.dimsItr,k);
            elem = obj.Array(idx{:});
        end
        
    end
    
end



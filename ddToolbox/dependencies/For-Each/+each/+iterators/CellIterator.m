classdef CellIterator < each.iterators.Iterable
%CELLITERATOR Cell Array Iterator
%
% CellIterator Methods:
%   each.iterators.CellIterator/CellIterator - Constructor for a cell array
%                                              iterator.
%   each.iterators.CellIterator/getValue     - Get the Kth cell of an
%                                              cell array iterator object.
%
% See Also: each, cell/each each.iterators.Iterable

%   Copyright 2014 The MathWorks, Inc.
    
    properties (Access = private)
        CellArray;
    end
    
    methods
        function obj = CellIterator(C)
            %CELLITERATOR Constructor for a cell array iterator
            % IO = CellIterator(A) returns an iterator object IO which can access
            %                      every cell of the cell array C.
            %
            % See Also: each, each.iterators.Iterable
            obj.CellArray = C;
            obj.NumberOfIterations = numel(C);
        end
        
        function elem = getValue(obj,k)
            %GETVALUE  Get the Kth value of an iterator object.
            % ELEM = getValue(OBJ,K) returns the contents of the kth cell of the array 
            %                        used to create the instance of OBJ.
            elem = obj.CellArray{k};
        end
    end
    
end
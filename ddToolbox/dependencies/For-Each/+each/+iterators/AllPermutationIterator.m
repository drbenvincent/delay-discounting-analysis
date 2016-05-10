classdef AllPermutationIterator < each.iterators.PermutationIterator
    %ALLPERMUTATIONITERATOR permutation iterator
    % Iterator for looping over the permutations of a given vector
    %
    % AllPermutationIterator Methods:
    %   each.iterators.AllPermutationIterator/AllPermutationIterator - Constructor for an permutation iterator
    %   each.iterators.AllPermutationIterator/getValue            - Get the Kth permutation of an iterator object.
    %
    % Note: This iterator only works for types which can be passed into SORT
    %
    % See Also: each, eachPermutation, each.iterators.Iterable
    %
    
    %   Copyright 2014 The MathWorks, Inc.
    
    properties (Access = private)
        Multiplicity
        UniqueVals
    end
    
    methods
        function obj = AllPermutationIterator(vect)
            %ALLPERMUTATIONITERATOR Constructor for a permutation iterator 
            % IO = AllPermutationIterator(v) returns an iterator object which can access
            %                                every permutation of the vector v.
            %
            % See Also: each, each.iterators.Iterable
            if isempty(vect)
                obj.NumberOfIterations = 0;
                obj.UniqueVals = vect;
                obj.Ids = double.empty(size(vect));
                return
            end
            
            if ~isvector(vect)
                error('iterators:eachPermutation:notavector',...
                    'Expected the input to be a vector.')
            end
            obj.NumberOfIterations = factorial(length(vect));
            
            [obj.UniqueVals,~,obj.Ids] = unique( sort(vect) );
            obj.FirstVector = obj.UniqueVals(obj.Ids);
            obj.Multiplicity = uint32(prod(histc(obj.Ids,1:max(obj.Ids))));
            
        end
        
        function elem = getValue(obj,k)
            %GETVALUE  Get the Kth value of an iterator object.
            % PERM = getValue(OBJ,K) returns the kth permutation of the vector used to
            %                        create the instance of OBJ.
            %
            k = 1+idivide(k-1,obj.Multiplicity,'floor');
            elem = obj.UniqueVals(obj.GetKthPerm(k));
        end
        
    end
    
end

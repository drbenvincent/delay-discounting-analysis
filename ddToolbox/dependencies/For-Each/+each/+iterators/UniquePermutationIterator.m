classdef UniquePermutationIterator < each.iterators.PermutationIterator
%UNIQUEPERMUTATIONITERATOR permutation iterator
% Iterator for looping over all the unique permutations of a given array
%
% UniquePermutationIterator Methods:
%   each.iterators.UniquePermutationIterator/UniquePermutationIterator - Constructor for an permutation iterator
%   each.iterators.UniquePermutationIterator/getValue            - Get the Kth permutation of an iterator object.
%
% Note: This iterator only works for types which can be passed into UNIQUE
%
% See Also: each, eachPermutation, each.iterators.Iterable
%

%   Copyright 2014 The MathWorks, Inc.
    
    properties (Access = private)
        UniqueVals
    end

    methods
        function obj = UniquePermutationIterator(vect)
            %UNIQUEPERMUTATIONITERATOR Constructor for a permutation iterator
            % IO = UniquePermutationIterator(v) returns an iterator object which can access
            %                                   every unique permutation of the vector v.
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
            
            obj.FirstVector = sort(vect);
            
            [obj.UniqueVals,~,obj.Ids] = unique(obj.FirstVector);
            obj.NumberOfIterations = getNumPerms(obj.Ids);
            
        end
        
        function elem = getValue(obj,k)
            %GETVALUE  Get the Kth value of an iterator object.
            % PERM = getValue(OBJ,K) returns the kth permutation of the vector used to
            %                        create the instance of OBJ.
            %
            elem = obj.UniqueVals(obj.GetKthPerm(k));
        end
        
    end
end

function num = getNumPerms(ids)
    % save the length of the ids
    n = numel(ids);
    
    % count the duplicates, and remove counts which occur once.
    dupeCounts = histc(ids,1:max(ids));
    dupeCounts = dupeCounts(:)';
    dupeCounts(dupeCounts==1) = [];
    
    % The formula for the number of unique permutations of a vector is as
    % follows:
    %
    %   N = n! / prod(r_i!), i = 1 to number of unique elements of ids, 
    %
    % where r_i is the number of instances of the ith unique element.
    % This calculation is guaranteed to be an integer.
    if isempty(dupeCounts)
        num = factorial(n);
        return
    elseif n < 19
        % When n is less than 19, there is no risk of precision loss.
        num = factorial(n)/prod(factorial(dupeCounts));
        return
    end
    
    % for n > 18, the numerator of the calculation can exceed 2^52-1
    % To correctly perform the division, the avoid doing the multiplication
    % until all the dividing factors have been canceled out.
    denoms = [];
    for k = dupeCounts;
        % List all the terms contributing to the product of the denominator.
        denoms = [denoms, 2:k]; %#ok<AGROW>
    end
    % list the largest factorial, and the subsequent numbers which would
    % have saturated the calculation if included in the product.
    % Note: prod(cumFactorial) == n! in exact arithmetic, and n cannot be
    % very large in general.
    cumFactorial = [factorial(18),19:n];
    for d = denoms
        % Can the current denominator factor divide any of the factorial
        % terms?
        k = find(mod(cumFactorial,d) == 0,1,'first');
        if isempty(k)
            % If d didn't divide any of the elements in cumFactorial then
            % break d into prime factors and divide out those factors
            for fact = factor(d)
                k = find(mod(cumFactorial,fact) == 0,1,'first');
                cumFactorial(k) = cumFactorial(k)/fact;
            end
        else
            % if d divides a term in cumFactorial, divide out the term.
            cumFactorial(k) = cumFactorial(k)/d;
        end
    end
    % after the above loop completes, all of the factors will be divided
    % out of cumFactorial, so the resulting array's product is exactly
    % equal to the number of unique permutations.
    % Note: this can exceed to 2^52-1 so functions which rely on this
    % calculation need to check for overflow on their own
    num = prod(cumFactorial);

end


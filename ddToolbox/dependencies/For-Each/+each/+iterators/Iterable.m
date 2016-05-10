classdef Iterable < handle
% Interface Class for Loop Iterable Objects
%
% To create an iterator class, inherit from each.iterators.Iterable and
% implement the getValue method and set the NumberOfIterations property.
%
% For example:
%
%   classdef MyIterator < each.iterators.Iterable
%
% See the code for each.iterators.ArrayIterator as an example of how to 
% create your own iterator.
%
% Iterable Members:
%   Abstract Members:
%       each.iterators.Iterable.NumberOfIterations - Number of iterations.
%       each.iterators.Iterable/getValue - Used to get individual iteration
%                                           values.
%
% See Also each.iterators.ArrayIterator, each
%

%   Copyright 2014 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = protected)
        % NumberOfIterations must be set to a scalar value in the child class constructor
        NumberOfIterations;
    end
    
    methods (Abstract)
        %GETVALUE  Abstract Method for accessing iterator data.
        % VAL = getValue(OBJ,K) returns the Kth element of the iterator OBJ. K must
        %                       accept integer values between 1 and N, where
        %                       N = getNumIterations(OBJ).
        val = getValue(obj,k);
    end
    
    methods (Hidden, Sealed)
        % In order to overload FOR, the each.iterators.Iterable class overloads the 
        % SIZE and SUBSREF methods, and provides a simplified interface of the 
        % GETVALUE method and NumberOfIterations property.
        function [varargout] = size(obj)
            % Size
            varargout = {1 obj.NumberOfIterations};
        end
        
        function out = subsref(obj,s)
            % Subsref
            
            % Subsref should only call getValue when the expression is:
            % IO(:,k)
            if isscalar(s)  ...
            && strcmp(s.type,'()') ...
            && numel(s.subs) == 2 ...
            && strcmp(s.subs(1),':')
                try
                    k = s.subs{2};
                    out = getValue(obj,k);
                catch ME
                    throwAsCaller(ME);
                end
                % call back to the object to get properties
            else
                out = builtin('subsref',obj,s);
            end
        end
    end
    
    methods
        function set.NumberOfIterations(obj,rhs)
            if ~isnumeric(rhs) || ~isscalar(rhs)
                throwAsCaller(MException('Iterators:Iterable:NumberOfIterations',...
                    'NumberOfIterations must be set to a numeric scalar value'));
            end
            
            if rhs > each.iterators.MaxIterations
                throwAsCaller(MException('each:iterators:TooManyIterations'...
                    ,'Cannot perform more than %d loop iterations.',each.iterators.MaxIterations));
            end
            obj.NumberOfIterations = floor(rhs);
        end
    end
end


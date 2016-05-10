function it = getIterator(obj)
% GETITERATOR Return an iterator for the input type passed in, otherwise 
% uses the each function to select the iterator

%   Copyright 2014 The MathWorks, Inc.

if isa(obj, 'each.iterators.Iterable')
    it = obj;
else
    it = each(obj);
end
end
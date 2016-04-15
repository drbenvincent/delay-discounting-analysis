function out = each(C)
% EACH Step through each element in an array.
% When the argument to each is a cell array, the resulting elements are the 
% contents of the cell. This is useful for cell arrays containing strings.
%
% Example, iterate over strings in a cell array.
% 
%     strings = {'Monday','Tuesday','Wednesday','Thursday','Friday'};
%     for str = each(strings)
%         disp(str)
%     end
%
% Example, iterate over elements with different types:
%  
%     c = {'astring',magic(3),cell.empty(0,1)};
%     for elem = each( c )
%         class(elem)
%     end
%
% See Also: EACH, EACHROW, EACHCOLUMN, EACHSLICE, EACHTUPLE, 
%   EACHCOMBINATION, EACHPERMUTATION
% 

%   Copyright 2014 The MathWorks, Inc.

out = each.iterators.CellIterator(C);
end
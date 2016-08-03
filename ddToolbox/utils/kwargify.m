function [new] = kwargify(defaults, updates)
% KWARIFY. This function will take a `defaults` structure  
% and it will overwrite (or add) any structure fields provided in the
% `updates` structure.
%
% Written by Benjamin Vincent, www.inferenceLab.com

assert(isstruct(defaults))
assert(isstruct(updates))

% exit if no kwargs are given
if numel(updates)==0
	return
end

% initialise new structure as default, to be updated
new = defaults;

fields = fieldnames(updates);
for n=1:numel(fields)
	new.(fields{n}) = updates.(fields{n});
end

return
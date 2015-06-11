function [opts]=kwargify(opts,kwargs)
% KWARIFY. This function will take a structure of default options (opts)
% and it will overwrite (or add) any structure fields provided in the
% structure kwargs.
%
% Written by Benjamin Vincent, www.inferenceLab.com

% exit if no kwargs are given
if numel(kwargs)==0
	return
end

% list of fields specified in kwarg structure
fields = fieldnames(kwargs);

% loop through adding, or overwriting the fields in opts with that in
% kwargs.
for n=1:numel(fields)
	opts.(fields{n}) = kwargs.(fields{n});
end

return
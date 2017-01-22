function [outputMatrix, fields] = struct2Matrix(inputStruct)
outputMatrix = [];

fields = fieldnames(inputStruct);

% remove fields if any consist of a single NaN
for n=1:numel(fields)
	if numel(inputStruct.(fields{n}))==1
		inputStruct = rmfield(inputStruct, fields{n});
	end
end

% update fields
fields = fieldnames(inputStruct);

% check vectors of all fields are identical length
if numel(fields)>1
	len = structfun( @(x) numel(x), inputStruct);
	assert(all(len==len(1)), 'Vectors in each field need to be identical length')
end

for n=1:numel(fields)
	outputMatrix(:,n) = inputStruct.(fields{n});
end
end


function output = asRowVector(input)
% coerce into a row vector
if iscolumn(input)
	output = input';
end
end

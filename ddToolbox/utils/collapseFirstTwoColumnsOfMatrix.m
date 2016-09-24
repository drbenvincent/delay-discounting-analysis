function outputMatrix = collapseFirstTwoColumnsOfMatrix(inputMatrix)

assert(isnumeric(inputMatrix))

oldDims = size(inputMatrix);

switch numel(oldDims)
	case{2} % scalar
		newDims = [oldDims(1)*oldDims(2) 1];
	case{3} % vector
		newDims = [oldDims(1)*oldDims(2) oldDims(3)];
	case{4} % matrix
		newDims = [oldDims(1)*oldDims(2) oldDims(3) oldDims(4)];
end

outputMatrix = reshape(inputMatrix, newDims);
end
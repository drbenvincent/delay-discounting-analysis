function p = psychometric_function(x, params)
% P(choose delayed) = params(:,1) + (1-2*params(:,1)) * normcdf( (x ./ params(:,2)) , 0, 1);
if verLessThan('matlab','9.1')
	p = bsxfun(@plus,...
		params(:,1),...
		bsxfun(@times, ...
		(1-2*params(:,1)),...
		normcdf( bsxfun(@rdivide, x, params(:,2) ) , 0, 1)) );
else
	% use new array broadcasting in 2016b
	p = params(:,1) + (1-2*params(:,1)) * normcdf( (x ./ params(:,2)) , 0, 1);
end

end

function p = psychometric_function(x, params)
% P(choose delayed) = params(:,1) + (1-2*params(:,1)) * normcdf( (x ./ params(:,2)) , 0, 1);

epsilon = params(:,1);
alpha = params(:,2);

if verLessThan('matlab','9.1')
	p = bsxfun(@plus,...
		epsilon,...
		bsxfun(@times, ...
		(1-2*epsilon),...
		normcdf( bsxfun(@rdivide, x, alpha ) , 0, 1)) );
else
	% use new array broadcasting in 2016b
	p = epsilon + (1-2*epsilon) * normcdf( (x ./ alpha) , 0, 1);
end

end

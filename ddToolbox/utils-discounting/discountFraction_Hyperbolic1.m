function discountFraction = discountFraction_Hyperbolic1(k,delay)
% discountFraction = 1 / (1+k.delay)

if verLessThan('matlab','9.1')
	discountFraction = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, delay) ) );
else
	% use new array broadcasting in 2016b
	discountFraction = 1 ./ (1 + k.*delay) ;
end
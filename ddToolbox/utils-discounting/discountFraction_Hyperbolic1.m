function discountFraction = discountFraction_Hyperbolic1(k,delay)
% discountFraction = 1 / (1+k.delay)
discountFraction = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, delay) ) );
end
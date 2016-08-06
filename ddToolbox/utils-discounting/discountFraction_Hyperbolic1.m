function discountFraction = discountFraction_Hyperbolic1(k,D)
% discountFraction = 1 / (1+k.D)
discountFraction = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, D) ) );
end
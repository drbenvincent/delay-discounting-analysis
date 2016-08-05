function k = magnitudeEffect(reward, params)

assert(isscalar(reward))
assert(size(params,2)==2)

m = params(:,1);
c = params(:,2);
% -----------------------------------------------------------
% log(k) = m * log(B) + c
% k = exp( m * log(B) + c )
% fh = @(x,params) exp( params(:,1) * log(x) + params(:,2));
% Fast vectorised version of above --------------------------
k =  exp( bsxfun(@plus, bsxfun(@times,m,log(reward)) ,c));
% -----------------------------------------------------------
end
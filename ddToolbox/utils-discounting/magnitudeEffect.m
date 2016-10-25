function k = magnitudeEffect(reward, params)
% log(k) = m * log(B) + c
% k = exp( m * log(B) + c )
    
assert(size(params,2)==2)

m = params(:,1);
c = params(:,2);

if verLessThan('matlab','9.1')
	k = exp( bsxfun(@plus, bsxfun(@times,m,log(reward)) ,c));
else
	% use new array broadcasting in 2016b
	k = exp( params(:,1) * log(reward) + params(:,2));
end

end

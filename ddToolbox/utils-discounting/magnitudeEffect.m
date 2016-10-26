function k = magnitudeEffect(reward, params)
% log(k) = m * log(reward) + c
% k = exp( m * log(reward) + c )
    
assert(size(params,2)==2)

m = params(:,1);
c = params(:,2);

if verLessThan('matlab','9.1')
	k = exp( bsxfun(@plus, bsxfun(@times,m,log(reward)) ,c));
else
	% use new array broadcasting in 2016b
	k = exp( m * log(reward) + c);
end

end

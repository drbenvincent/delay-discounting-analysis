function ribbon_plot(x,Y, col)

assert(isrow(x), 'x must be a row vector, ie [1, N]')
assert(size(Y,2)==numel(x),'Y must have same number of columns as x')


yPointEstimate = median(Y);

p = prctile(Y,[25 75],1);
lower = p(1,:);
upper = p(2,:);




plot(x,yPointEstimate,'k-')
hold on
[h]=my_shaded_errorbar_zone_UL(x,upper,lower,col);
% plot(x,lower,'k:')
% plot(x,upper,'k:')


end

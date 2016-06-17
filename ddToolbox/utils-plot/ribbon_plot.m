function ribbon_plot(x,Y, intervals)

assert(isrow(x), 'x must be a row vector, ie [1, N]')
assert(size(Y,2)==numel(x),'Y must have same number of columns as x')

col = [0 0 1];

% function to convert a credible interval to percentiles
% eg 
% interval2percentiles(50) = [25 75]
% interval2percentiles(95) = [2.5 97.5]
interval2percentiles = @(interval) [0+((100-interval)/2) 100-((100-interval)/2)];

% sort intervals from narrow to wide
intervals = sort(intervals, 'descend');

% Point estimate
yPointEstimate = median(Y);
plot(x,yPointEstimate,'k-')
hold on

% plot each interval
for i = 1:numel(intervals)
	percentiles = interval2percentiles( intervals(i) );
	p = prctile(Y,percentiles,1);
	lower = p(1,:);
	upper = p(2,:);
	
	h(i) = my_shaded_errorbar_zone_UL(x,upper,lower,col);
end

end

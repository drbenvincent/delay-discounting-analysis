function percentiles = interval2percentiles(interval)
% function to convert a credible interval to percentiles
% eg 
% interval2percentiles(50) = [25 75]
% interval2percentiles(95) = [2.5 97.5]

assert(isscalar(interval), 'expecting scalar input')
assert(interval>=0, 'interval must be between 0-100')
assert(interval<=100, 'interval must be between 0-100')

percentiles = [0+((100-interval)/2)...
	100-((100-interval)/2)];

end

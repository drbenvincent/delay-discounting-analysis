function autoXlim(samples, supp)
% sets the XLim so that it's centered on the median of the MCMC samples
% provided and +/- X std. But not outside of the support of the variable

% double check samples is a vector
samples = samples(:);


M = median(samples);
STD = std(samples);

lower = M - STD * 3;
upper = M + STD * 3;

if isnumeric(supp) ~= 1
	switch supp
		case{'positive'}
			supp=[0 inf];
	end
end

if lower < min(supp)
	lower = min(supp);
end
if upper > max(supp)
	upper = max(supp);
end

xlim([lower upper])
drawnow
return

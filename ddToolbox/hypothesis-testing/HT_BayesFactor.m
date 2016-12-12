function  HT_BayesFactor(priorSamples, posteriorSamples, hypothesis, testValue)
%warning('This code only implements the hypothesis x<0')

%import mcmc.*

if testValue~=0
	error('not yet implemented for testValue ~= 0')
end


switch hypothesis
	case{'>'}
		% Discard samples >testValue
		% in order to evaluate the order-restricted hypothesis x<0, then we need to
		% remove samples where either prior or posterior contain samples
		priorSamples = priorSamples(priorSamples>testValue);
		posteriorSamples = posteriorSamples(posteriorSamples>testValue);

		% create bin centers
		min_val = testValue;
		max_val = max([priorSamples ; posteriorSamples]);
		centers = linspace(min_val, max_val, 100);
		
	case{'<'}
		% Discard samples >testValue
		% in order to evaluate the order-restricted hypothesis x<0, then we need to
		% remove samples where either prior or posterior contain samples
		priorSamples = priorSamples(priorSamples<testValue);
		posteriorSamples = posteriorSamples(posteriorSamples<testValue);
		
		% create bin centers
		max_val = testValue ;
		min_val = min([priorSamples ; posteriorSamples]);
		centers = linspace(min_val, max_val, 100);
		
	case{'~='}
		error('not yet implemented')
		
	otherwise
		error('hypothesis supplied not valid')
end

% check we actually have samples remaining after this exclusion
assert(numel(priorSamples)>100, 'Excessively low (or zero) prior samples remaining')
assert(numel(posteriorSamples)>100, 'Excessively low (or zero) posteriorSamples samples remaining')

density.prior		= densityAtTestValue(priorSamples, centers, testValue);
density.posterior	= densityAtTestValue(posteriorSamples, centers, testValue);

switch hypothesis
	case{'>','<'}
		warning('NASTY FIX HERE FOR ORDER-RESTRICTED HYPOTHESIS. Due to the silly binning behaviour.')
		% double, because the bin width extends beyond the actual testValue
		density.prior.atTestValue = density.prior.atTestValue * 2;
		density.posterior.atTestValue = density.posterior.atTestValue * 2;
end


%% Calculate Bayes Factor
T = table();
T.BayesFactor10 = density.posterior.atTestValue / density.prior.atTestValue;
T.BayesFactor01 = density.prior.atTestValue / density.posterior.atTestValue;
disp(T)

%% Plot
bayesFactorPlot(density, priorSamples, posteriorSamples, centers)

end

% function density = densityAtZero(samples,edges)
% warning('this function will fail if last entry of ''edges'' is not zero')
% [density.N,~] = histcounts(samples, edges, 'Normalization','pdf');
% density.atZero = density.N(end);
% end

function density = densityAtTestValue(samples, centers, testValue)
assert(ismember(testValue, centers), 'centres must contain testValue')
% calculate histogram density
edges = centers2edges(centers);
[density.N,~] = histcounts(samples, edges, 'Normalization','pdf');
%plot(centers,density.N)
% find density at testValue
indexOfTestValue = find(centers==testValue);
density.atTestValue = density.N(indexOfTestValue);
end


function bayesFactorPlot(density, priorSamples, posteriorSamples, centers)

hold off
niceHistogramPlot(priorSamples, centers, [0.7 0.7 0.7])
hold on
niceHistogramPlot(posteriorSamples, centers, [0.2 0.2 0.2])

% plot density at x=0
plot(0, density.prior.atTestValue, 'ko', 'MarkerFaceColor','w')
plot(0, density.posterior.atTestValue, 'ko', 'MarkerFaceColor','k')
%legend('prior','post', 'Location','NorthWest')
%legend boxoff
axis square
box off
axis tight
mcmc.removeYaxis()
%addTextToFigure('TR',...
%	sprintf('log BF_{10} = %2.2f',log(BF_10)),...
%	15,	'latex')
%ylabel('density')
xlabel('G^m')
title('Bayesian hypothesis testing')

	function niceHistogramPlot(samples,centers, col)
		histogram(samples, centers,...
			'Normalization', 'pdf',...
			'EdgeColor', 'none',...
			'FaceColor', col);
	end

end

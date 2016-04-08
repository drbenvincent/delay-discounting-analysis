function  HT_BayesFactor(priorSamples, posteriorSamples)
warning('This code only implements the hypothesis x<0')

%% Discard samples >0
% in order to evaluate the order-restricted hypothesis x<0, then we need to
% remove samples where either prior or posterior contain samples
priorSamples = priorSamples(priorSamples<0);
posteriorSamples = posteriorSamples(posteriorSamples<0);

%% Obtain the probability density at x=0
% TODO: choose edges automatically
binsize = 0.05;
edges = [-5:binsize:0];
density.prior			= densityAtZero(priorSamples,edges);
density.posterior = densityAtZero(posteriorSamples,edges);

%% Calculate Bayes Factor
% TODO: more verbose reporting of results
BF_10 = density.posterior.atZero / density.prior.atZero
BF_01 = density.prior.atZero / density.posterior.atZero

%% Plot
bayesFactorPlot(density, priorSamples, posteriorSamples, edges)

end

function density = densityAtZero(samples,edges)
[density.N,~] = histcounts(samples, edges, 'Normalization','pdf');
density.atZero = density.N(end);
end

function bayesFactorPlot(density, priorSamples, posteriorSamples, edges)

hold on
niceHistogramPlot(priorSamples,edges, [0.7 0.7 0.7])
niceHistogramPlot(posteriorSamples,edges, [0.2 0.2 0.2])

% plot density at x=0
plot(0, density.prior.atZero,'ko','MarkerFaceColor','w')
plot(0, density.posterior.atZero,'ko','MarkerFaceColor','k')
%legend('prior','post', 'Location','NorthWest')
%legend boxoff
axis square
box off
axis tight, xlim([-2 0])
removeYaxis()
%addTextToFigure('TR',...
%	sprintf('log BF_{10} = %2.2f',log(BF_10)),...
%	15,	'latex')
%ylabel('density')
xlabel('G^m')
title('Bayesian hypothesis testing')

	function niceHistogramPlot(samples,edges, col)
		h = histogram(samples, edges, 'Normalization','pdf');
		h.EdgeColor = 'none';
		h.FaceColor = col;
	end

end